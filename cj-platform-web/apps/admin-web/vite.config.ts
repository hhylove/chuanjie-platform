import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  server: {
    // 管理端本地开发端口；生产环境由静态服务器托管构建产物。
    port: 5173,
    proxy: {
      // 本地开发统一代理API，避免浏览器跨域；目标端口对应Spring Boot。
      "/api": "http://localhost:8080",
      "/platform-api": "http://localhost:8080",
      "/admin-api": "http://localhost:8080",
    },
  },
});
