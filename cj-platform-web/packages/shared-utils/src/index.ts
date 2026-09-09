/** 生成简易 requestId（浏览器侧兜底） */
export function createRequestId(): string {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) {
    return crypto.randomUUID().replaceAll('-', '')
  }
  return `${Date.now()}${Math.random().toString(16).slice(2)}`
}
