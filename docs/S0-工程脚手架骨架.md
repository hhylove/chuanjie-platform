# S0 工程脚手架骨架文档

| 项 | 内容 |
|----|------|
| 编号 | S0 |
| 状态 | 联调中（骨架已落地） |
| 对齐 | 《完整系统项目架构》《前后端项目规范》 |
| 目标 | 前后端可本地启动、健康检查互通、模块边界落盘；**不含业务功能** |

评审通过后方可按本骨架建仓编码。

> **Skill 硬性规则：** 本文件属于 S0 在 skill 内的开工文档。未写入 skill / 未写明白 / 未评审通过 → **禁止开始 S0 开发**。S1～S5 同理，须先有对应 `s*-*.md`。

---

## 1. 范围与非目标

### 1.1 范围内（Must）

- 初始化两个工程：`cj-platform-server`、`cj-platform-web`
- 后端：Maven 多模块 + Spring Boot 3.5 可启动；Actuator health
- 统一响应体、错误码骨架、requestId
- DB 迁移工具就绪（推荐 Flyway）；至少 1 条基线迁移（可空库可执行）
- 前端：pnpm workspace；`admin-web` 可 build；`api-client` 可调 health
- `docker-compose`：PostgreSQL、Redis、MinIO
- README：启动步骤、端口、环境变量
- 目录与模块名按架构预留，空壳即可（不写业务逻辑）

### 1.2 非目标（Must Not）

- 真实登录/鉴权完善、RBAC 业务实现
- Flowable 流程定义与审批业务
- 任一中心业务页（项目/商品/财务等）
- 创业者端 / 供应商端 / 移动端完整应用（可只建空 apps 目录占位）
- 微服务拆分、K8s、完整 CI（可留 `.github` 或脚本占位）

---

## 2. 仓库与目录总览

建议 monorepo 根目录（当前 `chuanjie`）结构：

```text
chuanjie/
├── docs/                          # 可选：对外可读文档副本
├── .cursor/skills/chuanjie-platform/
├── cj-platform-server/            # 后端
├── cj-platform-web/               # 前端
├── docker-compose.yml             # 本地中间件
└── README.md
```

也可 server / web 分仓；S0 按**同仓双子工程**描述，分仓时目录不变、仅根 README 改为两仓说明。

---

## 3. 后端骨架：`cj-platform-server`

### 3.1 技术版本

| 项 | 版本/选型 |
|----|-----------|
| JDK | 21 |
| Spring Boot | 3.5.x |
| 构建 | Maven（多模块） |
| ORM | MyBatis Plus |
| DB | PostgreSQL 16+ |
| 缓存 | Redis（S0 只接上，可不使用） |
| 对象存储 | MinIO（S0 只接配置，可不调用） |
| 迁移 | Flyway |
| 监控 | Spring Actuator |
| 流程 | Flowable 依赖可引入，**S0 不配流程定义** |

### 3.2 Maven 模块树

```text
cj-platform-server/
├── pom.xml                          # 父 POM：依赖版本、插件
├── cj-dependencies/                 # BOM（可选，推荐）
├── cj-framework/                    # 公共：响应体、错误码、异常处理、工具
├── cj-server/                       # 启动模块：Application、配置、组装各 biz
├── cj-module-platform/
│   ├── cj-module-platform-api/      # 枚举、DTO、Facade、Event（S0 空包+说明）
│   └── cj-module-platform-biz/      # 空壳；S1 再实现用户组织权限
├── cj-module-collaboration/
│   ├── cj-module-collaboration-api/
│   └── cj-module-collaboration-biz/
├── cj-module-oa-hr/
│   ├── cj-module-oa-hr-api/
│   └── cj-module-oa-hr-biz/
├── cj-module-project/
│   ├── cj-module-project-api/
│   └── cj-module-project-biz/
├── cj-module-product/
│   ├── cj-module-product-api/
│   └── cj-module-product-biz/
├── cj-module-operation-creative/
│   ├── ...-api/ + ...-biz/
├── cj-module-supply-chain/
│   ├── ...-api/ + ...-biz/
├── cj-module-finance/
│   ├── ...-api/ + ...-biz/
└── cj-module-analytics-ai/
    ├── ...-api/ + ...-biz/
```

