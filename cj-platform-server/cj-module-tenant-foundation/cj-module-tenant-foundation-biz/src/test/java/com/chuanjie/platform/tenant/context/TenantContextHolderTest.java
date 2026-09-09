package com.chuanjie.platform.tenant.context;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatIllegalArgumentException;
import static org.assertj.core.api.Assertions.assertThatIllegalStateException;

import com.chuanjie.platform.tenant.api.context.TenantContext;
import com.chuanjie.platform.tenant.api.context.TenantContextHolder;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class TenantContextHolderTest {

    private static final TenantContext CONTEXT = new TenantContext(
            UUID.fromString("01993270-2000-7000-8000-000000000001"),
            UUID.fromString("01993270-2000-7000-8000-000000000002"),
            UUID.fromString("01993270-2000-7000-8000-000000000003"),
            UUID.fromString("01993270-2000-7000-8000-000000000004"),
            7L);

    @Test
    void contextExistsOnlyInsideItsScope() {
        assertThat(TenantContextHolder.current()).isEmpty();

        try (TenantContextHolder.Scope ignored = TenantContextHolder.open(CONTEXT)) {
            assertThat(TenantContextHolder.required()).isEqualTo(CONTEXT);
        }

        assertThat(TenantContextHolder.current()).isEmpty();
    }

    @Test
    void nestedScopeCannotSilentlyReplaceTrustedContext() {
        try (TenantContextHolder.Scope ignored = TenantContextHolder.open(CONTEXT)) {
            assertThatIllegalStateException()
                    .isThrownBy(() -> TenantContextHolder.open(CONTEXT))
                    .withMessageContaining("already bound");
        }
    }

    @Test
    void placementVersionMustBePositive() {
        assertThatIllegalArgumentException()
                .isThrownBy(() -> new TenantContext(
                        CONTEXT.accountId(),
                        CONTEXT.tenantId(),
                        CONTEXT.membershipId(),
                        CONTEXT.sessionId(),
                        0L))
                .withMessageContaining("placementVersion");
    }
}
