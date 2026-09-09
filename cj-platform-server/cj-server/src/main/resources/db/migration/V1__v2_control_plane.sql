-- R1 SaaS控制面：只保存全局身份、租户、成员、套餐、配额、放置、审计和可靠事件。
-- UUID由应用生成UUIDv7；控制面不保存用户密码、第三方令牌明文或数据库密码明文。

CREATE TABLE cp_account (
    id uuid PRIMARY KEY,
    display_name varchar(128) NOT NULL,
    avatar_url varchar(1024),
    status varchar(24) NOT NULL,
    token_version bigint NOT NULL DEFAULT 0,
    last_login_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_cp_account_status CHECK (status IN ('ACTIVE', 'DISABLED', 'LOCKED')),
    CONSTRAINT ck_cp_account_token_version CHECK (token_version >= 0)
);

COMMENT ON TABLE cp_account IS '全局自然人账号，不保存密码；一个账号可以加入多个租户';
COMMENT ON COLUMN cp_account.id IS '账号UUIDv7主键，由应用生成';
COMMENT ON COLUMN cp_account.display_name IS '账号在未进入租户时使用的全局显示名称';
COMMENT ON COLUMN cp_account.avatar_url IS '头像地址，不保存图片二进制';
COMMENT ON COLUMN cp_account.status IS '账号状态：ACTIVE、DISABLED、LOCKED';
COMMENT ON COLUMN cp_account.token_version IS '令牌版本；递增后使该账号旧访问令牌失效';
COMMENT ON COLUMN cp_account.last_login_at IS '最近一次完成OIDC登录的时间';
COMMENT ON COLUMN cp_account.created_at IS '记录创建时间';
COMMENT ON COLUMN cp_account.updated_at IS '记录最后更新时间';

CREATE TABLE cp_account_contact (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES cp_account(id),
    type varchar(16) NOT NULL,
    normalized_value varchar(320) NOT NULL,
    verified_at timestamptz,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    retired_at timestamptz,
    CONSTRAINT ck_cp_account_contact_type CHECK (type IN ('EMAIL', 'MOBILE'))
);

CREATE UNIQUE INDEX uk_cp_verified_contact
    ON cp_account_contact(type, normalized_value)
    WHERE verified_at IS NOT NULL AND retired_at IS NULL;
CREATE UNIQUE INDEX uk_cp_primary_contact
    ON cp_account_contact(account_id, type)
    WHERE is_primary = true AND retired_at IS NULL;

COMMENT ON TABLE cp_account_contact IS '账号邮箱和手机号历史；仅已验证且未退役的联系方式全局唯一';
COMMENT ON COLUMN cp_account_contact.id IS '联系方式UUIDv7主键';
COMMENT ON COLUMN cp_account_contact.account_id IS '所属全局账号';
COMMENT ON COLUMN cp_account_contact.type IS '联系方式类型：EMAIL或MOBILE';
COMMENT ON COLUMN cp_account_contact.normalized_value IS '标准化后的邮箱或手机号，用于唯一匹配';
COMMENT ON COLUMN cp_account_contact.verified_at IS '外部身份源确认该联系方式的时间，空值表示未验证';
COMMENT ON COLUMN cp_account_contact.is_primary IS '是否为该账号同类型的主联系方式';
COMMENT ON COLUMN cp_account_contact.created_at IS '记录创建时间';
COMMENT ON COLUMN cp_account_contact.retired_at IS '联系方式停止使用的时间，保留历史用于审计';

CREATE TABLE cp_external_identity (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES cp_account(id),
    issuer varchar(512) NOT NULL,
    subject varchar(512) NOT NULL,
    provider_code varchar(64) NOT NULL,
    claims_snapshot jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at timestamptz,
    CONSTRAINT uk_cp_external_identity UNIQUE (issuer, subject)
);

COMMENT ON TABLE cp_external_identity IS 'OIDC外部身份与全局账号的绑定关系';
COMMENT ON COLUMN cp_external_identity.id IS '外部身份UUIDv7主键';
COMMENT ON COLUMN cp_external_identity.account_id IS '绑定的全局账号';
COMMENT ON COLUMN cp_external_identity.issuer IS 'OIDC签发者规范化地址';
COMMENT ON COLUMN cp_external_identity.subject IS '签发者范围内稳定且唯一的subject';
COMMENT ON COLUMN cp_external_identity.provider_code IS '平台配置的OIDC提供方代码，不绑定厂商SDK';
COMMENT ON COLUMN cp_external_identity.claims_snapshot IS '脱敏后的必要声明快照，禁止保存令牌和完整敏感字段';
COMMENT ON COLUMN cp_external_identity.created_at IS '首次绑定时间';
COMMENT ON COLUMN cp_external_identity.last_login_at IS '该外部身份最近登录时间';

