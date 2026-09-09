package com.chuanjie.platform.platform.biz.web;

import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import com.chuanjie.platform.platform.biz.domain.PlatformRole;
import com.chuanjie.platform.platform.biz.security.AuthContext;
import com.chuanjie.platform.platform.biz.service.RoleAdminService;
import com.chuanjie.platform.platform.biz.web.dto.RoleSaveRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.MDC;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/** 角色管理 API。 */
@Tag(name = "角色管理", description = "角色列表与增改")
@RestController
@RequestMapping("/admin-api/v1/platform/roles")
public class RoleController {

    private final RoleAdminService roleAdminService;

    public RoleController(RoleAdminService roleAdminService) {
        this.roleAdminService = roleAdminService;
    }

    /** 角色列表。status：active（默认）/ disabled / all */
    @Operation(summary = "角色列表")
    @GetMapping
    public ApiResponse<List<PlatformRole>> list(
            @RequestParam(defaultValue = "active") String status) {
        return ApiResponse.ok(roleAdminService.listAll(status), rid());
    }

    /** 新建角色。 */
    @PostMapping
    public ApiResponse<Map<String, Long>> create(@Valid @RequestBody RoleSaveRequest request) {
        Long id = roleAdminService.create(request, operator());
        return ApiResponse.ok(Map.of("id", id), rid());
    }

    /** 更新角色。 */
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable long id, @Valid @RequestBody RoleSaveRequest request) {
        roleAdminService.update(id, request, operator());
        return ApiResponse.ok(null, rid());
    }

    /** 停用角色。 */
    @Operation(summary = "停用角色")
    @PostMapping("/{id}/disable")
    public ApiResponse<Void> disable(@PathVariable long id) {
        roleAdminService.setStatus(id, "disabled", operator());
        return ApiResponse.ok(null, rid());
    }

    /** 启用角色。 */
    @Operation(summary = "启用角色")
    @PostMapping("/{id}/enable")
    public ApiResponse<Void> enable(@PathVariable long id) {
        roleAdminService.setStatus(id, "active", operator());
        return ApiResponse.ok(null, rid());
    }

    private static String operator() {
        return AuthContext.get() == null ? "system" : AuthContext.get().username();
    }

    private static String rid() {
        String id = MDC.get(RequestIdFilter.MDC_KEY);
        return id == null ? "" : id;
    }
}
