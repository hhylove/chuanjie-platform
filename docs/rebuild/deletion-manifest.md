# V1 删除清单与审批记录

> 状态：第一批已批准并部分完成
> 原则：本文获得用户明确批准前，不执行任何删除。

## 第一批：可立即清理的可再生成内容

| 目标 | 理由 | 替代/恢复方法 | 风险 |
|---|---|---|---|
| `cj-platform-server/**/target/` | Maven 编译产物，约 49.5 MiB | `mvn test` 或 `mvn package` | 低 |
| `cj-platform-web/**/node_modules/` | pnpm 依赖，约 127 MiB | `pnpm install --frozen-lockfile` | 低；恢复需要依赖源可访问 |
| `cj-platform-web/apps/admin-web/dist/` | Vite 构建产物，约 1.4 MiB | `pnpm build` | 低 |
| 根目录及子工程 `.idea/` | 本机 IDE 状态 | IDE 重新导入项目 | 低；可能丢失个人运行配置 |
| `cj-platform-server/Gen.class` | 松散编译输出 | 从源码重新编译 | 低 |
| `cj-platform-server/server-run.log` | 本地运行日志 | 无需恢复 | 低 |
| `cj-platform-server/server-run.err` | 本地运行错误输出 | 无需恢复 | 低 |
| `cj-platform-server/login-*.json` | 本地登录接口验证输出 | 重新调用测试接口 | 低 |
| `cj-platform-server/users-*.json` | 本地用户接口验证输出 | 重新调用测试接口 | 低 |
| `cj-platform-server/openapi-check.json` | 本地 OpenAPI 验证输出 | 重新访问 `/v3/api-docs` | 低 |

第一批删除后必须执行：

1. `mvn -f cj-platform-server/pom.xml test`
2. `pnpm --dir cj-platform-web install --frozen-lockfile`
3. `pnpm --dir cj-platform-web typecheck`
4. `pnpm --dir cj-platform-web build`

若依赖源不可访问，先保留 `node_modules`，不得为了清理而破坏当前可运行环境。

## 第二批：只能在 V2 替代物就绪后清理

| V1 目标 | 删除前置条件 | 恢复方法 |
|---|---|---|
| V1 `cj-module-platform` 身份与 JWT 实现 | R1 OIDC、全局账号、租户成员和租户切换集成测试通过 | Git 基线恢复 |
| V1 Flyway `V1__baseline.sql`～`V3__platform_test_seed.sql` | V2 新库迁移与数据迁移方案评审通过 | Git 基线恢复；旧数据库只读备份 |
| V1 系统管理页面 | V2 租户组织权限页面通过验收 | Git 基线恢复 |
| 旧 Redis/MinIO 配置 | Valkey/SeaweedFS Compose 健康检查及迁移说明通过 | Git 基线恢复 |
| 旧模块占位源码/POM | 对应 V2 模块骨架可构建且 ArchUnit 测试通过 | Git 基线恢复 |

第二批不在本次评审中授权执行；每个 V2 阶段结束时另行形成精确到文件的清单。

## 永不删除

- 三个原始 `.docx` 业务资料。
- V2 架构、重建骨架、实施计划、ADR、迁移记录和进度日志。
- 尚未确认已迁移的用户业务数据、数据库备份和第三方凭据。

## 审批记录

| 日期 | 批次 | 决策 | 说明 |
|---|---|---|---|
| 2026-09-09 | 第一批 | 已批准 | 仅可再生成内容和本地临时输出；执行结果见下节 |
| 2026-09-09 | 第二批 | 未授权 | 等对应 V2 替代物就绪后逐阶段评审 |

## 第一批执行结果

用户于 2026-09-09 明确批准第一批清理。

| 项目 | 结果 | 说明 |
|---|---|---|
| 前端 `node_modules` | 已清理并重建 | pnpm重新创建依赖；类型检查和生产构建通过 |
| 前端 `dist` | 已删除 | 构建验证后再次删除，随时可重新生成 |
| `.idea` | 已删除 | 根目录和后端子工程IDE缓存均已清理 |
| 接口验证 JSON、`Gen.class` | 已删除 | 已有 Git 恢复基线 `30a85e1` |
| `server-run.log`、`server-run.err` | 暂缓 | Java进程 `20212` 正在占用；未擅自停止运行服务 |
| Maven `target` | 暂缓 | 当前环境找不到 `mvn`，无法完成删除后的后端测试门禁 |

三份原始需求文档 SHA-256 与清理前完全一致；有效业务源码仍为 63 个 Java 文件、10 个 Vue 文件。