CREATE TABLE cp_tenant (
    id uuid PRIMARY KEY,
    tenant_code varchar(64) NOT NULL,
    name varchar(200) NOT NULL,
    status varchar(24) NOT NULL,
    owner_account_id uuid NOT NULL REFERENCES cp_account(id),
    timezone varchar(64) NOT NULL DEFAULT 'Asia/Shanghai',
    locale varchar(32) NOT NULL DEFAULT 'zh-CN',
    expires_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_tenant_code UNIQUE (tenant_code),
    CONSTRAINT ck_cp_tenant_status CHECK (status IN ('PENDING', 'ACTIVE', 'SUSPENDED', 'EXPIRED', 'CLOSING', 'CLOSED'))
);

COMMENT ON TABLE cp_tenant IS '公司租户主档；tenant_code创建后不可修改';
COMMENT ON COLUMN cp_tenant.id IS '租户UUIDv7主键';
COMMENT ON COLUMN cp_tenant.tenant_code IS '全局唯一且不可变的租户代码';
COMMENT ON COLUMN cp_tenant.name IS '租户公司或组织显示名称';
COMMENT ON COLUMN cp_tenant.status IS '租户状态：PENDING、ACTIVE、SUSPENDED、EXPIRED、CLOSING、CLOSED';
COMMENT ON COLUMN cp_tenant.owner_account_id IS '租户唯一所有者账号；移交必须通过受控业务操作';
COMMENT ON COLUMN cp_tenant.timezone IS '租户默认IANA时区';
COMMENT ON COLUMN cp_tenant.locale IS '租户默认语言区域代码';
COMMENT ON COLUMN cp_tenant.expires_at IS '租户服务到期时间，空值表示未设置';
COMMENT ON COLUMN cp_tenant.created_at IS '记录创建时间';
COMMENT ON COLUMN cp_tenant.updated_at IS '记录最后更新时间';

CREATE TABLE cp_login_session (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES cp_account(id),
    current_tenant_id uuid REFERENCES cp_tenant(id),
    token_hash bytea NOT NULL,
    family_id uuid NOT NULL,
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    rotated_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_login_session_token_hash UNIQUE (token_hash)
);

CREATE INDEX ix_cp_login_session_account ON cp_login_session(account_id, revoked_at, expires_at);
CREATE INDEX ix_cp_login_session_family ON cp_login_session(family_id);

COMMENT ON TABLE cp_login_session IS '平台刷新会话；只保存随机刷新令牌摘要并支持会话族重放吊销';
COMMENT ON COLUMN cp_login_session.id IS '登录会话UUIDv7主键';
COMMENT ON COLUMN cp_login_session.account_id IS '会话所属全局账号';
COMMENT ON COLUMN cp_login_session.current_tenant_id IS '当前选中的租户；空值表示尚未选租户';
COMMENT ON COLUMN cp_login_session.token_hash IS '刷新令牌不可逆摘要，明文只向客户端返回一次';
COMMENT ON COLUMN cp_login_session.family_id IS '令牌轮换会话族标识，用于检测重放后整体吊销';
COMMENT ON COLUMN cp_login_session.expires_at IS '刷新会话绝对过期时间';
COMMENT ON COLUMN cp_login_session.revoked_at IS '会话吊销时间，空值表示尚未吊销';
COMMENT ON COLUMN cp_login_session.rotated_at IS '该令牌被轮换替代的时间';
COMMENT ON COLUMN cp_login_session.created_at IS '会话创建时间';
COMMENT ON COLUMN cp_login_session.last_seen_at IS '会话最近活动时间';

CREATE TABLE cp_tenant_member (
    id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES cp_tenant(id),
    account_id uuid NOT NULL REFERENCES cp_account(id),
    member_no varchar(64) NOT NULL,
    display_name varchar(128) NOT NULL,
    status varchar(24) NOT NULL,
    joined_at timestamptz,
    left_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_tenant_member_account UNIQUE (tenant_id, account_id),
    CONSTRAINT uk_cp_tenant_member_no UNIQUE (tenant_id, member_no),
    CONSTRAINT ck_cp_tenant_member_status CHECK (status IN ('INVITED', 'ACTIVE', 'DISABLED', 'LEFT'))
);

