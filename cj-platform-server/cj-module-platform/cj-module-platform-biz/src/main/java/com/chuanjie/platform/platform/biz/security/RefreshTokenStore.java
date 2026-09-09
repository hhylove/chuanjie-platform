package com.chuanjie.platform.platform.biz.security;

/** Refresh Token 存储：nodocker 用内存；有 Redis 时可替换实现。 */
public interface RefreshTokenStore {

    /** 保存 refreshToken → userId，带过期秒数 */
    void save(String refreshToken, long userId, long expireSeconds);

    /** 读取 userId；不存在或过期返回 null */
    Long getUserId(String refreshToken);

    /** 删除（登出作废） */
    void remove(String refreshToken);
}
