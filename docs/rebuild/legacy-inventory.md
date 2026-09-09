# V1 旧实现盘点

> 盘点日期：2026-09-09  
> 盘点目的：为 V2 多租户 SaaS 重建建立可恢复、可审查的旧实现清单。本文不构成删除授权。

## 1. 仓库状态

- 工作目录：`D:\code\chuanjie`
- 初始状态：没有 Git 仓库。
- 已执行：本地 `git init`，分支为 `main`，未创建 GitHub 仓库、未配置远程地址、未上传文件。
- 删除前恢复基线：`30a85e1 chore: establish v1 recovery baseline`。
- 当前限制：目录所有者与沙箱用户不同，Git 命令使用单次 `safe.directory` 参数，不修改全局 Git 安全设置。

## 2. 必须永久保留的业务资料

| 文件 | SHA-256 |
|---|---|
| `创界新后台前后端项目规范.docx` | `6BFA1D33BF5E801B173F326A67A5B0EEC10F0AD617CD980F3CA36F6FDD743BD0` |
| `创界新后台完整系统项目架构.docx` | `4D3E50E817A9F1CC1BF99AEB918427DD489E26F50DD86E40C8F3B3F11CEF001A` |
| `创界AI科技中心项目进度表.docx` | `93CF5EA6B06561BCA8225CFC46609FC0BD9F0BADF1457EC7767EF3CCF3C2B96D` |

V2 架构和重建文档同样永久保留：

- `.cursor/skills/chuanjie-platform/architecture-v2-saas.md`
- `.cursor/skills/chuanjie-platform/v2-rebuild.md`
- `docs/plans/2026-09-09-saas-platform-rebuild.md`

## 3. 有效源码规模

统计已排除 `.git`、`target`、`node_modules` 和 `dist`。

| 类型 | 数量 | 说明 |
|---|---:|---|
| Java | 63 | V1 后端业务与框架代码 |
| Vue | 10 | 登录、工作台、系统管理等页面 |
| TypeScript | 17 | 前端入口、路由、API与共享包 |
| SQL | 3 | V1～V3 Flyway 脚本 |
| Maven POM | 31 | V1 模块树及父依赖 |
| Markdown | 33 | 项目说明、skill与模块占位文档 |

## 4. V1 后端模块

| 路径 | 当前处理 | V2 去向 |
|---|---|---|
| `cj-platform-server/cj-framework` | 保留参考 | 重建为租户感知公共框架 |
| `cj-platform-server/cj-server` | 保留参考 | 重建启动器、配置与 V2 Flyway 基线 |
| `cj-platform-server/cj-module-platform` | 待迁移 | 拆为 `platform-control` 与 `tenant-foundation` |
| `cj-platform-server/cj-module-collaboration` | 待迁移 | 增加通知中心，不允许直接调用厂商 SDK |
| `cj-platform-server/cj-module-project` | 保留需求参考 | V2 R4 重建 |
| `cj-platform-server/cj-module-product` | 保留需求参考 | 合并到 V2 `product-supply` 边界 |
| `cj-platform-server/cj-module-supply-chain` | 保留需求参考 | 合并到 V2 `product-supply` 边界 |
| `cj-platform-server/cj-module-finance` | 保留需求参考 | V2 R6 重建 |
| `cj-platform-server/cj-module-analytics-ai` | 保留需求参考 | V2 R8 重建 |
| `cj-platform-server/cj-module-oa-hr` | 保留需求参考 | 在 R3 后专项拆解 |
| `cj-platform-server/cj-module-operation-creative` | 保留需求参考 | 在项目/商品阶段重新定边界 |

## 5. V1 前端

| 路径 | 当前处理 | V2 去向 |
|---|---|---|
| `cj-platform-web/apps/admin-web` | 保留视觉与交互参考 | 增加租户选择、租户上下文和新信息架构 |
| `cj-platform-web/apps/entrepreneur-web` | 保留占位 | R4 后重建 |
| `cj-platform-web/apps/supplier-web` | 保留占位 | R5/R6 后重建 |
| `cj-platform-web/apps/mobile` | 保留占位 | R3 后重建 |
| `cj-platform-web/packages/*` | 逐包评估 | 保留通用包，新增 `tenant-context` |

## 6. 可再生成内容

| 类别 | 目录数 | 文件数 | 大小 | 结论 |
|---|---:|---:|---:|---|
| Maven `target` | 20 | 154 | 51,917,818 B | 可删除，运行 Maven 可恢复 |
| pnpm `node_modules` | 10 个顶层链接/目录 | 12,621 | 133,126,515 B | 可删除，`pnpm install --frozen-lockfile` 可恢复 |
| Vite `dist` | 1 | 3 | 1,489,630 B | 可删除，`pnpm build` 可恢复 |
| IDEA `.idea` | 2 | 11 | 18,090 B | 本地 IDE 状态，不纳入基线 |

## 7. 松散临时文件

位于 `cj-platform-server/`：

- `Gen.class`
- `server-run.log`
- `server-run.err`
- `login-in.json`
- `login-out.json`
- `users-out.json`
- `users-dis.json`
- `openapi-check.json`

这些文件属于编译、运行或接口验证输出，不是权威业务资料；列入第一批删除候选。

## 8. 结论

旧源码规模适合受控重建，无需整体一次性删除。R0应先提交当前可追溯基线，再清理可再生成内容；业务源码仅在对应 V2 模块具备测试和可运行替代物后分批删除。
