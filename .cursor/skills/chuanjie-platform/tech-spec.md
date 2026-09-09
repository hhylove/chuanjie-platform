# 前后端工程规范摘要

源文档：`创界新后台前后端项目规范.docx`（V1.0）

## 总体原则

- 新前端重做信息架构与交互，不复制旧页  
- 后端模块化单体起步，业务域代码与数据边界清晰  
- 主数据唯一权威来源（项目/商品/店铺/供应商/仓库/组织）  
- 审批状态 ≠ 业务状态；金额、库存、权限、状态变化由后端最终校验  
- 关键变化可追溯；正式数据用关闭 / 作废 / 归档  
- **接口、字段、SQL 必须注释**；无注释不得入库  
- **先拆解并写入进度表，再开发**；每次开发更新进度  

## 仓库与技术

| 仓库 | 职责 |
|------|------|
| `cj-platform-web` | admin / entrepreneur / supplier / mobile + 共享包 |
| `cj-platform-server` | 业务、流程、集成、任务、AI |

前端：Vue 3、TS、Vite、Pinia、Element Plus；pnpm workspace  
后端：Java 21、Spring Boot 3.5、MyBatis Plus、Flowable 7  
存储：PostgreSQL、Redis、MinIO  

## 前端要点

- 业务按 `modules/<domain>` 组织；两端以上复用才进 packages  
- 分层：Page → Feature → 公共业务组件 → 设计系统  
- Vue 单文件原则上 ≤500 行，>800 必须拆分  
- 禁止页面直调 Axios；经 `api-client` / 模块 api  
- 禁止 `any` 承接正式接口；金额不用 JS 浮点做最终核算  
- Pinia 只放跨页共享状态；权限前端只控展示  
- 项目内页面必须有明确 `projectId` 上下文  
- **可用性**：业务页禁止暴露数据库 ID 让用户手填；关联选名称（下拉/树选）；文案用人话（详见 skill「前端可用性」）  

命名：组件 PascalCase；页面目录 kebab-case；composable `use*`；事件 `handle*`  

## 后端要点

- 模块建议对齐架构：`platform` / `collaboration` / `oa-hr` / `project` / `product` / `operation-creative` / `supply-chain` / `finance` / `analytics-ai`（实现名可用 `cj-module-*`）  
- 每模块含 `-api` 与 `-biz`；禁止把项目/商品/财务堆进 platform  
- 依赖：Controller → Service → Domain → Repository → Mapper  
- 跨模块只依赖对方 api；禁止直改他域表  
- 轻量查询 Facade；重要状态变化用领域事件；关键事件 Outbox + 幂等  
- API：`/admin-api/v1/...`、`/entrepreneur-api/v1/...`、`/supplier-api/v1/...`  
- 响应：`{ code, data, message, requestId }`  
- **接口文档：springdoc-openapi（OpenAPI 3 + Swagger UI）**；本地默认开启，见 `/swagger-ui.html` 与 `/v3/api-docs`；受保护接口在 UI 用 Bearer JWT  
- 表名域前缀 + snake_case；金额 `decimal` / `BigDecimal`  
- 公共字段：creator、create_time、updater、update_time、deleted、version  
- 经营数据原则上必须有 `project_id`  
- 审批/任务走统一 collaboration，各中心不自建零散审批引擎

## 注释要求（强制）

| 对象 | 必须说明 |
|------|----------|
| 对外接口 | 用途、关键参数、返回含义 |
| ReqVO/RespVO/DTO/字段 | 业务含义、单位/币种、必填、约束 |
| 前端类型/枚举/Store/props | 与后端口径一致 |
| 建表/改表 SQL | 表字段 `COMMENT`、变更原因 |
| 复杂查询/批处理 | 目的、关联、注意事项 |
| **配置文件** | **每项配置说明干什么用**（见下） |

### 配置注释细则

适用于 `application*.yml`、`.env*`、`docker-compose.yml`、Vite/代理配置等：

- 数据源 URL / 用户名 / 库名：连哪套库、哪个环境  
- Redis / MinIO：用途（缓存/会话/对象存储）、端口含义  
- Flyway：是否启用、脚本目录、baseline 含义  
- profile（`local` / `nodocker` 等）：适用场景与差异  
- 端口、代理、apiBaseUrl：给谁用、何时改  
- 禁止提交无注释的「神秘配置」；密钥可用注释说明来源（环境变量名），勿把生产密钥写进库  

## 状态与一致性

- 状态变更在领域服务校验；Controller 不直接改状态  
- 记录操作人、时间、原因、前后状态  
- 单模块本地事务；跨模块事件 + 补偿；事务中不调第三方 HTTP  
- 库存/预算/付款写操作必须幂等  

## Git / CI 摘要

分支：`main` / `develop` / `feature|fix|release|hotfix/*`  
提交：`feat(product): ...` 等约定式  
合并须说明影响、迁移、回滚；过评审与质量门禁  

## 强制清单（摘录）

1. 新业务按域组织，不堆 system  
2. 主数据不重复保存可关联数据  
3. 跨模块只走公开接口或事件  
4. 正式数据不物理删除  
5. 首期模块化单体，条件成熟再拆微服务  
6. AI 不绕过权限与业务规则  
7. 无注释 / 无进度更新不得合并（含配置项注释）  
