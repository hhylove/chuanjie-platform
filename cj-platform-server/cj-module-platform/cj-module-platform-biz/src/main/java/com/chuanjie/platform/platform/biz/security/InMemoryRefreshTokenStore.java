package com.chuanjie.platform.platform.biz.security;

import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 内存 Refresh Token 存储。
 * 用途：nodocker / 单机开发；进程重启后全部失效。生产多实例应换 Redis 实现。
 */
@Component
public class InMemoryRefreshTokenStore implements RefreshTokenStore {

    private record Entry(long userId, long expireAtEpochMs) {}

    private final Map<String, Entry> store = new ConcurrentHashMap<>();

    @Override
    public void save(String refreshToken, long userId, long expireSeconds) {
        long expireAt = System.currentTimeMillis() + expireSeconds * 1000L;
        store.put(refreshToken, new Entry(userId, expireAt));
    }

    @Override
    public Long getUserId(String refreshToken) {
        Entry entry = store.get(refreshToken);
        if (entry == null) {
            return null;
        }
        if (entry.expireAtEpochMs() < System.currentTimeMillis()) {
            store.remove(refreshToken);
            return null;
        }
        return entry.userId();
    }

    @Override
    public void remove(String refreshToken) {
        store.remove(refreshToken);
    }
}
