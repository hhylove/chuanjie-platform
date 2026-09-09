package com.chuanjie.platform.tenant.api.context;

import java.util.Objects;
import java.util.Optional;

/**
 * 将已验证的租户上下文绑定到当前请求线程，并在作用域结束时强制清理。
 *
 * <p>该类型不会从请求头直接构造上下文；调用方必须先完成平台会话、成员状态和租户状态校验。
 */
public final class TenantContextHolder {

    private static final ThreadLocal<TenantContext> CURRENT = new ThreadLocal<>();

    private TenantContextHolder() {
    }

    /**
     * 返回当前线程的租户上下文；尚未选择租户时为空。
     *
     * @return 可选租户上下文
     */
    public static Optional<TenantContext> current() {
        return Optional.ofNullable(CURRENT.get());
    }

    /**
     * 返回当前租户上下文，缺失时拒绝继续访问租户业务。
     *
     * @return 当前可信租户上下文
     * @throws IllegalStateException 当前线程没有绑定租户上下文
     */
    public static TenantContext required() {
        TenantContext context = CURRENT.get();
        if (context == null) {
            throw new IllegalStateException("Tenant context is not bound to the current thread");
        }
        return context;
    }

    /**
     * 打开唯一租户作用域；禁止嵌套覆盖，避免一次请求意外切换租户。
     *
     * @param context 已完成会话和成员校验的可信上下文
     * @return 必须通过try-with-resources关闭的作用域
     */
    public static Scope open(TenantContext context) {
        Objects.requireNonNull(context, "context must not be null");
        if (CURRENT.get() != null) {
            throw new IllegalStateException("Tenant context is already bound to the current thread");
        }
        CURRENT.set(context);
        return new Scope(Thread.currentThread());
    }

    /** 当前线程租户绑定的可关闭作用域。 */
    public static final class Scope implements AutoCloseable {

        private final Thread ownerThread;
        private boolean closed;

        private Scope(Thread ownerThread) {
            this.ownerThread = ownerThread;
        }

        /** 清理线程租户上下文；重复关闭不产生副作用。 */
        @Override
        public void close() {
            if (closed) {
                return;
            }
            if (Thread.currentThread() != ownerThread) {
                throw new IllegalStateException("Tenant context scope must be closed by its owner thread");
            }
            CURRENT.remove();
            closed = true;
        }
    }
}
