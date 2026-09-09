package com.chuanjie.platform.platform.biz.web;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import com.chuanjie.platform.platform.biz.domain.PlatformUser;
import com.chuanjie.platform.platform.biz.security.AuthContext;
import com.chuanjie.platform.platform.biz.service.UserAdminService;
import com.chuanjie.platform.platform.biz.web.dto.UserSaveRequest;
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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 用户管理 API。 */
@Tag(name = "用户管理", description = "用户分页/增改/启停")
@RestController
@RequestMapping("/admin-api/v1/platform/users")
public class UserController {

    private final UserAdminService userAdminService;

    public UserController(UserAdminService userAdminService) {
        this.userAdminService = userAdminService;
    }

    /** 分页查询用户（不含密码哈希）。 */
    @Operation(summary = "用户分页")
    @GetMapping
    public ApiResponse<Map<String, Object>> page(
            @RequestParam(defaultValue = "1") long pageNo,
            @RequestParam(defaultValue = "20") long pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "active") String status) {
        Page<PlatformUser> page = userAdminService.page(pageNo, pageSize, keyword, status);
        List<Map<String, Object>> records = page.getRecords().stream().map(userAdminService::toView).toList();
        Map<String, Object> data = new HashMap<>();
        data.put("list", records);
        data.put("total", page.getTotal());
        data.put("pageNo", page.getCurrent());
        data.put("pageSize", page.getSize());
        return ApiResponse.ok(data, rid());
    }

    /** 用户详情。 */
    @GetMapping("/{id}")
    public ApiResponse<Map<String, Object>> detail(@PathVariable long id) {
        return ApiResponse.ok(userAdminService.toView(userAdminService.get(id)), rid());
    }

    /** 创建用户。 */
    @PostMapping
    public ApiResponse<Map<String, Long>> create(@Valid @RequestBody UserSaveRequest request) {
        Long id = userAdminService.create(request, operator());
        return ApiResponse.ok(Map.of("id", id), rid());
    }

    /** 更新用户。 */
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable long id, @Valid @RequestBody UserSaveRequest request) {
        userAdminService.update(id, request, operator());
        return ApiResponse.ok(null, rid());
    }

    /** 停用用户（status=disabled）。 */
    @PostMapping("/{id}/disable")
    public ApiResponse<Void> disable(@PathVariable long id) {
        userAdminService.setStatus(id, "disabled", operator());
        return ApiResponse.ok(null, rid());
    }

    /** 启用用户。 */
    @PostMapping("/{id}/enable")
    public ApiResponse<Void> enable(@PathVariable long id) {
        userAdminService.setStatus(id, "active", operator());
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