COMMENT ON TABLE cp_tenant_member IS '账号在租户内的成员身份，是后续业务授权主体';
COMMENT ON COLUMN cp_tenant_member.id IS '成员UUIDv7主键，同时作为membership_id';
COMMENT ON COLUMN cp_tenant_member.tenant_id IS '成员所属租户';
COMMENT ON COLUMN cp_tenant_member.account_id IS '成员关联的全局账号';
COMMENT ON COLUMN cp_tenant_member.member_no IS '租户内唯一且稳定的成员编号';
COMMENT ON COLUMN cp_tenant_member.display_name IS '成员在当前租户内的显示名称';
COMMENT ON COLUMN cp_tenant_member.status IS '成员状态：INVITED、ACTIVE、DISABLED、LEFT';
COMMENT ON COLUMN cp_tenant_member.joined_at IS '成员正式加入租户时间';
COMMENT ON COLUMN cp_tenant_member.left_at IS '成员退出或被移除时间';
COMMENT ON COLUMN cp_tenant_member.created_at IS '记录创建时间';
COMMENT ON COLUMN cp_tenant_member.updated_at IS '记录最后更新时间';

CREATE TABLE cp_member_invitation (
    id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES cp_tenant(id),
    contact_type varchar(16) NOT NULL,
    contact_value varchar(320) NOT NULL,
    inviter_id uuid NOT NULL REFERENCES cp_tenant_member(id),
    token_hash bytea NOT NULL,
    expires_at timestamptz NOT NULL,
    accepted_at timestamptz,
    revoked_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_member_invitation_token UNIQUE (token_hash),
    CONSTRAINT ck_cp_member_invitation_type CHECK (contact_type IN ('EMAIL', 'MOBILE'))
);

COMMENT ON TABLE cp_member_invitation IS '租户成员一次性邀请；只保存邀请令牌摘要';
COMMENT ON COLUMN cp_member_invitation.id IS '邀请UUIDv7主键';
COMMENT ON COLUMN cp_member_invitation.tenant_id IS '邀请目标租户';
COMMENT ON COLUMN cp_member_invitation.contact_type IS '邀请联系方式类型：EMAIL或MOBILE';
COMMENT ON COLUMN cp_member_invitation.contact_value IS '标准化后的邀请联系方式';
COMMENT ON COLUMN cp_member_invitation.inviter_id IS '发起邀请的租户成员';
COMMENT ON COLUMN cp_member_invitation.token_hash IS '一次性邀请令牌不可逆摘要';
COMMENT ON COLUMN cp_member_invitation.expires_at IS '邀请过期时间';
COMMENT ON COLUMN cp_member_invitation.accepted_at IS '邀请接受时间，空值表示未接受';
COMMENT ON COLUMN cp_member_invitation.revoked_at IS '邀请撤销时间，空值表示未撤销';
COMMENT ON COLUMN cp_member_invitation.created_at IS '邀请创建时间';

CREATE TABLE cp_tenant_domain (
    id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES cp_tenant(id),
    domain varchar(253) NOT NULL,
    verified_at timestamptz,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_tenant_domain UNIQUE (domain)
);

CREATE UNIQUE INDEX uk_cp_tenant_primary_domain ON cp_tenant_domain(tenant_id) WHERE is_primary = true;

COMMENT ON TABLE cp_tenant_domain IS '租户自定义域名及验证状态';
COMMENT ON COLUMN cp_tenant_domain.id IS '租户域名UUIDv7主键';
COMMENT ON COLUMN cp_tenant_domain.tenant_id IS '域名所属租户';
COMMENT ON COLUMN cp_tenant_domain.domain IS '标准化的小写域名，全局唯一';
COMMENT ON COLUMN cp_tenant_domain.verified_at IS '域名所有权验证通过时间';
COMMENT ON COLUMN cp_tenant_domain.is_primary IS '是否为租户主域名';
COMMENT ON COLUMN cp_tenant_domain.created_at IS '记录创建时间';

