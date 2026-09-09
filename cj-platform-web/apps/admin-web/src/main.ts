import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import './styles/tokens.css'
import './styles/themes.css'
import { setAppConfig } from '@cj/configuration'
import { resetHttpClient } from '@cj/api-client'
import { initTheme } from './composables/useTheme'
import App from './App.vue'
import { router } from './router'

// 开发默认走 Vite 代理；需要直连后端时在 .env 设 VITE_API_BASE_URL=http://localhost:8080
setAppConfig({
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL ?? '',
})
resetHttpClient()
// 应用本地主题偏好（与 index.html 内联脚本配合，避免闪白）
initTheme()

createApp(App).use(createPinia()).use(router).use(ElementPlus).mount('#app')