**依赖规则（S0 起强制）：**

- `cj-server` 依赖各 `*-biz`
- `*-biz` 只依赖本模块 `*-api` + `cj-framework` + 其他模块的 `*-api`
- **禁止** `*-biz` 依赖其他模块的 `*-biz` / Mapper / DO
- 业务代码不得堆进 `platform`（S1 仅放身份与组织权限）

### 3.3 启动模块包结构（示例）

```text
cj-server/src/main/java/com/chuanjie/platform/
├── PlatformServerApplication.java
└── config/                          # 数据源、Redis、Jackson、WebMvc 等

cj-server/src/main/resources/
├── application.yml
├── application-local.yml
└── db/migration/
    └── V1__baseline.sql             # 基线；可仅含注释说明，或 schema_version 友好空脚本
```

### 3.4 `cj-framework` S0 必交付

| 能力 | 说明 |
|------|------|
| 统一响应 | `{ code, data, message, requestId }`；成功 `code=0` |
| 全局异常 | 业务异常 / 校验异常 / 未知异常；message 说明原因 |
| requestId | Filter/Interceptor 注入 MDC 与响应 |
| 错误码段 | 预留：100xxx platform … 900xxx analytics-ai（常量类+注释） |
| 基础注解/工具 | 按需；禁止塞业务 |

### 3.5 S0 示例接口（仅脚手架验证）

```text
GET /actuator/health
GET /admin-api/v1/system/ping
```

`ping` 返回统一响应体；Controller 写清 JavaDoc（用途/返回）。**不是业务接口。**

### 3.6 配置约定（local）

| 配置项 | 示例 |
|--------|------|
| HTTP | `8080` |
| PostgreSQL | `localhost:5432/cj_platform` |
| Redis | `localhost:6379` |
| MinIO | `localhost:9000` |
| 上下文 | 无 context-path，或统一 `/`；API 前缀写在 Controller |

密钥不进库：用 `application-local.yml`（gitignore）或环境变量。

### 3.7 后端验收命令

```bash
cd cj-platform-server
mvn -q -DskipTests package
mvn -pl cj-server spring-boot:run
curl -s http://localhost:8080/actuator/health
curl -s http://localhost:8080/admin-api/v1/system/ping
```

---

## 4. 前端骨架：`cj-platform-web`

### 4.1 技术版本

| 项 | 选型 |
|----|------|
| 包管理 | pnpm workspace |
| 框架 | Vue 3 + TypeScript + Vite |
| 状态 | Pinia |
| 路由 | Vue Router |
| UI | Element Plus |
| 质量 | ESLint + vue-tsc +（可选）Vitest |

### 4.2 Workspace 树

```text
cj-platform-web/
├── package.json
├── pnpm-workspace.yaml
├── turbo.json / nx（可选，S0 不强制）
├── apps/
│   ├── admin-web/                   # S0 必须可跑
│   ├── entrepreneur-web/            # S0 可空壳占位
│   ├── supplier-web/                # S0 可空壳占位
│   └── mobile/                      # S0 可空壳或仅 README 占位
├── packages/
│   ├── api-client/                  # S0 必须：Axios 封装 + ping/health
│   ├── shared-types/
│   ├── shared-utils/
│   ├── auth/                        # S0 占位：token 读写接口，不做真实登录
│   ├── design-system/               # S0 可最小导出 Button 占位
│   ├── business-components/         # S0 空包
│   ├── constants/
│   └── configuration/               # 环境变量类型与默认值
└── tooling/                         # eslint-config / tsconfig 基座
```

### 4.3 `admin-web` 源码骨架

