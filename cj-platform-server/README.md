# cj-platform-server

创界新后台服务端（模块化单体）。S0 仅脚手架。

## 模块依赖规则

- `cj-server` 依赖各 `*-biz`
- `*-biz` 只依赖本模块 `*-api` + `cj-framework` + 其他模块 `*-api`
- **禁止** `*-biz` 依赖其他模块的 `*-biz` / Mapper / DO
- 业务不得堆进 platform（S1 仅身份与组织权限）

## 本地启动

```bash
# 默认 nodocker（H2，无需 Postgres）
mvn -DskipTests install
java -jar cj-server/target/cj-server-0.1.0-SNAPSHOT.jar

# 使用 Docker Postgres/Redis
# 根目录：docker compose up -d
java -jar cj-server/target/cj-server-0.1.0-SNAPSHOT.jar --spring.profiles.active=local
```

若 IDE 报 `localhost:5432 refused`：Active profiles 改成 `nodocker`，或先 `docker compose up -d` 再用 `local`。

验证：

- http://localhost:8080/actuator/health
- http://localhost:8080/admin-api/v1/system/ping

JDK：脚手架目标 21；当前工程 `release=17` 以便本机 JDK17 编译，升级 JDK21 后改回 21。
