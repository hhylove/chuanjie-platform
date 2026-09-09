package com.chuanjie.platform.control.identity;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

/**
 * 平台OIDC客户端配置；只描述标准协议端点，不依赖Casdoor专有SDK。
 */
@ConfigurationProperties(prefix = "cj.identity.oidc")
public class OidcClientProperties {

    /** 是否启用真实OIDC登录；未配置客户端凭据时必须保持关闭。 */
    private boolean enabled;

    /** Spring Security中的提供方注册标识，也是回调路径的一部分。 */
    private String registrationId = "casdoor";

    /** 登录页展示的身份提供方名称。 */
    private String clientName = "Casdoor";

    /** 身份提供方分配给创界云枢的OAuth2客户端编号。 */
    private String clientId;

    /** 身份提供方分配的客户端密钥，只能由环境或密钥系统注入。 */
    private String clientSecret;

    /** OIDC签发者地址，用于校验ID Token中的issuer。 */
    private String issuerUri;

    /** 浏览器发起授权码登录的标准授权端点。 */
    private String authorizationUri;

    /** 后端使用授权码换取令牌的标准Token端点。 */
    private String tokenUri;

    /** 校验ID Token签名所使用的公开密钥集合端点。 */
    private String jwkSetUri;

    /** 读取标准用户声明的UserInfo端点。 */
    private String userInfoUri;

    /** 身份提供方中稳定用户主键对应的声明名。 */
    private String userNameAttribute = "sub";

    /** OIDC回调地址模板，必须与身份提供方登记值完全一致。 */
    private String redirectUri = "{baseUrl}/login/oauth2/code/{registrationId}";

    /** 请求的最小OIDC声明范围；openid不可删除。 */
    private List<String> scopes = new ArrayList<>(List.of("openid", "profile", "email"));

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getRegistrationId() {
        return registrationId;
    }

    public void setRegistrationId(String registrationId) {
        this.registrationId = registrationId;
    }

    public String getClientName() {
        return clientName;
    }

    public void setClientName(String clientName) {
        this.clientName = clientName;
    }

    public String getClientId() {
        return clientId;
    }

    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }

    public String getIssuerUri() {
        return issuerUri;
    }

    public void setIssuerUri(String issuerUri) {
        this.issuerUri = issuerUri;
    }

    public String getAuthorizationUri() {
        return authorizationUri;
    }

    public void setAuthorizationUri(String authorizationUri) {
        this.authorizationUri = authorizationUri;
    }

    public String getTokenUri() {
        return tokenUri;
    }

    public void setTokenUri(String tokenUri) {
        this.tokenUri = tokenUri;
    }

    public String getJwkSetUri() {
        return jwkSetUri;
    }

    public void setJwkSetUri(String jwkSetUri) {
        this.jwkSetUri = jwkSetUri;
    }

    public String getUserInfoUri() {
        return userInfoUri;
    }

    public void setUserInfoUri(String userInfoUri) {
        this.userInfoUri = userInfoUri;
    }

    public String getUserNameAttribute() {
        return userNameAttribute;
    }

    public void setUserNameAttribute(String userNameAttribute) {
        this.userNameAttribute = userNameAttribute;
    }

    public String getRedirectUri() {
        return redirectUri;
    }

    public void setRedirectUri(String redirectUri) {
        this.redirectUri = redirectUri;
    }

    public List<String> getScopes() {
        return scopes;
    }

    public void setScopes(List<String> scopes) {
        this.scopes = new ArrayList<>(scopes);
    }
}
