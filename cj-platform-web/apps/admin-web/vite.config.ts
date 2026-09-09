import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'node:path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      // @ -> src，页面内用 @/xxx 引用
      '@': path.resolve(__dirname, 'src'),
    },
  },
  server: {
    // 前端开发服务器端口
    port: 5173,
    proxy: {
      // 将 /admin-api 转到后端，避免浏览器 CORS；需后端已在 8080 启动
      '/admin-api': 'http://localhost:8080',
      // Actuator 健康检查同源代理
      '/actuator': 'http://localhost:8080',
      // springdoc OpenAPI JSON
      '/v3/api-docs': 'http://localhost:8080',
      // Swagger UI 静态资源与入口
      '/swagger-ui': 'http://localhost:8080',
      '/swagger-ui.html': 'http://localhost:8080',
    },
  },
})
