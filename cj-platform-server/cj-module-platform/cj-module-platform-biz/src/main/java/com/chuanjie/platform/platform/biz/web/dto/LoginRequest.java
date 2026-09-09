package com.chuanjie.platform.platform.biz.web.dto;

import jakarta.validation.constraints.NotBlank;

/** 登录请求。 */
public class LoginRequest {
    /** 登录账号 */
    @NotBlank(message = "账号不能为空")
    private String username;
    /** 明文密码（仅传输，服务端立即哈希比对） */
    @NotBlank(message = "密码不能为空")
    private String password;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
