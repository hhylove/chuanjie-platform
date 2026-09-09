package com.chuanjie.platform.platform.biz.web.dto;

import jakarta.validation.constraints.NotBlank;

/** 刷新 Token 请求。 */
public class RefreshRequest {
    /** Refresh Token */
    @NotBlank(message = "refreshToken 不能为空")
    private String refreshToken;

    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
}
