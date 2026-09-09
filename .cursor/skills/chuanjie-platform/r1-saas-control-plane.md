# R1 SaaS 控制面专项设计

> 状态：已评审通过，开发中
> 依据：[architecture-v2-saas.md](architecture-v2-saas.md)  
> 范围：全局账号、OIDC、租户、成员、套餐、配额、数据库路由和租户切换

## 1. 目标

建立所有业务模块依赖的多租户根基：一个自然人拥有一个全局账号，可加入多家公司并切换当前租户；普通客户使用共享数据库，大客户可路由到独立数据库；认证服务可替换，业务授权不绑定Casdoor。

## 2. 本期范围

- OIDC授权码登录、回调、登出和外部身份绑定。
- 全局账号及邮箱、手机号标准化和唯一性处理。
- 租户创建、启停、冻结、到期和注销申请状态。
- 租户成员邀请、加入、启停、退出及管理员移交。
- 套餐、订阅、模块开关和配额定义；首期不在线收费。
- 当前租户选择、租户绑定访问令牌、刷新会话和强制失效。
- 数据库放置策略、逻辑路由和共享/独立数据库模式。
- 控制面审计、管理接口和隔离集成测试。

## 3. 非目标

- 部门、岗位、角色、菜单、数据与字段权限在R2实现。
- 微信、企微、钉钉、飞书等身份源的厂商细节由OIDC服务配置，R1只认标准OIDC声明。
- 在线套餐购买、支付、开票和自动续费不在R1实现。
- 独立数据库的自动搬迁工具在R9实现；R1只建立路由模型和可测试的数据源选择器。
- 不提供用户名密码登录，不在平台保存用户密码。

## 4. 身份与会话流程

```text
浏览器 -> 平台 /oidc/login -> OIDC服务（默认Casdoor）
OIDC服务 -> 平台 /oidc/callback -> 校验state/nonce/PKCE与令牌
平台 -> 匹配或创建全局账号 -> 返回可加入的租户列表
用户选择租户 -> 校验成员状态 -> 签发租户绑定的平台会话
后续请求 -> 校验平台令牌 -> 构造可信TenantContext -> 数据源路由/RLS
```

- 平台通过标准Discovery、Authorization Code + PKCE接入OIDC。
- OIDC令牌只证明外部身份；平台签发自己的短期访问令牌，以承载当前 `account_id`、`tenant_id`、`membership_id`、会话号和令牌版本。
- Access Token默认15分钟；Refresh Session默认30天，可按租户安全策略缩短。
- Refresh Token只保存随机值摘要，明文只返回客户端一次；轮换使用，检测重复使用后吊销整个会话族。
- 尚未选择租户时只允许调用会话与租户列表接口，不能访问租户业务API。

## 5. 控制面数据模型

主键统一使用PostgreSQL `uuid`，由应用生成时间有序UUIDv7。时间字段使用 `timestamptz`，所有状态使用受约束字符串并保留变更审计。

### 5.1 身份

| 表 | 关键字段 | 约束与说明 |
|---|---|---|
| `cp_account` | `id`, `display_name`, `avatar_url`, `status`, `token_version`, `last_login_at` | 全局自然人；不保存密码 |
| `cp_account_contact` | `account_id`, `type`, `normalized_value`, `verified_at`, `is_primary` | 已验证手机号/邮箱全局唯一；保留更换历史 |
| `cp_external_identity` | `account_id`, `issuer`, `subject`, `provider_code`, `claims_snapshot` | `(issuer, subject)`全局唯一；claims快照脱敏 |
| `cp_login_session` | `account_id`, `current_tenant_id`, `token_hash`, `family_id`, `expires_at`, `revoked_at` | 刷新令牌摘要、轮换和设备会话 |

### 5.2 租户与成员

