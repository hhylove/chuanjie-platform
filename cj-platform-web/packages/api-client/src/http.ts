import axios, { type AxiosInstance } from 'axios'
import { clearAuthTokens, getAccessToken } from '@cj/auth'
import { getAppConfig } from '@cj/configuration'
import { createRequestId } from '@cj/shared-utils'

let client: AxiosInstance | null = null

/** 获取全局 Axios 实例（页面禁止直接 import axios） */
export function getHttpClient(): AxiosInstance {
  if (client) return client
  client = axios.create({
    baseURL: getAppConfig().apiBaseUrl,
    timeout: 15000,
  })
  client.interceptors.request.use((config) => {
    const requestId = createRequestId()
    config.headers.set('X-Request-Id', requestId)
    const token = getAccessToken()
    if (token) {
      config.headers.set('Authorization', `Bearer ${token}`)
    }
    return config
  })
  client.interceptors.response.use(
    (resp) => {
      const body = resp.data as { code?: number } | undefined
      // 业务未登录码：清 token（由路由守卫跳转登录）
      if (body && body.code === 100401) {
        clearAuthTokens()
      }
      return resp
    },
    (error) => Promise.reject(error),
  )
  return client
}

/** 配置变更后重置客户端（例如切换 apiBaseUrl） */
export function resetHttpClient(): void {
  client = null
}
