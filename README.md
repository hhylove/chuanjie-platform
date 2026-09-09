# 创界新后台（chuanjie）

统一企业经营与创业项目管理平台。当前交付：**S0 脚手架 + S1-01 登录/身份底座（进行中）**。

## 目录

| 路径 | 说明 |
|------|------|
| `cj-platform-server/` | 后端模块化单体 |
| `cj-platform-web/` | 前端 pnpm monorepo |
| `docs/` | 文档 |
| `.cursor/skills/chuanjie-platform/` | 项目 skill（先文档后开发） |
| `docker-compose.yml` | Postgres / Redis / MinIO |

## 端口

| 服务 | 端口 |
|------|------|
| 后端 | 8080 |
| admin-web | 5173 |
| Postgres | 5432 |
| Redis | 6379 |
| MinIO API / Console | 9000 / 9001 |

Postgres：`cj` / `cj_local`，库名 `cj_platform`  
MinIO：`cjminio` / `cjminio_local`

## 本地启动

```bash
# A. 无 Docker：直接用默认 nodocker（内存 H2）
cd cj-platform-server
# 需 JDK 17+；本机示例：JAVA_HOME=D:\jdk17
mvn -DskipTests package
java -jar cj-server/target/cj-server-0.1.0-SNAPSHOT.jar
# IDE 运行 main 即可，默认 profile=nodocker

# B. 有 Docker Desktop：先起中间件，再切 local
docker compose up -d
java -jar cj-server/target/cj-server-0.1.0-SNAPSHOT.jar --spring.profiles.active=local

# 前端
cd ../cj-platform-web
pnpm install
pnpm dev:admin
# 浏览器打开 http://localhost:5173 → 登录页
# 默认账号 admin / Admin@123
# 前端默认经 Vite 代理访问 8080
```

验证：

- http://localhost:8080/actuator/health
- http://localhost:8080/admin-api/v1/system/ping
- `POST /admin-api/v1/auth/login`（账号密码）
- admin-web 登录后进工作台，可退出
- **接口文档（Swagger UI）：** http://localhost:8080/swagger-ui.html  
  OpenAPI JSON：http://localhost:8080/v3/api-docs  
  用法：先调「登录」拿 `accessToken` → 右上角 Authorize → 填入 token → 调需鉴权接口

**说明：**

- 报 `Connection to localhost:5432 refused` = 后端用了 `local` 且 Postgres 未启动 → 改用默认 `nodocker`，或先 `docker compose up -d`
- 前端直连 8080 失败 / CORS：确认 `VITE_API_BASE_URL` 为空，走代理；并确认后端已在 8080 启动
- Casdoor SSO：仅 skill 文档预留，S1 不部署
- 生产环境可通过 `springdoc.api-docs.enabled=false` / `springdoc.swagger-ui.enabled=false` 关闭文档入口
