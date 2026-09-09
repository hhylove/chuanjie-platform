package com.chuanjie.platform.tenant.runtime;

import com.chuanjie.platform.tenant.api.context.TenantContext;
import com.chuanjie.platform.tenant.api.context.TenantContextHolder;
import java.util.Objects;
import java.util.function.Supplier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * 在可信租户作用域和数据库本地事务变量内执行租户工作。
 *
 * <p>{@code SET LOCAL}的作用域仅限当前事务，连接回到连接池前由PostgreSQL自动恢复，避免租户串线。
 */
public final class TenantTransactionExecutor {

    private static final String SET_TENANT_SQL =
            "SELECT set_config('app.current_tenant_id', ?, true)";
    private static final String SET_PLACEMENT_VERSION_SQL =
            "SELECT set_config('app.tenant_placement_version', ?, true)";

    private final JdbcTemplate jdbcTemplate;
    private final TransactionTemplate transactionTemplate;
    private final TenantPlacementVersionProvider placementVersionProvider;

    /**
     * 创建租户事务执行器。
     *
     * @param jdbcTemplate 已由数据源路由器选中的租户数据库访问器
     * @param transactionManager 与租户数据库访问器对应的事务管理器
     * @param placementVersionProvider 控制面放置版本查询器
     */
    public TenantTransactionExecutor(
            JdbcTemplate jdbcTemplate,
            PlatformTransactionManager transactionManager,
            TenantPlacementVersionProvider placementVersionProvider) {
        this.jdbcTemplate = Objects.requireNonNull(jdbcTemplate, "jdbcTemplate must not be null");
        this.transactionTemplate = new TransactionTemplate(
                Objects.requireNonNull(transactionManager, "transactionManager must not be null"));
        this.placementVersionProvider = Objects.requireNonNull(
                placementVersionProvider, "placementVersionProvider must not be null");
    }

    /**
     * 校验路由版本并在数据库RLS可读取的事务变量中执行租户工作。
     *
     * @param context 已验证的平台租户上下文
     * @param work 只能访问当前租户数据的工作
     * @param <T> 工作返回类型
     * @return 工作结果
     */
    public <T> T execute(TenantContext context, Supplier<T> work) {
        Objects.requireNonNull(context, "context must not be null");
        Objects.requireNonNull(work, "work must not be null");

        long currentVersion = placementVersionProvider.currentVersion(context.tenantId());
        if (currentVersion != context.placementVersion()) {
            throw new StaleTenantPlacementException(
                    context.tenantId(), context.placementVersion(), currentVersion);
        }

        return transactionTemplate.execute(status -> {
            try (TenantContextHolder.Scope ignored = TenantContextHolder.open(context)) {
                jdbcTemplate.queryForObject(SET_TENANT_SQL, String.class, context.tenantId().toString());
                jdbcTemplate.queryForObject(
                        SET_PLACEMENT_VERSION_SQL,
                        String.class,
                        Long.toString(context.placementVersion()));
                return work.get();
            }
        });
    }
}
