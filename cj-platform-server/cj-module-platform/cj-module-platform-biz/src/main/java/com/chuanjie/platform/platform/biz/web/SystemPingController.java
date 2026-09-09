package com.chuanjie.platform.platform.biz.web;

import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.MDC;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * S0 脚手架探活接口（非业务）。
 * <p>用途：验证统一响应体、requestId 与 admin-api 前缀是否生效。</p>
 */
@Tag(name = "系统探活", description = "S0 脚手架探活，非业务")
@RestController
@RequestMapping("/admin-api/v1/system")
public class SystemPingController {

    /**
     * 探活。
     *
     * @return data.pong=true 表示服务可用
     */
    @Operation(summary = "Ping")
    @SecurityRequirements
    @GetMapping("/ping")
    public ApiResponse<Map<String, Object>> ping() {
        String requestId = MDC.get(RequestIdFilter.MDC_KEY);
        return ApiResponse.ok(Map.of("pong", true, "module", "platform"), requestId == null ? "" : requestId);
    }
}
