package com.chuanjie.platform.control.identity;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistration.ClientSettings;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.InMemoryClientRegistrationRepository;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.security.oauth2.core.oidc.OidcScopes;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.util.Assert;

/**
 * 使用Spring Security标准OIDC协议栈建立登录入口、回调校验和PKCE保护。
 */
@Configuration(proxyBeanMethods = false)
@EnableConfigurationProperties(OidcClientProperties.class)
public class OidcClientConfiguration {

    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/v1/auth/oidc/login",
            "/oauth2/**",
            "/login/oauth2/**",
            "/swagger-ui.html",
            "/swagger-ui/**",
            "/v3/api-docs/**",
            "/actuator/health",
            "/actuator/info",
            "/error"
    };

    /**
     * OIDC启用时创建唯一标准客户端注册，并强制机密客户端同时使用PKCE。
     *
     * @param properties 已从受控配置源绑定的OIDC参数
     * @return Spring Security客户端注册仓库
     */
    @Bean
    @ConditionalOnProperty(prefix = "cj.identity.oidc", name = "enabled", havingValue = "true")
    public ClientRegistrationRepository clientRegistrationRepository(OidcClientProperties properties) {
        validateEnabledProperties(properties);

        ClientRegistration registration = ClientRegistration.withRegistrationId(properties.getRegistrationId())
                .clientName(properties.getClientName())
                .clientId(properties.getClientId())
                .clientSecret(properties.getClientSecret())
                .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_BASIC)
                .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
                .redirectUri(properties.getRedirectUri())
                .scope(properties.getScopes())
                .authorizationUri(properties.getAuthorizationUri())
                .tokenUri(properties.getTokenUri())
                .jwkSetUri(properties.getJwkSetUri())
                .userInfoUri(properties.getUserInfoUri())
                .userNameAttributeName(properties.getUserNameAttribute())
                .issuerUri(properties.getIssuerUri())
                .clientSettings(ClientSettings.builder().requireProofKey(true).build())
                .build();
        return new InMemoryClientRegistrationRepository(registration);
    }

    /**
     * OIDC启用时仅放行协议、健康检查和本地文档入口，其余接口要求已认证。
     *
     * @param http Spring Security HTTP安全构建器
     * @return OIDC登录安全过滤链
     * @throws Exception 安全规则无法构建时抛出
     */
    @Bean
    @ConditionalOnProperty(prefix = "cj.identity.oidc", name = "enabled", havingValue = "true")
    public SecurityFilterChain oidcSecurityFilterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        .anyRequest().authenticated())
                .oauth2Login(Customizer.withDefaults())
                .build();
    }

    /**
     * OIDC未配置时阻断所有未明确公开的业务接口，避免Spring默认账号或匿名访问误上线。
     *
     * @param http Spring Security HTTP安全构建器
     * @return 安全关闭状态下的最小过滤链
     * @throws Exception 安全规则无法构建时抛出
     */
    @Bean
    @ConditionalOnProperty(prefix = "cj.identity.oidc", name = "enabled", havingValue = "false", matchIfMissing = true)
    public SecurityFilterChain oidcDisabledSecurityFilterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        .anyRequest().denyAll())
                .build();
    }

    private static void validateEnabledProperties(OidcClientProperties properties) {
        Assert.hasText(properties.getRegistrationId(), "cj.identity.oidc.registration-id must not be blank");
        Assert.hasText(properties.getClientId(), "CJ_IDENTITY_OIDC_CLIENT_ID must be configured when OIDC is enabled");
        Assert.hasText(properties.getClientSecret(), "CJ_IDENTITY_OIDC_CLIENT_SECRET must be configured when OIDC is enabled");
        Assert.hasText(properties.getIssuerUri(), "cj.identity.oidc.issuer-uri must not be blank");
        Assert.hasText(properties.getAuthorizationUri(), "cj.identity.oidc.authorization-uri must not be blank");
        Assert.hasText(properties.getTokenUri(), "cj.identity.oidc.token-uri must not be blank");
        Assert.hasText(properties.getJwkSetUri(), "cj.identity.oidc.jwk-set-uri must not be blank");
        Assert.hasText(properties.getUserInfoUri(), "cj.identity.oidc.user-info-uri must not be blank");
        Assert.hasText(properties.getRedirectUri(), "cj.identity.oidc.redirect-uri must not be blank");
        Assert.isTrue(properties.getScopes().contains(OidcScopes.OPENID),
                "cj.identity.oidc.scopes must contain openid");
    }
}
