package com.chuanjie.platform.tenant;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;

class ControlPlaneMigrationContractTest {

    @Test
    void migrationsDeclareTheApprovedR1TablesAndTenantContextFunction() throws IOException {
        String controlPlane = readMigration("db/migration/V1__v2_control_plane.sql");
        String tenantRuntime = readMigration("db/migration/V2__v2_tenant_foundation.sql");

        assertThat(controlPlane)
                .contains("CREATE TABLE cp_account")
                .contains("CREATE TABLE cp_tenant")
                .contains("CREATE TABLE cp_tenant_member")
                .contains("CREATE TABLE cp_plan")
                .contains("CREATE TABLE cp_tenant_quota")
                .contains("CREATE TABLE cp_data_placement")
                .contains("COMMENT ON TABLE")
                .contains("COMMENT ON COLUMN");
        assertThat(tenantRuntime)
                .contains("CREATE SCHEMA tenant_runtime")
                .contains("tenant_runtime.current_tenant_id")
                .contains("current_setting('app.current_tenant_id', true)");
    }

    private String readMigration(String resourceName) throws IOException {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream(resourceName)) {
            assertThat(input).as("migration resource %s", resourceName).isNotNull();
            return new String(input.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}
