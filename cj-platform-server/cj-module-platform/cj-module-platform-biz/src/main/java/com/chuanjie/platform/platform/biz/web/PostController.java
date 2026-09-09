package com.chuanjie.platform.platform.biz.web;

import com.chuanjie.platform.framework.web.ApiResponse;
import com.chuanjie.platform.framework.web.RequestIdFilter;
import com.chuanjie.platform.platform.biz.domain.PlatformPost;
import com.chuanjie.platform.platform.biz.security.AuthContext;
import com.chuanjie.platform.platform.biz.service.PostAdminService;
import com.chuanjie.platform.platform.biz.web.dto.PostSaveRequest;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/** 岗位管理 API。 */
@Tag(name = "岗位管理", description = "岗位列表与增改")
@RestController
@RequestMapping("/admin-api/v1/platform/posts")
public class PostController {

    private final PostAdminService postAdminService;

    public PostController(PostAdminService postAdminService) {
        this.postAdminService = postAdminService;
    }

    /** 岗位列表。 */
    @Operation(summary = "岗位列表")
    @GetMapping
    public ApiResponse<List<PlatformPost>> list() {
        return ApiResponse.ok(postAdminService.listAll(), rid());
    }

    /** 新建岗位。 */
    @PostMapping
    public ApiResponse<Map<String, Long>> create(@Valid @RequestBody PostSaveRequest request) {
        Long id = postAdminService.create(request, operator());
        return ApiResponse.ok(Map.of("id", id), rid());
    }

    /** 更新岗位。 */
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable long id, @Valid @RequestBody PostSaveRequest request) {
        postAdminService.update(id, request, operator());
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