CREATE TABLE cp_tenant_login_policy (
    tenant_id uuid PRIMARY KEY REFERENCES cp_tenant(id),
    allowed_providers text[] NOT NULL DEFAULT ARRAY[]::text[],
    mfa_required boolean NOT NULL DEFAULT false,
    session_ttl_minutes integer NOT NULL DEFAULT 43200,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_cp_login_policy_ttl CHECK (session_ttl_minutes BETWEEN 5 AND 43200)
);

COMMENT ON TABLE cp_tenant_login_policy IS '租户允许的OIDC提供方、MFA和会话时长策略';
COMMENT ON COLUMN cp_tenant_login_policy.tenant_id IS '策略所属租户，一租户一条';
COMMENT ON COLUMN cp_tenant_login_policy.allowed_providers IS '允许使用的OIDC提供方代码；空数组表示使用平台默认';
COMMENT ON COLUMN cp_tenant_login_policy.mfa_required IS '租户是否要求身份提供方完成多因素认证';
COMMENT ON COLUMN cp_tenant_login_policy.session_ttl_minutes IS '刷新会话最长分钟数，范围5至43200';
COMMENT ON COLUMN cp_tenant_login_policy.updated_at IS '策略最后更新时间';

CREATE TABLE cp_plan (
    id uuid PRIMARY KEY,
    code varchar(64) NOT NULL,
    name varchar(128) NOT NULL,
    status varchar(24) NOT NULL,
    version integer NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_plan_code_version UNIQUE (code, version),
    CONSTRAINT ck_cp_plan_status CHECK (status IN ('DRAFT', 'ACTIVE', 'RETIRED')),
    CONSTRAINT ck_cp_plan_version CHECK (version > 0)
);

COMMENT ON TABLE cp_plan IS '套餐版本定义；R1不包含在线价格和支付逻辑';
COMMENT ON COLUMN cp_plan.id IS '套餐版本UUIDv7主键';
COMMENT ON COLUMN cp_plan.code IS '稳定套餐代码';
COMMENT ON COLUMN cp_plan.name IS '套餐显示名称';
COMMENT ON COLUMN cp_plan.status IS '套餐状态：DRAFT、ACTIVE、RETIRED';
COMMENT ON COLUMN cp_plan.version IS '同一套餐代码的递增版本号';
COMMENT ON COLUMN cp_plan.created_at IS '记录创建时间';
COMMENT ON COLUMN cp_plan.updated_at IS '记录最后更新时间';

CREATE TABLE cp_plan_module (
    id uuid PRIMARY KEY,
    plan_id uuid NOT NULL REFERENCES cp_plan(id),
    module_code varchar(64) NOT NULL,
    enabled boolean NOT NULL DEFAULT true,
    limits_json jsonb NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT uk_cp_plan_module UNIQUE (plan_id, module_code)
);

COMMENT ON TABLE cp_plan_module IS '套餐包含的模块开关和默认限制';
COMMENT ON COLUMN cp_plan_module.id IS '套餐模块UUIDv7主键';
COMMENT ON COLUMN cp_plan_module.plan_id IS '所属套餐版本';
COMMENT ON COLUMN cp_plan_module.module_code IS '平台稳定模块代码';
COMMENT ON COLUMN cp_plan_module.enabled IS '该套餐是否启用模块';
COMMENT ON COLUMN cp_plan_module.limits_json IS '模块低频扩展限制，强一致配额仍使用配额表';

CREATE TABLE cp_tenant_subscription (
    id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES cp_tenant(id),
    plan_id uuid NOT NULL REFERENCES cp_plan(id),
    starts_at timestamptz NOT NULL,
    expires_at timestamptz,
    status varchar(24) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_cp_subscription_status CHECK (status IN ('PENDING', 'ACTIVE', 'EXPIRED', 'CANCELED')),
    CONSTRAINT ck_cp_subscription_period CHECK (expires_at IS NULL OR expires_at > starts_at)
);

CREATE UNIQUE INDEX uk_cp_tenant_current_subscription
    ON cp_tenant_subscription(tenant_id)
    WHERE status IN ('PENDING', 'ACTIVE');