| 表 | 关键字段 | 约束与说明 |
|---|---|---|
| `cp_tenant` | `id`, `tenant_code`, `name`, `status`, `owner_account_id`, `timezone`, `locale` | `tenant_code`全局唯一且创建后不可改 |
| `cp_tenant_member` | `tenant_id`, `account_id`, `member_no`, `display_name`, `status`, `joined_at` | `(tenant_id, account_id)`唯一；成员是业务授权主体 |
| `cp_member_invitation` | `tenant_id`, `contact_type`, `contact_value`, `inviter_id`, `expires_at`, `accepted_at` | 邀请令牌仅存摘要；一次性使用 |
| `cp_tenant_domain` | `tenant_id`, `domain`, `verified_at`, `is_primary` | 域名全局唯一；验证后启用 |
| `cp_tenant_login_policy` | `tenant_id`, `allowed_providers`, `mfa_required`, `session_ttl_minutes` | 限制租户可用登录方式和会话策略 |

### 5.3 套餐与路由

| 表 | 关键字段 | 约束与说明 |
|---|---|---|
| `cp_plan` | `code`, `name`, `status`, `version` | 套餐定义，不包含在线价格逻辑 |
| `cp_plan_module` | `plan_id`, `module_code`, `enabled`, `limits_json` | 模块开关及默认限制 |
| `cp_tenant_subscription` | `tenant_id`, `plan_id`, `starts_at`, `expires_at`, `status` | 同一时刻最多一个有效订阅 |
| `cp_tenant_quota` | `tenant_id`, `quota_code`, `limit_value`, `used_value`, `period` | 支持用户、存储、API和任务量 |
| `cp_data_placement` | `tenant_id`, `mode`, `cell_code`, `datasource_key`, `secret_ref`, `version` | `SHARED`/`DEDICATED`/`PRIVATE`；不保存明文密码 |
| `cp_tenant_feature_override` | `tenant_id`, `module_code`, `enabled`, `expires_at` | 对套餐能力做有审计的临时覆盖 |

### 5.4 审计与可靠事件

| 表 | 关键字段 | 用途 |
|---|---|---|
| `cp_audit_log` | `tenant_id?`, `actor_account_id`, `action`, `object_type`, `object_id`, `before_json`, `after_json`, `request_id` | 控制面关键操作审计 |
| `cp_outbox_event` | `event_id`, `aggregate_type`, `aggregate_id`, `event_type`, `payload`, `published_at`, `retry_count` | 事务内记录租户/成员/订阅变更事件 |

## 6. 状态机

### 租户

`PENDING -> ACTIVE -> SUSPENDED -> ACTIVE`；到期进入 `EXPIRED`，注销申请进入 `CLOSING`，完成合规保留和导出后才进入 `CLOSED`。冻结/到期时禁止业务写入，但允许租户管理员查看账单、导出数据和处理续期。

### 成员

`INVITED -> ACTIVE -> DISABLED -> ACTIVE`，主动退出或管理员移除进入 `LEFT`。租户唯一Owner不能退出或被禁用，必须先完成Owner移交。

### 订阅

`PENDING -> ACTIVE -> EXPIRED/CANCELED`。套餐升级即时生效；降级默认下个周期生效，且不得直接删除超额数据，只禁止继续新增并提示治理。

## 7. API契约

### 匿名及会话API

| 方法 | 路径 | 用途 |
|---|---|---|
| `GET` | `/api/v1/auth/oidc/login` | 生成state、nonce、PKCE并跳转OIDC |
| `GET` | `/api/v1/auth/oidc/callback` | 完成OIDC回调及全局账号映射 |
| `GET` | `/api/v1/session/tenants` | 返回当前账号可用租户列表 |
| `POST` | `/api/v1/session/select-tenant` | 校验成员资格并签发租户绑定会话 |
| `POST` | `/api/v1/session/refresh` | 轮换刷新令牌 |
| `POST` | `/api/v1/session/logout` | 吊销当前会话 |

### 平台管理API

| 方法 | 路径 | 用途 |
|---|---|---|
| `POST/GET/PATCH` | `/platform-api/v1/tenants` | 租户创建、查询和状态管理 |
| `POST/GET/PATCH` | `/platform-api/v1/plans` | 套餐和模块能力管理 |
| `PUT` | `/platform-api/v1/tenants/{id}/subscription` | 分配或变更订阅 |
| `PUT` | `/platform-api/v1/tenants/{id}/placement` | 配置共享/独立/私有数据放置 |
| `GET` | `/platform-api/v1/audit-logs` | 查询控制面审计日志 |

