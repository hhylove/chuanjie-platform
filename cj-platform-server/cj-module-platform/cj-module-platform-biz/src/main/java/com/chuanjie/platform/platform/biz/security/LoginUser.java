package com.chuanjie.platform.platform.biz.security;

/**
 * 登录态摘要（放入请求上下文）。
 *
 * @param userId 用户 ID
 * @param username 登录账号
 * @param displayName 显示名
 */
public record LoginUser(long userId, String username, String displayName) {}
