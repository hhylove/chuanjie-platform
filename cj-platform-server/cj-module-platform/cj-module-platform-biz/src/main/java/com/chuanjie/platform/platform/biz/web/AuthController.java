package com.chuanjie.platform.platform.biz.web;

import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import com.chuanjie.platform.platform.biz.security.AuthContext;
import com.chuanjie.platform.platform.biz.security.LoginUser;
import com.chuanjie.platform.platform.biz.service.AuthService;
import com.chuanjie.platform.platform.biz.web.dto.LoginRequest;
import com.chuanjie.platform.platform.biz.web.dto.RefreshRequest;
import com.chuanjie.platform.platform.biz.web.dto.TokenResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.MDC;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 认证接口：登录 / 登出 / 刷新 / 当前用户。
 * 路径前缀 /admin-api/v1/auth
 */
@Tag(name = "认证", description = "登录、登出、刷新 Token、当前用户")
@RestController
@RequestMapping("/admin-api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * 账号密码登录。
     *
     * @param request username + password
     * @return accessToken、refreshToken、用户摘要
     */
    @Operation(summary = "登录", description = "账号密码登录；成功返回 accessToken 与 refreshToken")
    @SecurityRequirements // 登录无需 Bearer
    @PostMapping("/login")
    public ApiResponse<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.ok(authService.login(request.getUsername(), request.getPassword()), rid());
    }

    /**
     * 登出：请求体可带 refreshToken 以作废；无 body 也允许（仅清客户端）。
     */
    @Operation(summary = "登出", description = "可选传 refreshToken 作废服务端刷新令牌")
    @SecurityRequirements
    @PostMapping("/logout")
    public ApiResponse<Void> logout(@RequestBody(required = false) Map<String, String> body) {
        String refresh = body == null ? null : body.get("refreshToken");
        authService.logout(refresh);
        return ApiResponse.ok(null, rid());
    }

    /**
     * 刷新 Access Token。
     *
     * @param request refreshToken
     * @return 新的 token 对
     */
    @Operation(summary = "刷新 Token", description = "用 refreshToken 换发新的 access/refresh")
    @SecurityRequirements
    @PostMapping("/refresh")
    public ApiResponse<TokenResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        return ApiResponse.ok(authService.refresh(request.getRefreshToken()), rid());
    }

    /**
     * 当前登录用户、角色码、数据范围摘要。
     */
    @Operation(summary = "当前用户", description = "需 Authorization: Bearer {accessToken}")
    @GetMapping("/me")
    public ApiResponse<TokenResponse.UserSummary> me() {
        LoginUser loginUser = AuthContext.get();
        return ApiResponse.ok(authService.me(loginUser.userId()), rid());
    }

    private static String rid() {
        String id = MDC.get(RequestIdFilter.MDC_KEY);
        return id == null ? "" : id;
    }
}
