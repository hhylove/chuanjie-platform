# 创界云枢 V2

面向多家公司的经营与协作SaaS平台。V2采用全新实现：默认共享数据库，大客户可独立数据库，并支持同一套代码私有部署。

## 当前状态

- V1前后端源码已清理，恢复基线：`30a85e1`
- R1 SaaS控制面设计已评审通过
- 已建立Java模块化单体和Vue租户感知前端骨架
- R1控制面数据库模型已建立；OIDC和真实租户接口尚未实现

## 工程目录

| 路径 | 用途 |
|---|---|
| `cj-platform-server/` | Java 21、Spring Boot 3.5模块化单体 |
| `cj-platform-web/` | Vue 3、TypeScript、Vite、pnpm工作区 |
| `.cursor/skills/chuanjie-platform/` | 已评审架构、阶段设计与进度门禁 |
| `docs/plans/` | 可执行实施计划 |
| `docs/rebuild/` | V1清理、恢复和迁移记录 |
| `docker-compose.yml` | 可选容器PostgreSQL、Valkey、SeaweedFS环境 |

## 技术基线

| 层 | 选型 |
|---|---|
| 后端 | Java 21、Spring Boot 3.5.12、Maven |
| 前端 | Vue 3、TypeScript 5、Vite 7、pnpm 10 |
| 数据 | PostgreSQL 16 |
| 缓存 | Valkey 9 |
| 文件 | SeaweedFS 4.46（S3兼容接口） |
| 身份 | 标准OIDC，默认Casdoor |

## 本地验证

```powershell
# 后端：需要JAVA_HOME指向JDK 21或更高版本，编译目标固定为Java 21。
cd cj-platform-server
.\mvnw.cmd test

# 前端
cd ..\cj-platform-web
pnpm install --frozen-lockfile
pnpm test
pnpm typecheck
pnpm build:admin

# 后端连接本机PostgreSQL 16并自动执行Flyway迁移
cd ..\cj-platform-server
.\mvnw.cmd -pl cj-server -am package -DskipTests
java -jar .\cj-server\target\cj-server-0.1.0-SNAPSHOT.jar --spring.profiles.active=local

# local配置启动后查看接口文档
# Swagger UI: http://localhost:8080/swagger-ui.html
# OpenAPI JSON: http://localhost:8080/v3/api-docs

# 可选容器基础设施；普通up不会启动已配置profile的PostgreSQL
cd ..
docker compose config
docker compose up -d

# 只有明确需要容器数据库时才执行
docker compose --profile container-db up -d postgres
```

也可以在项目根目录运行 `powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1`，一次完成后端测试、前端测试、类型检查、构建和可用时的Compose校验。本机无需全局安装Maven；Wrapper首次运行会下载固定的Maven 3.9.11。

当前开发数据库使用本机PostgreSQL 16，不要求Docker。Testcontainers隔离测试以及Valkey、SeaweedFS容器运行验收仍需兼容容器环境。

## OIDC 登录状态

OIDC协议入口已经实现，地址为 `GET /api/v1/auth/oidc/login`。当前默认关闭，因此在尚未配置身份提供方时会返回 `503 Service Unavailable`，不会创建临时用户名密码。

启用前需要在Casdoor创建应用，将 `http://localhost:8080/login/oauth2/code/casdoor` 登记为回调地址，并通过环境变量注入：

```powershell
$env:CJ_IDENTITY_OIDC_ENABLED = "true"
$env:CJ_IDENTITY_OIDC_CLIENT_ID = "Casdoor应用的Client ID"
$env:CJ_IDENTITY_OIDC_CLIENT_SECRET = "Casdoor应用的Client Secret"
$env:CJ_IDENTITY_OIDC_ISSUER_URI = "Casdoor服务地址"
```

如果Casdoor不是默认的 `http://127.0.0.1:8000`，还需按其 Discovery 文档覆盖授权、Token、JWKS和UserInfo端点。真实密钥不得提交到Git。

## 本地端口

| 服务 | 端口 |
|---|---:|
| 后端 | 8080 |
| Swagger UI（仅local默认开启） | 8080/swagger-ui.html |
| 管理端 | 5173 |
| PostgreSQL | 5432 |
| Valkey | 6379 |
| SeaweedFS S3 | 8333 |
| SeaweedFS Filer | 8888 |
| SeaweedFS Master | 9333 |

## 开发门禁

开发前先阅读：

- `.cursor/skills/chuanjie-platform/architecture-v2-saas.md`
- `.cursor/skills/chuanjie-platform/v2-rebuild.md`
- `.cursor/skills/chuanjie-platform/r1-saas-control-plane.md`
- `.cursor/skills/chuanjie-platform/progress.md`

任何新功能必须先写清范围、数据模型、接口、状态机和验收标准，经评审后才能编码。
