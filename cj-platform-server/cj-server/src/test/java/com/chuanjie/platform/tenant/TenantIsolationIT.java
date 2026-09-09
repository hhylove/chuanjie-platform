package com.chuanjie.platform.tenant;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.UUID;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers(disabledWithoutDocker = true)
class TenantIsolationIT {

    private static final UUID TENANT_A = UUID.fromString("01993270-0000-7000-8000-000000000001");
    private static final UUID TENANT_B = UUID.fromString("01993270-0000-7000-8000-000000000002");

    @Container
    private static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("chuanjie")
            .withUsername("migration_owner")
            .withPassword("migration-test-only");

    @BeforeAll
    static void migrateAndCreateTenantFixture() throws SQLException {
        Flyway.configure()
                .dataSource(POSTGRES.getJdbcUrl(), POSTGRES.getUsername(), POSTGRES.getPassword())
                .load()
                .migrate();

        try (Connection connection = adminConnection(); Statement statement = connection.createStatement()) {
            statement.execute("CREATE ROLE tenant_app LOGIN PASSWORD 'tenant-test-only' NOSUPERUSER NOBYPASSRLS");
            statement.execute("""
                    CREATE TABLE tenant_isolation_fixture (
                        id uuid PRIMARY KEY,
                        tenant_id uuid NOT NULL,
                        external_key varchar(64) NOT NULL,
                        payload varchar(255) NOT NULL,
                        CONSTRAINT uk_tenant_fixture_key UNIQUE (tenant_id, external_key)
                    )
                    """);
            statement.execute("ALTER TABLE tenant_isolation_fixture ENABLE ROW LEVEL SECURITY");
            statement.execute("ALTER TABLE tenant_isolation_fixture FORCE ROW LEVEL SECURITY");
            statement.execute("""
                    CREATE POLICY tenant_fixture_isolation ON tenant_isolation_fixture
                    USING (tenant_id = tenant_runtime.current_tenant_id())
                    WITH CHECK (tenant_id = tenant_runtime.current_tenant_id())
                    """);
            statement.execute("GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_isolation_fixture TO tenant_app");
            statement.execute("INSERT INTO tenant_isolation_fixture VALUES "
                    + "('01993270-1000-7000-8000-000000000001', '" + TENANT_A + "', 'same-key', 'A'), "
                    + "('01993270-1000-7000-8000-000000000002', '" + TENANT_B + "', 'same-key', 'B')");
        }
    }

    @Test
    void tenantCanReadAndUpdateOnlyItsOwnRows() throws SQLException {
        try (Connection connection = tenantConnection()) {
            connection.setAutoCommit(false);
            selectTenant(connection, TENANT_A);

            assertThat(countRows(connection)).isEqualTo(1);
            assertThat(updateTenantB(connection)).isZero();
            connection.commit();
        }
    }

    @Test
    void missingTenantContextFailsClosed() throws SQLException {
        try (Connection connection = tenantConnection()) {
            assertThat(countRows(connection)).isZero();
        }
    }

    @Test
    void uniquenessIsScopedToTenant() throws SQLException {
        try (Connection connection = tenantConnection()) {
            connection.setAutoCommit(false);
            selectTenant(connection, TENANT_A);

            assertThatThrownBy(() -> insertDuplicateKey(connection))
                    .isInstanceOf(SQLException.class)
                    .hasMessageContaining("uk_tenant_fixture_key");
        }
    }

    private static Connection adminConnection() throws SQLException {
        return DriverManager.getConnection(POSTGRES.getJdbcUrl(), POSTGRES.getUsername(), POSTGRES.getPassword());
    }

    private static Connection tenantConnection() throws SQLException {
        return DriverManager.getConnection(POSTGRES.getJdbcUrl(), "tenant_app", "tenant-test-only");
    }

    private static void selectTenant(Connection connection, UUID tenantId) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT set_config('app.current_tenant_id', ?, true)")) {
            statement.setString(1, tenantId.toString());
            statement.execute();
        }
    }

    private static int countRows(Connection connection) throws SQLException {
        try (Statement statement = connection.createStatement();
                ResultSet result = statement.executeQuery("SELECT count(*) FROM tenant_isolation_fixture")) {
            result.next();
            return result.getInt(1);
        }
    }

    private static int updateTenantB(Connection connection) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "UPDATE tenant_isolation_fixture SET payload = 'blocked' WHERE tenant_id = ?")) {
            statement.setObject(1, TENANT_B);
            return statement.executeUpdate();
        }
    }

    private static void insertDuplicateKey(Connection connection) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO tenant_isolation_fixture (id, tenant_id, external_key, payload) VALUES (?, ?, ?, ?)")) {
            statement.setObject(1, UUID.randomUUID());
            statement.setObject(2, TENANT_A);
            statement.setString(3, "same-key");
            statement.setString(4, "duplicate");
            statement.executeUpdate();
        }
    }
}
