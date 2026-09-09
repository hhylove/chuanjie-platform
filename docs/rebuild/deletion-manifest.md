# V1 删除清单与审批记录

> 状态：V1 前后端源码已清理完成
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

## 第二批：V1 前后端源码整体清理

用户于 2026-09-09 明确决定全新重写，并明确授权清理现有前后端源码。恢复基线 `30a85e1` 已完整保存后端 108 个受版本控制文件和前端 70 个受版本控制文件。

本批精确目标仅为：

- `D:\code\chuanjie\cj-platform-server`
- `D:\code\chuanjie\cj-platform-web`

删除前停止占用后端日志的旧版 `PlatformServerApplication` 进程 `20212`。本批不包括根目录 `docs`、`.cursor`、三个 `.docx`、`.git`、`docker-compose.yml`、`README.md` 或其他目录。

以下旧版细项随上述目录整体进入 Git 历史，不再要求 V2 替代物先落地：

| V1 目标 | 删除前置条件 | 恢复方法 |
|---|---|---|
| V1 `cj-module-platform` 身份与 JWT 实现 | R1 OIDC、全局账号、租户成员和租户切换集成测试通过 | Git 基线恢复 |
| V1 Flyway `V1__baseline.sql`～`V3__platform_test_seed.sql` | V2 新库迁移与数据迁移方案评审通过 | Git 基线恢复；旧数据库只读备份 |
| V1 系统管理页面 | V2 租户组织权限页面通过验收 | Git 基线恢复 |
| 旧 Redis/MinIO 配置 | Valkey/SeaweedFS Compose 健康检查及迁移说明通过 | Git 基线恢复 |
| 旧模块占位源码/POM | 对应 V2 模块骨架可构建且 ArchUnit 测试通过 | Git 基线恢复 |

V2将创建全新的同名工程目录，不复制旧业务源码、页面、数据库脚本和配置。后续如需查询旧实现，只从恢复提交读取，不直接还原进新工程。

执行结果：用户自行完成被进程占用的剩余前端目录清理。2026-09-09复核确认 `cj-platform-server` 与 `cj-platform-web` 均已不存在；三份原始需求文档、V2文档和本地Git历史仍在工作区中。

## 永不删除

- 三个原始 `.docx` 业务资料。
- V2 架构、重建骨架、实施计划、ADR、迁移记录和进度日志。
- 尚未确认已迁移的用户业务数据、数据库备份和第三方凭据。

## 审批记录

| 日期 | 批次 | 决策 | 说明 |
|---|---|---|---|
| 2026-09-09 | 第一批 | 已批准 | 仅可再生成内容和本地临时输出；执行结果见下节 |
| 2026-09-09 | 第二批 | 已批准 | 全新重写；清理现有前后端源码目录，旧代码仅保留在Git历史 |

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