COMMENT ON TABLE cp_tenant_subscription IS '租户套餐订阅；首期由平台管理分配，不在线收费';
COMMENT ON COLUMN cp_tenant_subscription.id IS '订阅UUIDv7主键';
COMMENT ON COLUMN cp_tenant_subscription.tenant_id IS '订阅所属租户';
COMMENT ON COLUMN cp_tenant_subscription.plan_id IS '订阅的套餐版本';
COMMENT ON COLUMN cp_tenant_subscription.starts_at IS '订阅开始生效时间';
COMMENT ON COLUMN cp_tenant_subscription.expires_at IS '订阅到期时间，空值表示未设置';
COMMENT ON COLUMN cp_tenant_subscription.status IS '订阅状态：PENDING、ACTIVE、EXPIRED、CANCELED';
COMMENT ON COLUMN cp_tenant_subscription.created_at IS '记录创建时间';
COMMENT ON COLUMN cp_tenant_subscription.updated_at IS '记录最后更新时间';

CREATE TABLE cp_tenant_quota (
    id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES cp_tenant(id),
    quota_code varchar(64) NOT NULL,
    limit_value bigint NOT NULL,
    used_value bigint NOT NULL DEFAULT 0,
    period varchar(16) NOT NULL,
    period_started_at timestamptz,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_tenant_quota UNIQUE (tenant_id, quota_code, period),
    CONSTRAINT ck_cp_tenant_quota_values CHECK (limit_value >= -1 AND used_value >= 0),
    CONSTRAINT ck_cp_tenant_quota_period CHECK (period IN ('STATIC', 'DAILY', 'MONTHLY'))
);

COMMENT ON TABLE cp_tenant_quota IS '租户强一致配额和聚合用量；limit_value为-1表示不限量';
COMMENT ON COLUMN cp_tenant_quota.id IS '租户配额UUIDv7主键';
COMMENT ON COLUMN cp_tenant_quota.tenant_id IS '配额所属租户';
COMMENT ON COLUMN cp_tenant_quota.quota_code IS '稳定配额代码，如USER_SEATS或STORAGE_BYTES';
COMMENT ON COLUMN cp_tenant_quota.limit_value IS '硬限制值，-1表示不限量';
COMMENT ON COLUMN cp_tenant_quota.used_value IS '当前周期已用量，不得小于零';
COMMENT ON COLUMN cp_tenant_quota.period IS '计量周期：STATIC、DAILY、MONTHLY';
COMMENT ON COLUMN cp_tenant_quota.period_started_at IS '当前计量周期起点，静态配额可为空';
COMMENT ON COLUMN cp_tenant_quota.updated_at IS '配额或用量最后更新时间';

CREATE TABLE cp_data_placement (
    tenant_id uuid PRIMARY KEY REFERENCES cp_tenant(id),
    mode varchar(24) NOT NULL,
    cell_code varchar(64) NOT NULL,
    datasource_key varchar(128) NOT NULL,
    secret_ref varchar(512) NOT NULL,
    version bigint NOT NULL DEFAULT 1,
    updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_cp_data_placement_mode CHECK (mode IN ('SHARED', 'DEDICATED', 'PRIVATE')),
    CONSTRAINT ck_cp_data_placement_version CHECK (version > 0)
);

COMMENT ON TABLE cp_data_placement IS '租户数据放置路由；只保存数据源定位键和密钥引用';
COMMENT ON COLUMN cp_data_placement.tenant_id IS '路由所属租户，一租户一条当前路由';
COMMENT ON COLUMN cp_data_placement.mode IS '放置模式：SHARED、DEDICATED、PRIVATE';
COMMENT ON COLUMN cp_data_placement.cell_code IS '承载该租户的数据Cell代码';
COMMENT ON COLUMN cp_data_placement.datasource_key IS '部署配置中的数据源定位键，不是连接密码';
COMMENT ON COLUMN cp_data_placement.secret_ref IS '环境或密钥服务中的连接凭据引用，禁止保存明文密码';
COMMENT ON COLUMN cp_data_placement.version IS '路由版本；迁移切换时递增以拒绝旧路由写入';
COMMENT ON COLUMN cp_data_placement.updated_at IS '路由最后更新时间';

CREATE TABLE cp_tenant_feature_override (
    id uuid PRIMARY KEY,
    tenant_id uuid NOT NULL REFERENCES cp_tenant(id),
    module_code varchar(64) NOT NULL,
    enabled boolean NOT NULL,
    expires_at timestamptz,
    reason varchar(512) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cp_tenant_feature_override UNIQUE (tenant_id, module_code)
);

