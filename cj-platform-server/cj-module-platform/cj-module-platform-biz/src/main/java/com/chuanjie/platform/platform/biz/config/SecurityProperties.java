package com.chuanjie.platform.platform.biz.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * JWT 与 SSO 相关配置。
 * 绑定前缀 cj.security；每项用途见 application.yml 注释。
 */
@ConfigurationProperties(prefix = "cj.security")
public class SecurityProperties {

    private final Jwt jwt = new Jwt();
    private final Sso sso = new Sso();

    public Jwt getJwt() {
        return jwt;
    }

    public Sso getSso() {
        return sso;
    }

    /** JWT Access/Refresh 参数 */
    public static class Jwt {
        /** HS256 签名密钥 */
        private String secret = "change-me";
        /** Access Token 过期秒数 */
        private long accessExpireSeconds = 7200;
        /** Refresh Token 过期秒数 */
        private long refreshExpireSeconds = 604800;

        public String getSecret() {
            return secret;
        }

        public void setSecret(String secret) {
            this.secret = secret;
        }

        public long getAccessExpireSeconds() {
            return accessExpireSeconds;
        }

        public void setAccessExpireSeconds(long accessExpireSeconds) {
            this.accessExpireSeconds = accessExpireSeconds;
        }

        public long getRefreshExpireSeconds() {
            return refreshExpireSeconds;
        }

        public void setRefreshExpireSeconds(long refreshExpireSeconds) {
            this.refreshExpireSeconds = refreshExpireSeconds;
        }
    }

    /** 外部 SSO 开关（S1 关闭，Casdoor 仅文档预留） */
    public static class Sso {
        /** 是否启用外部 SSO */
        private boolean enabled;
        /** 提供方：casdoor 等 */
        private String provider = "casdoor";

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public String getProvider() {
            return provider;
        }

        public void setProvider(String provider) {
            this.provider = provider;
        }
    }
}
