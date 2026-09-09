# 创界云枢 V2 SaaS Platform Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将现有单公司原型重建为默认共享、大客户可独立数据库、支持私有部署的多租户 SaaS 平台。

**Architecture:** 采用 Java 21 + Spring Boot 3.5 模块化单体，控制面管理全局身份、租户与路由，数据面通过共享 PostgreSQL、专属数据库和 Cell 平滑扩展。第三方系统、短信和企业消息经 integration-hub 适配，业务模块只接收标准命令与事件。

**Tech Stack:** Java 21、Spring Boot 3.5、MyBatis Plus、Flowable 7、PostgreSQL 16、Valkey、SeaweedFS、Vue 3、TypeScript、Vite、Pinia、Element Plus、Flyway、JUnit 5、Testcontainers、Docker Compose、Prometheus、Grafana。

---

## 执行原则

- 先完成 `R0`，再逐阶段细化 R1～R9；每阶段必须先产出专项设计并由用户评审。
- 当前目录不是 Git 仓库。任何删除前必须先建立 Git 基线或等价只读归档。
- 原始 `.docx` 永久保留；旧源码只有在删除清单获批且新骨架可构建后才能删除。
- 每个任务遵循：写失败测试 → 验证失败 → 最小实现 → 验证通过 → 更新文档和进度 → 提交。

### Task 1: 建立可恢复基线

**Files:**
- Preserve: `创界新后台完整系统项目架构.docx`
- Preserve: `创界新后台前后端项目规范.docx`
- Preserve: `创界AI科技中心项目进度表.docx`
- Create: `docs/rebuild/legacy-inventory.md`
- Create: `docs/rebuild/deletion-manifest.md`
- Create: `docs/rebuild/rollback.md`

**Step 1:** 使用 `rg --files` 生成旧源码、构建产物、日志、测试输出和配置清单，并逐项分类。

**Step 2:** 运行 `git status --short --branch`，预期当前提示非 Git 仓库；记录事实，不删除文件。

**Step 3:** 经用户授权后执行 `git init`，检查 `.gitignore`，提交原始基线；若不建 Git，则创建带 SHA-256 清单的只读归档。

**Step 4:** 在 `deletion-manifest.md` 中为每个目标记录绝对/相对路径、删除理由、替代物和恢复方式。

**Step 5:** 请用户评审删除清单。预期结果：明确批准前无删除操作。

**Step 6:** 提交：`docs(rebuild): inventory legacy implementation`。

### Task 2: 建立 V2 Maven 骨架

**Files:**
- Modify: `cj-platform-server/pom.xml`
- Modify: `cj-platform-server/cj-dependencies/pom.xml`
- Create: `cj-platform-server/cj-module-platform-control/pom.xml`
- Create: `cj-platform-server/cj-module-tenant-foundation/pom.xml`
- Create: `cj-platform-server/cj-module-integration-hub/pom.xml`
- Test: `cj-platform-server/cj-server/src/test/java/com/chuanjie/platform/ArchitectureTest.java`

**Step 1:** 编写 ArchUnit 测试，禁止业务模块依赖其他模块的 `biz`、`repository` 或 `mapper` 包。

**Step 2:** 运行 `mvn -pl cj-server -am test`，预期测试因模块边界尚未建立而失败。

**Step 3:** 建立目标模块与 `api`/`biz` 子模块，仅加入最小依赖和 `package-info.java`。

**Step 4:** 再次运行测试，预期架构测试和 Maven 构建通过。

**Step 5:** 提交：`build(server): establish v2 module boundaries`。

### Task 3: 建立 V2 前端骨架

**Files:**
- Modify: `cj-platform-web/pnpm-workspace.yaml`
- Modify: `cj-platform-web/package.json`
- Create: `cj-platform-web/packages/tenant-context/src/index.ts`
- Test: `cj-platform-web/packages/tenant-context/src/index.test.ts`

**Step 1:** 编写租户上下文测试，覆盖未选择租户、切换租户后清理旧权限缓存、请求携带新会话三种情况。

**Step 2:** 运行 `pnpm --filter tenant-context test`，预期因包不存在而失败。

**Step 3:** 创建最小租户上下文包，并约束页面不得直接创建 Axios 实例。

**Step 4:** 运行 `pnpm typecheck && pnpm build`，预期全部通过。

**Step 5:** 提交：`build(web): establish tenant-aware workspace`。

### Task 4: 建立租户数据模型与隔离测试

**Files:**
- Create: `cj-platform-server/cj-server/src/main/resources/db/migration/V1__v2_control_plane.sql`
- Create: `cj-platform-server/cj-server/src/main/resources/db/migration/V2__v2_tenant_foundation.sql`
- Create: `cj-platform-server/cj-server/src/test/java/com/chuanjie/platform/tenant/TenantIsolationIT.java`

**Step 1:** 在聚合应用模块使用 Testcontainers 编写跨租户读取、修改、唯一约束和 RLS 的失败测试；同时增加不依赖Docker的迁移契约测试，确保无Docker环境不会把跳过误报为通过。

**Step 2:** 运行对应测试，预期因表和策略不存在而失败。

**Step 3:** 创建全局账号、租户、成员、套餐、配额和数据库路由表；每个字段写 SQL `COMMENT`。部门、岗位、角色和业务授权属于R2，本任务禁止提前实现。

**Step 4:** 实现租户上下文、MyBatis过滤及 PostgreSQL RLS 会话设置。

**Step 5:** 运行测试，预期所有跨租户访问被拒绝，租户内访问通过。

**Step 6:** 提交：`feat(tenant): add control plane and dual isolation`。

