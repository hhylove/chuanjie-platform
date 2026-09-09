package com.chuanjie.platform.tenant.runtime;

import java.util.UUID;

/** 查询控制面中租户当前数据放置版本，供写事务拒绝过期路由。 */
@FunctionalInterface
public interface TenantPlacementVersionProvider {

    /**
     * 查询租户当前放置版本。
     *
     * @param tenantId 租户标识
     * @return 大于零的当前放置版本
     */
    long currentVersion(UUID tenantId);
}
