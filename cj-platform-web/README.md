# cj-platform-web

创界新后台前端 monorepo（pnpm workspace）。S0：admin-web + api-client 可跑。

## Apps

| 应用 | 说明 |
|------|------|
| admin-web | 内部管理后台（S0 必须） |
| entrepreneur-web | 创业者端占位 |
| supplier-web | 供应商端占位 |
| mobile | 移动端占位 |

## 命令

```bash
pnpm install
pnpm typecheck
pnpm build:admin
pnpm dev:admin
```

开发时 API **默认走 Vite 代理**（`apiBaseUrl` 为空），代理到 `http://localhost:8080`，与后端 `nodocker`/`local` 无关。

可选：在 `apps/admin-web/.env.development` 设置 `VITE_API_BASE_URL=http://localhost:8080` 改为直连（需后端 CORS）。

页面禁止直调 Axios，统一经 `@cj/api-client`。