COMMENT ON TABLE cp_tenant_feature_override IS '对套餐模块能力的临时人工覆盖，所有变更必须审计';
COMMENT ON COLUMN cp_tenant_feature_override.id IS '功能覆盖UUIDv7主键';
COMMENT ON COLUMN cp_tenant_feature_override.tenant_id IS '覆盖所属租户';
COMMENT ON COLUMN cp_tenant_feature_override.module_code IS '被覆盖的稳定模块代码';
COMMENT ON COLUMN cp_tenant_feature_override.enabled IS '覆盖后的模块启用状态';
COMMENT ON COLUMN cp_tenant_feature_override.expires_at IS '覆盖自动失效时间，空值表示人工撤销';
COMMENT ON COLUMN cp_tenant_feature_override.reason IS '人工覆盖原因，供审计追溯';
COMMENT ON COLUMN cp_tenant_feature_override.created_at IS '覆盖创建时间';

CREATE TABLE cp_audit_log (
    id uuid PRIMARY KEY,
    tenant_id uuid REFERENCES cp_tenant(id),
    actor_account_id uuid REFERENCES cp_account(id),
    action varchar(128) NOT NULL,
    object_type varchar(128) NOT NULL,
    object_id varchar(128) NOT NULL,
    before_json jsonb,
    after_json jsonb,
    request_id varchar(128) NOT NULL,
    occurred_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX ix_cp_audit_tenant_time ON cp_audit_log(tenant_id, occurred_at DESC);
CREATE INDEX ix_cp_audit_request ON cp_audit_log(request_id);

COMMENT ON TABLE cp_audit_log IS '控制面关键操作不可抵赖审计；敏感字段写入前必须脱敏';
COMMENT ON COLUMN cp_audit_log.id IS '审计记录UUIDv7主键';
COMMENT ON COLUMN cp_audit_log.tenant_id IS '相关租户；全局操作可为空';
COMMENT ON COLUMN cp_audit_log.actor_account_id IS '操作人全局账号；系统任务可为空';
COMMENT ON COLUMN cp_audit_log.action IS '稳定审计动作代码';
COMMENT ON COLUMN cp_audit_log.object_type IS '被操作对象类型';
COMMENT ON COLUMN cp_audit_log.object_id IS '被操作对象业务标识';
COMMENT ON COLUMN cp_audit_log.before_json IS '变更前脱敏快照';
COMMENT ON COLUMN cp_audit_log.after_json IS '变更后脱敏快照';
COMMENT ON COLUMN cp_audit_log.request_id IS '贯穿请求链路的唯一请求编号';
COMMENT ON COLUMN cp_audit_log.occurred_at IS '操作发生时间';

CREATE TABLE cp_outbox_event (
    event_id uuid PRIMARY KEY,
    aggregate_type varchar(128) NOT NULL,
    aggregate_id varchar(128) NOT NULL,
    event_type varchar(128) NOT NULL,
    payload jsonb NOT NULL,
    occurred_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at timestamptz,
    retry_count integer NOT NULL DEFAULT 0,
    next_retry_at timestamptz,
    CONSTRAINT ck_cp_outbox_retry_count CHECK (retry_count >= 0)
);

CREATE INDEX ix_cp_outbox_pending ON cp_outbox_event(next_retry_at, occurred_at) WHERE published_at IS NULL;

COMMENT ON TABLE cp_outbox_event IS '控制面事务内可靠事件，供后续异步发布器投递';
COMMENT ON COLUMN cp_outbox_event.event_id IS '事件UUIDv7主键，同时作为幂等键';
COMMENT ON COLUMN cp_outbox_event.aggregate_type IS '事件聚合根类型';
COMMENT ON COLUMN cp_outbox_event.aggregate_id IS '事件聚合根标识';
COMMENT ON COLUMN cp_outbox_event.event_type IS '稳定事件类型代码';
COMMENT ON COLUMN cp_outbox_event.payload IS '事件载荷，不得包含令牌、密码或未脱敏联系方式';
COMMENT ON COLUMN cp_outbox_event.occurred_at IS '业务事件发生时间';
COMMENT ON COLUMN cp_outbox_event.published_at IS '成功发布完成时间，空值表示待发布';
COMMENT ON COLUMN cp_outbox_event.retry_count IS '发布失败后的累计重试次数';
COMMENT ON COLUMN cp_outbox_event.next_retry_at IS '下一次允许重试时间';
