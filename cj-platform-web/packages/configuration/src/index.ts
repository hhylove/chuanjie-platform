/** 前端运行时配置（S0） */
export interface AppConfig {
  /**
   * 后端 API 根地址。
   * 开发默认空字符串：走 Vite 代理（/admin-api、/actuator → 8080），避免 CORS。
   * 直连后端时可设为 http://localhost:8080。
   */
  apiBaseUrl: string
}

const config: AppConfig = {
  apiBaseUrl: '',
}

/** 读取当前配置 */
export function getAppConfig(): AppConfig {
  return config
}

/** 覆盖运行时配置（应用启动时调用） */
export function setAppConfig(partial: Partial<AppConfig>): void {
  Object.assign(config, partial)
}

/** @deprecated 请用 getAppConfig()；保留兼容 */
export const defaultConfig: AppConfig = config
