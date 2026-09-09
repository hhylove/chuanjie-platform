/**
 * 鉴权：本地 Access/Refresh Token 读写；真实登录走 api-client auth。
 */
const ACCESS_KEY = 'cj_access_token'
const REFRESH_KEY = 'cj_refresh_token'

export function getAccessToken(): string | null {
  if (typeof localStorage === 'undefined') return null
  return localStorage.getItem(ACCESS_KEY)
}

export function setAccessToken(token: string): void {
  localStorage.setItem(ACCESS_KEY, token)
}

export function clearAccessToken(): void {
  localStorage.removeItem(ACCESS_KEY)
}

export function getRefreshToken(): string | null {
  if (typeof localStorage === 'undefined') return null
  return localStorage.getItem(REFRESH_KEY)
}

export function setRefreshToken(token: string): void {
  localStorage.setItem(REFRESH_KEY, token)
}

export function clearRefreshToken(): void {
  localStorage.removeItem(REFRESH_KEY)
}

/** 登出时清本地令牌 */
export function clearAuthTokens(): void {
  clearAccessToken()
  clearRefreshToken()
}

export function isLoggedIn(): boolean {
  return Boolean(getAccessToken())
}