### Task 5: 接入 OIDC 与租户切换

**Files:**
- Create: `cj-platform-server/cj-module-platform-control/cj-module-platform-control-biz/src/main/java/com/chuanjie/platform/control/identity/`
- Create: `cj-platform-server/cj-module-platform-control/cj-module-platform-control-biz/src/test/java/com/chuanjie/platform/control/identity/OidcLoginIT.java`
- Create: `cj-platform-web/packages/auth/src/oidc.ts`

**Step 1:** 编写 OIDC 回调、外部身份绑定、多租户成员列表和租户切换测试。

**Step 2:** 运行测试，预期因端点未实现而失败。

**Step 3:** 通过 Spring Security OIDC 标准协议实现认证映射，不引入 Casdoor 专有 SDK。

**Step 4:** 实现切换租户后重新签发会话，并拒绝用户未加入的租户。

**Step 5:** 运行后端集成测试和前端测试，预期通过。

**Step 6:** 提交：`feat(identity): add oidc login and tenant switching`。

### Task 6: 建立通知中心和短信通道 SPI

**Files:**
- Create: `cj-platform-server/cj-module-collaboration/cj-module-collaboration-api/src/main/java/com/chuanjie/platform/collaboration/api/notification/`
- Create: `cj-platform-server/cj-module-integration-hub/cj-module-integration-hub-api/src/main/java/com/chuanjie/platform/integration/api/message/MessageChannel.java`
- Test: `cj-platform-server/cj-module-collaboration/cj-module-collaboration-biz/src/test/java/com/chuanjie/platform/collaboration/notification/NotificationServiceTest.java`

**Step 1:** 编写站内信优先、短信回执、失败重试、租户自有通道和验证码限流测试。

**Step 2:** 运行测试，预期因通知服务与通道 SPI 不存在而失败。

**Step 3:** 实现通知命令、模板、发送记录、通道选择和厂商无关 SPI；只提供测试适配器，不写死商业供应商。

**Step 4:** 验证业务模块只能依赖通知 API，不能依赖厂商 SDK。

**Step 5:** 运行测试，预期通过。

**Step 6:** 提交：`feat(notification): add multichannel notification core`。

### Task 7: 建立第三方集成框架与聚水潭适配器

**Files:**
- Create: `cj-platform-server/cj-module-integration-hub/cj-module-integration-hub-biz/src/main/java/com/chuanjie/platform/integration/core/`
- Create: `cj-platform-server/cj-module-integration-hub/cj-module-integration-hub-biz/src/main/java/com/chuanjie/platform/integration/jushuitan/`
- Test: `cj-platform-server/cj-module-integration-hub/cj-module-integration-hub-biz/src/test/java/com/chuanjie/platform/integration/jushuitan/JushuitanSyncIT.java`

**Step 1:** 使用 MockWebServer 编写签名、限流、分页、增量游标、幂等、重试、断点续传和对账测试；测试凭据只能使用假值。

**Step 2:** 运行测试，预期因适配器不存在而失败。

**Step 3:** 实现凭据保险箱接口、Connector SPI、Inbox/Outbox、映射表、同步任务和失败重放。

**Step 4:** 实现聚水潭商品/SKU、订单、库存和售后的标准化适配器，禁止直接写业务表。

**Step 5:** 运行集成测试，预期重复消息不重复入账、失败可从游标恢复。

**Step 6:** 提交：`feat(integration): add jushuitan synchronization`。

### Task 8: 建立本地部署与可观测性

**Files:**
- Modify: `docker-compose.yml`
- Modify: `cj-platform-server/cj-server/src/main/resources/application.yml`
- Create: `deploy/prometheus/prometheus.yml`
- Create: `deploy/grafana/provisioning/`
- Create: `docs/runbooks/backup-restore.md`
- Create: `docs/runbooks/integration-failure.md`

**Step 1:** 编写 Compose 健康检查脚本，覆盖 PostgreSQL、Valkey、SeaweedFS、应用和监控端点。

**Step 2:** 将本地基础组件切换为 PostgreSQL 16、Valkey和SeaweedFS；每项配置写明用途、默认值与切换场景。

**Step 3:** 增加请求延迟、错误率、连接池、同步积压、短信失败和备份结果指标。

**Step 4:** 运行 `docker compose config` 和健康检查，预期配置有效且全部服务健康。

**Step 5:** 执行一次备份恢复演练并记录耗时、数据校验和及未达标项。

**Step 6:** 提交：`ops: add v2 local stack and recovery runbooks`。

### Task 9: 执行受控旧代码清理

**Files:**
- Modify: `docs/rebuild/deletion-manifest.md`
- Modify: `.cursor/skills/chuanjie-platform/progress.md`

**Step 1:** 确认 Task 1 基线可恢复、Task 2/3 新骨架可构建、删除清单已由用户批准。

**Step 2:** 先删除清单中的构建产物、日志和临时 JSON，运行全量构建。

**Step 3:** 按模块小批量删除被替代的旧源码，每批删除后运行后端测试、前端测试、类型检查和构建。

**Step 4:** 若任何验证失败，按 `rollback.md` 恢复该批次，禁止继续扩大删除范围。

**Step 5:** 更新进度、实际删除内容、恢复点及遗留项。

**Step 6:** 提交：`refactor: remove superseded v1 implementation`。

## R1 之后的规划方式

R2～R9 在进入开发前分别创建 `docs/plans/YYYY-MM-DD-rN-*.md`，写出精确表结构、接口、状态机、测试和迁移步骤。不得用本总计划替代专项评审。
