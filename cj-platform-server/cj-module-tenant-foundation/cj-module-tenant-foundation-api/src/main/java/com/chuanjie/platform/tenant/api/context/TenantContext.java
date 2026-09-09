package com.chuanjie.platform.tenant.api.context;

import java.util.Objects;
import java.util.UUID;

/**
 * 一次已认证租户请求的可信身份上下文。
 *
 * @param accountId 全局自然人账号标识
 * @param tenantId 当前租户标识
 * @param membershipId 账号在当前租户内的成员身份标识
 * @param sessionId 平台登录会话标识，用于审计和强制失效
 * @param placementVersion 租户数据放置版本，写入前必须与控制面当前版本一致
 */
public record TenantContext(
        UUID accountId,
        UUID tenantId,
        UUID membershipId,
        UUID sessionId,
        long placementVersion) {

    public TenantContext {
        Objects.requireNonNull(accountId, "accountId must not be null");
        Objects.requireNonNull(tenantId, "tenantId must not be null");
        Objects.requireNonNull(membershipId, "membershipId must not be null");
        Objects.requireNonNull(sessionId, "sessionId must not be null");
        if (placementVersion <= 0) {
            throw new IllegalArgumentException("placementVersion must be positive");
        }
    }
}
