package com.chuanjie.platform.tenant.runtime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.chuanjie.platform.tenant.api.context.TenantContext;
import com.chuanjie.platform.tenant.api.context.TenantContextHolder;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;

class TenantTransactionExecutorTest {

    private static final TenantContext CONTEXT = new TenantContext(
            UUID.fromString("01993270-3000-7000-8000-000000000001"),
            UUID.fromString("01993270-3000-7000-8000-000000000002"),
            UUID.fromString("01993270-3000-7000-8000-000000000003"),
            UUID.fromString("01993270-3000-7000-8000-000000000004"),
            9L);

    private JdbcTemplate jdbcTemplate;
    private PlatformTransactionManager transactionManager;
    private TransactionStatus transactionStatus;
    private TenantPlacementVersionProvider placementVersionProvider;

    @BeforeEach
    void setUp() {
        jdbcTemplate = mock(JdbcTemplate.class);
        transactionManager = mock(PlatformTransactionManager.class);
        transactionStatus = mock(TransactionStatus.class);
        placementVersionProvider = mock(TenantPlacementVersionProvider.class);
        when(transactionManager.getTransaction(any(TransactionDefinition.class))).thenReturn(transactionStatus);
    }

    @Test
    void bindsTrustedContextAndDatabaseSettingsInsideTransaction() {
        when(placementVersionProvider.currentVersion(CONTEXT.tenantId())).thenReturn(CONTEXT.placementVersion());
        TenantTransactionExecutor executor =
                new TenantTransactionExecutor(jdbcTemplate, transactionManager, placementVersionProvider);

        String result = executor.execute(CONTEXT, () -> {
            assertThat(TenantContextHolder.required()).isEqualTo(CONTEXT);
            return "done";
        });

        assertThat(result).isEqualTo("done");
        assertThat(TenantContextHolder.current()).isEmpty();
        verify(jdbcTemplate).queryForObject(
                "SELECT set_config('app.current_tenant_id', ?, true)",
                String.class,
                CONTEXT.tenantId().toString());
        verify(jdbcTemplate).queryForObject(
                "SELECT set_config('app.tenant_placement_version', ?, true)",
                String.class,
                Long.toString(CONTEXT.placementVersion()));
        verify(transactionManager).commit(transactionStatus);
    }

    @Test
    void stalePlacementVersionIsRejectedBeforeTransactionStarts() {
        when(placementVersionProvider.currentVersion(CONTEXT.tenantId())).thenReturn(10L);
        TenantTransactionExecutor executor =
                new TenantTransactionExecutor(jdbcTemplate, transactionManager, placementVersionProvider);

        assertThatThrownBy(() -> executor.execute(CONTEXT, () -> "must-not-run"))
                .isInstanceOf(StaleTenantPlacementException.class)
                .hasMessageContaining(CONTEXT.tenantId().toString());

        verifyNoInteractions(jdbcTemplate);
        verifyNoInteractions(transactionManager);
        assertThat(TenantContextHolder.current()).isEmpty();
    }
}
