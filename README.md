# 创界云枢 V2

面向多家公司的经营与协作SaaS平台。V2采用全新实现：默认共享数据库，大客户可独立数据库，并支持同一套代码私有部署。

## 当前状态

- V1前后端源码已清理，恢复基线：`30a85e1`
- R1 SaaS控制面设计已评审通过
- 已建立Java模块化单体和Vue租户感知前端骨架
- OIDC、数据库模型和真实租户接口尚未实现

## 工程目录

| 路径 | 用途 |
|---|---|
| `cj-platform-server/` | Java 21、Spring Boot 3.5模块化单体 |
| `cj-platform-web/` | Vue 3、TypeScript、Vite、pnpm工作区 |
| `.cursor/skills/chuanjie-platform/` | 已评审架构、阶段设计与进度门禁 |
| `docs/plans/` | 可执行实施计划 |
| `docs/rebuild/` | V1清理、恢复和迁移记录 |
| `docker-compose.yml` | PostgreSQL、Valkey、SeaweedFS本地环境 |

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

# 本地基础设施
cd ..
docker compose config
docker compose up -d
```

也可以在项目根目录运行 `powershell -ExecutionPolicy Bypass -File .\scripts\verify.ps1`，一次完成后端测试、前端测试、类型检查、构建和可用时的Compose校验。本机无需全局安装Maven；Wrapper首次运行会下载固定的Maven 3.9.11。

当前设备尚未安装Docker CLI，因此这里只完成了Compose YAML静态结构检查，容器运行验收待Docker可用后执行。

## 本地端口

| 服务 | 端口 |
|---|---:|
| 后端 | 8080 |
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
