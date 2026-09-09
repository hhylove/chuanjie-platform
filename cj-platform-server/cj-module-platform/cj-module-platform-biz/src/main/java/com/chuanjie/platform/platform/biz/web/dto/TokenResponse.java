package com.chuanjie.platform.platform.biz.web.dto;

import java.util.List;

/**
 * 登录成功返回。
 *
 * @param accessToken JWT Access Token
 * @param refreshToken Refresh Token（可作废）
 * @param expiresIn Access 过期秒数
 * @param user 用户摘要
 */
public record TokenResponse(
        String accessToken,
        String refreshToken,
        long expiresIn,
        UserSummary user
) {
    /**
     * 用户摘要（不含密码）。
     *
     * @param id 用户 ID
     * @param username 账号
     * @param displayName 显示名
     * @param userType 身份类型
     * @param deptId 部门
     * @param roleCodes 角色编码列表
     * @param permissions 权限码列表（S1-01 可为空，S1-02 填充）
     * @param dataScope 数据范围摘要
     */
    public record UserSummary(
            Long id,
            String username,
            String displayName,
            String userType,
            Long deptId,
            List<String> roleCodes,
            List<String> permissions,
            String dataScope
    ) {}
}
