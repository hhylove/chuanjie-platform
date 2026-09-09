package com.chuanjie.platform.framework.error;

/** 可预期的业务异常，由全局处理器转为统一响应。 */
public class BizException extends RuntimeException {
    private final int code;

    public BizException(int code, String message) {
        super(message);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
