import type { ApiResponse } from '@cj/shared-types'
import { API_SUCCESS_CODE } from '@cj/constants'
import { getHttpClient } from './http'

/** Actuator 健康检查原始结构（子集） */
export interface HealthStatus {
  status: string
}

/** ping 接口 data */
export interface PingData {
  pong: boolean
  module: string
}

/**
 * 调用后端 /actuator/health
 */
export async function getHealth(): Promise<HealthStatus> {
  const { data } = await getHttpClient().get<HealthStatus>('/actuator/health')
  return data
}

/**
 * 调用后端 /admin-api/v1/system/ping（统一响应体）
 */
export async function getPing(): Promise<ApiResponse<PingData>> {
  const { data } = await getHttpClient().get<ApiResponse<PingData>>('/admin-api/v1/system/ping')
  if (data.code !== API_SUCCESS_CODE) {
    throw new Error(data.message || 'ping failed')
  }
  return data
}