### 租户成员API

| 方法 | 路径 | 用途 |
|---|---|---|
| `GET` | `/admin-api/v1/members` | 当前租户成员分页查询 |
| `POST` | `/admin-api/v1/members/invitations` | 邀请成员 |
| `POST` | `/api/v1/invitations/{token}/accept` | 接受邀请 |
| `PATCH` | `/admin-api/v1/members/{id}/status` | 启停成员 |
| `POST` | `/admin-api/v1/ownership-transfer` | 移交租户Owner |

所有响应统一包含 `code`、`data`、`message`、`requestId`；所有修改接口使用幂等键并记录审计。

## 8. 数据源路由与隔离

- 控制面使用固定控制库连接，不经过租户数据源路由。
- 进入租户API前先建立不可变 `TenantContext`；异步任务必须在任务载荷中携带已验证租户和放置版本。
- 数据源选择器依据 `cp_data_placement` 缓存路由，缓存失效时回源控制库。
- `datasource_key`只定位部署配置，实际口令通过 `secret_ref`从环境或密钥服务读取。
- 共享库连接在事务开始时设置数据库会话租户变量，RLS策略读取该变量；事务结束必须清理。
- 路由版本不匹配时拒绝写入并重新解析，避免租户迁移切换期间写入旧库。

## 9. 配额与模块开关

- 模块访问同时检查订阅、套餐模块和租户覆盖项；前端隐藏只改善体验，后端必须强制。
- 强一致配额（如用户席位）在控制面事务中校验；高频计量（API、存储、任务）先累积用量事件再周期汇总。
- 达到软阈值时告警，达到硬阈值时只阻止新增，不阻止读取、删除或导出。
- 配额变更、人工覆盖和用量校准全部进入审计日志。

## 10. 安全要求

- OIDC强制校验issuer、audience、签名、state、nonce、PKCE和时间窗口。
- 外部身份自动合并只能依据同一已验证联系方式；冲突时进入人工处理，禁止静默合并。
- 平台管理员与租户管理员权限完全分离；平台运维默认不能查看租户业务正文。
- 邀请令牌、刷新令牌和验证码只存不可逆摘要。
- 日志不得记录OIDC令牌、手机号/邮箱全文、数据库密钥或邀请明文。
- 租户状态、Owner、放置和订阅变更属于高风险操作，要求二次确认并写不可抵赖审计。

## 11. 测试与验收

### 自动化测试

- OIDC成功、state/nonce错误、签名错误、账号冲突和重复回调。
- 同一账号加入多租户、无成员资格切换被拒、禁用成员会话失效。
- Refresh Token轮换、重放检测、全会话吊销和令牌版本失效。
- 共享租户A无法读取或修改租户B数据；绕过MyBatis时仍被RLS阻止。
- 共享、独立和私有三种放置模式选择正确，路由版本变化后旧写入被拒。
- 套餐到期、模块关闭、席位超额和降级不删除已有数据。
- 重复邀请、重复创建租户和重复订阅变更保持幂等。

### 验收标准

1. 一个账号可加入至少三个测试租户并安全切换。
2. 任何租户业务请求都能追溯到账号、成员、租户、会话和请求编号。
3. 应用层过滤与PostgreSQL RLS隔离测试全部通过。
4. Casdoor替换为标准测试OIDC服务时，业务代码无需修改。
5. 控制面数据库不存任何第三方令牌或数据库密码明文。
6. 所有表、字段、接口和配置均有用途与约束注释。

## 12. 评审后实施顺序

1. 创建全新Maven/前端workspace和测试骨架。
2. 先写架构边界测试和PostgreSQL Testcontainers测试。
3. 建控制面Flyway脚本与领域模型。
4. 实现OIDC登录、全局账号映射和租户选择。
5. 实现租户、成员、套餐、配额和放置管理。
6. 完成隔离、安全、审计、恢复及接口验收。

本文已评审通过。实现须严格限定在本专项范围；部门、岗位、角色与业务授权留在R2。
