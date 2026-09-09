package com.chuanjie.platform.platform.biz.security;

import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import com.chuanjie.platform.platform.biz.error.PlatformErrorCodes;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.MDC;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.nio.charset.StandardCharsets;

/** 校验 Authorization Bearer JWT，写入 AuthContext。 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtTokenService jwtTokenService;
    private final ObjectMapper objectMapper;

    public AuthInterceptor(JwtTokenService jwtTokenService, ObjectMapper objectMapper) {
        this.jwtTokenService = jwtTokenService;
        this.objectMapper = objectMapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            writeUnauthorized(response, "未登录或缺少 Authorization Bearer Token");
            return false;
        }
        String token = header.substring(7).trim();
        try {
            Claims claims = jwtTokenService.parse(token);
            long userId = Long.parseLong(claims.getSubject());
            String username = String.valueOf(claims.get("username"));
            AuthContext.set(new LoginUser(userId, username, username));
            return true;
        } catch (JwtException | IllegalArgumentException ex) {
            writeUnauthorized(response, "登录已失效，请重新登录");
            return false;
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        AuthContext.clear();
    }

    private void writeUnauthorized(HttpServletResponse response, String message) throws Exception {
        response.setStatus(HttpServletResponse.SC_OK);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        String rid = MDC.get(RequestIdFilter.MDC_KEY);
        ApiResponse<Void> body = ApiResponse.fail(PlatformErrorCodes.UNAUTHORIZED, message, rid == null ? "" : rid);
        response.getWriter().write(objectMapper.writeValueAsString(body));
    }
}
