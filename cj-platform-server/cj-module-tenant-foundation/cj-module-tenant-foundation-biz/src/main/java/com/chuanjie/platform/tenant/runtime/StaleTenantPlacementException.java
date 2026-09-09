package com.chuanjie.platform.tenant.runtime;

import java.util.UUID;

/** 租户请求携带的数据放置版本已过期，必须重新解析路由后重试。 */
public final class StaleTenantPlacementException extends RuntimeException {

    public StaleTenantPlacementException(UUID tenantId, long requestedVersion, long currentVersion) {
        super("Stale tenant placement for " + tenantId + ": requested=" + requestedVersion
                + ", current=" + currentVersion);
    }
}
