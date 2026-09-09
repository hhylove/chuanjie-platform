/** 统一 API 响应 */
export interface ApiResponse<T> {
  /** 0 成功，非 0 失败 */
  code: number
  data: T
  message: string
  requestId: string
}
