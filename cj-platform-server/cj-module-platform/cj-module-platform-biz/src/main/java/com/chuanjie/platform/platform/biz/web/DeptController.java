package com.chuanjie.platform.platform.biz.web;

import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import com.chuanjie.platform.platform.biz.security.AuthContext;
import com.chuanjie.platform.platform.biz.service.DeptAdminService;
import com.chuanjie.platform.platform.biz.web.dto.DeptSaveRequest;
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

/** 部门管理 API。 */
@Tag(name = "部门管理", description = "部门树与增改")
@RestController
@RequestMapping("/admin-api/v1/platform/depts")
public class DeptController {

    private final DeptAdminService deptAdminService;

    public DeptController(DeptAdminService deptAdminService) {
        this.deptAdminService = deptAdminService;
    }

    /** 部门树。status：active（默认）/ disabled / all */
    @Operation(summary = "部门树")
    @GetMapping("/tree")
    public ApiResponse<List<Map<String, Object>>> tree(
            @RequestParam(defaultValue = "active") String status) {
        return ApiResponse.ok(deptAdminService.tree(status), rid());
    }

    /** 新建部门。 */
    @PostMapping
    public ApiResponse<Map<String, Long>> create(@Valid @RequestBody DeptSaveRequest request) {
        Long id = deptAdminService.create(request, operator());
        return ApiResponse.ok(Map.of("id", id), rid());
    }

    /** 更新部门。 */
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable long id, @Valid @RequestBody DeptSaveRequest request) {
        deptAdminService.update(id, request, operator());
        return ApiResponse.ok(null, rid());
    }

    /** 停用部门。 */
    @Operation(summary = "停用部门")
    @PostMapping("/{id}/disable")
    public ApiResponse<Void> disable(@PathVariable long id) {
        deptAdminService.setStatus(id, "disabled", operator());
        return ApiResponse.ok(null, rid());
    }

    /** 启用部门。 */
    @Operation(summary = "启用部门")
    @PostMapping("/{id}/enable")
    public ApiResponse<Void> enable(@PathVariable long id) {
        deptAdminService.setStatus(id, "active", operator());
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
