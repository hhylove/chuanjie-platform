package com.chuanjie.platform.framework.web;

/**
 * 统一 API 响应体。
 *
 * @param code 0 成功，非 0 失败（见错误码段）
 * @param data 业务数据
 * @param message 提示信息；失败时说明原因与处理建议
 * @param requestId 请求追踪号
 */
public record ApiResponse<T>(int code, T data, String message, String requestId) {

    /** 成功响应 */
    public static <T> ApiResponse<T> ok(T data, String requestId) {
        return new ApiResponse<>(0, data, "ok", requestId);
    }

    /** 失败响应 */
    public static <T> ApiResponse<T> fail(int code, String message, String requestId) {
        return new ApiResponse<>(code, null, message, requestId);
    }
}
