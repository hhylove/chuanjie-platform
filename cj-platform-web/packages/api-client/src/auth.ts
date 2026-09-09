import { getHttpClient } from './http'
import type { ApiResponse } from '@cj/shared-types'

/** 登录用户摘要 */
export interface AuthUserSummary {
  id: number
  username: string
  displayName: string
  userType: string
  deptId: number | null
  roleCodes: string[]
  permissions: string[]
  dataScope: string
}

/** 登录/刷新返回 */
export interface TokenData {
  accessToken: string
  refreshToken: string
  expiresIn: number
  user: AuthUserSummary
}

/** 账号密码登录 */
export async function loginApi(username: string, password: string): Promise<ApiResponse<TokenData>> {
  const { data } = await getHttpClient().post<ApiResponse<TokenData>>('/admin-api/v1/auth/login', {
    username,
    password,
  })
  return data
}

/** 登出（作废 refresh） */
export async function logoutApi(refreshToken: string | null): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>('/admin-api/v1/auth/logout', {
    refreshToken,
  })
  return data
}

/** 刷新 access */
export async function refreshApi(refreshToken: string): Promise<ApiResponse<TokenData>> {
  const { data } = await getHttpClient().post<ApiResponse<TokenData>>('/admin-api/v1/auth/refresh', {
    refreshToken,
  })
  return data
}

/** 当前用户 */
export async function meApi(): Promise<ApiResponse<AuthUserSummary>> {
  const { data } = await getHttpClient().get<ApiResponse<AuthUserSummary>>('/admin-api/v1/auth/me')
  return data
}
