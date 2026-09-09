package com.chuanjie.platform.control.identity;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;

/**
 * 暴露稳定的平台OIDC登录入口，将浏览器交给Spring Security标准授权流程。
 */
@RestController
@RequestMapping("/api/v1/auth/oidc")
@Tag(name = "身份认证", description = "标准OIDC登录入口；默认身份提供方为Casdoor")
public class OidcLoginController {

    private final OidcClientProperties properties;

    public OidcLoginController(OidcClientProperties properties) {
        this.properties = properties;
    }

    /**
     * 发起OIDC授权码登录；state、nonce和PKCE均由Spring Security生成并校验。
     *
     * @return 已配置时重定向到内部OAuth2入口，未配置时返回503
     */
    @GetMapping("/login")
    @Operation(summary = "发起OIDC登录", description = "生成一次性state、nonce和PKCE参数并重定向到身份提供方")
    @ApiResponses({
            @ApiResponse(responseCode = "302", description = "转入OIDC授权码登录流程"),
            @ApiResponse(responseCode = "503", description = "OIDC尚未配置或未启用")
    })
    public ResponseEntity<Void> login() {
        if (!properties.isEnabled()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
        }

        URI authorizationEntry = URI.create("/oauth2/authorization/" + properties.getRegistrationId());
        return ResponseEntity.status(HttpStatus.FOUND)
                .header(HttpHeaders.LOCATION, authorizationEntry.toString())
                .build();
    }
}
