package com.chuanjie.platform.control.api;

/**
 * SaaS控制面公开边界。
 *
 * <p>后续模块只能通过本包公开的接口访问租户、套餐、会话和数据放置信息，
 * 不得依赖控制面的业务实现包。</p>
 */
public final class ControlModule {

    private ControlModule() {
    }
}
