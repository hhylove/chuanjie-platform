package com.chuanjie.platform.platform.biz.security;

import com.chuanjie.platform.platform.biz.config.SecurityProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.UUID;

/** 签发与解析本系统 JWT Access Token。 */
@Component
public class JwtTokenService {

    private final SecurityProperties securityProperties;
    private final SecretKey key;

    public JwtTokenService(SecurityProperties securityProperties) {
        this.securityProperties = securityProperties;
        byte[] bytes = securityProperties.getJwt().getSecret().getBytes(StandardCharsets.UTF_8);
        this.key = Keys.hmacShaKeyFor(bytes);
    }

    /**
     * 签发 Access Token。
     *
     * @param userId 用户主键
     * @param username 登录名
     * @return JWT 字符串
     */
    public String createAccessToken(long userId, String username) {
        Instant now = Instant.now();
        Instant exp = now.plusSeconds(securityProperties.getJwt().getAccessExpireSeconds());
        return Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(String.valueOf(userId))
                .claim("username", username)
                .issuedAt(Date.from(now))
                .expiration(Date.from(exp))
                .signWith(key)
                .compact();
    }

    /** 解析并校验 Access Token，失败抛异常。 */
    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public long accessExpireSeconds() {
        return securityProperties.getJwt().getAccessExpireSeconds();
    }

    public long refreshExpireSeconds() {
        return securityProperties.getJwt().getRefreshExpireSeconds();
    }
}