```text
apps/admin-web/src/
├── main.ts
├── App.vue
├── assets/
├── layouts/                         # 空白布局壳
├── router/
│   └── index.ts                     # 仅首页/健康检查页
├── stores/
├── styles/
├── composables/
└── modules/
    ├── workbench/                   # 空 modules 占位目录
    ├── oa/
    ├── hr/
    ├── training/
    ├── project/
    ├── product/
    ├── operation/
    ├── creative/
    ├── procurement/
    ├── supplier/
    ├── warehouse/
    ├── finance/
    └── analytics/
```

每个 `modules/*` S0 只需 `README.md` 一行说明归属阶段即可，**不建业务页**。

### 4.4 `api-client` S0 必交付

- 统一 baseURL、超时、requestId 头、错误解析
- **禁止**页面直调 Axios
- 提供 `getHealth()` / `getPing()`，类型明确，禁止 `any`
- 与后端响应类型一致：

```ts
/** 统一 API 响应 */
export interface ApiResponse<T> {
  /** 0 成功，非 0 失败 */
  code: number
  data: T
  message: string
  requestId: string
}
```

### 4.5 前端验收命令

```bash
cd cj-platform-web
pnpm install
pnpm lint
pnpm typecheck
pnpm --filter admin-web build
pnpm --filter admin-web dev
# 页面或控制台调用 ping，看到 code=0
```

---

## 5. Docker Compose（根目录）

```text
services:
  postgres:  # 5432, 库名 cj_platform, 用户/密码 local 文档说明
  redis:     # 6379
  minio:     # 9000 / 9001 console
```

验收：`docker compose up -d` 后后端 `local` 配置可连 Postgres。

---

## 6. 工程约定落盘（S0 写入仓库）

| 文件 | 内容 |
|------|------|
| 根 `README.md` | 如何起中间件、后端、前端；端口表 |
| `cj-platform-server/README.md` | 模块说明、依赖规则、迁移命令 |
| `cj-platform-web/README.md` | workspace 脚本、apps 职责 |
| `.gitignore` | node_modules、target、.env、local yml、IDE |
| `.editorconfig` | 缩进与 charset |
| 分支说明 | main / develop；S0 在 `feature/s0-scaffold` 开发 |

提交信息示例：`chore(s0): init platform server and web scaffold`

---

## 7. 子任务拆解与验收（对照 progress）

| ID | 交付物 | 验收标准 |
|----|--------|----------|
| S0-1 | 后端多模块空壳 + 启动 | `mvn package` 成功；进程可起；health UP |
| S0-2 | Flyway + 统一响应 + ping | 空库迁移成功；ping 符合响应约定；错误码类有注释 |
| S0-3 | pnpm workspace + admin-web | lint、typecheck、build 通过；空白首页可开 |
| S0-4 | api-client ↔ ping/health | admin-web 经 api-client 调用成功，类型完整 |
| S0-5 | docker-compose | 三件套健康；后端连上 Postgres |

**全部通过 = S0 完成**，方可进入 S1 拆解开发。

---

## 8. 注释与门禁（S0 也适用）

- `ping` 等对外接口必须有注释  
- 迁移脚本写明用途（基线）  
- **数据库及其它配置**（`application*.yml`、docker-compose、前端 `.env` / Vite 代理）每项须注释说明干什么用  
- 空模块 `package-info.java` 或 README 说明职责与禁止事项  
- 合并前更新 [progress.md](progress.md) 日志  

---

## 9. 评审检查清单

- [ ] 模块树与架构九大域一致，无「大 system 垃圾桶」  
- [ ] 跨模块依赖规则写进 README  
- [ ] 四端目录策略明确（admin 必做，其余占位）  
- [ ] 非目标无膨胀进 S0  
- [ ] 本地三步可起：compose → server → admin-web  
- [ ] 统一响应与 API 前缀与规范一致  

---

## 10. 评审结论（填写）

| 项 | 内容 |
|----|------|
| 评审人 | |
| 日期 | |
| 结论 | 通过 / 修改后再评 |
| 修改意见 | |
