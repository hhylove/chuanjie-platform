package com.chuanjie.platform.platform.biz.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.OptimisticLockerInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import com.chuanjie.platform.platform.biz.security.AuthInterceptor;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * platform 模块 Web / MyBatis 配置。
 * MapperScan：扫描 platform 包下 Mapper。
 */
@Configuration
@EnableConfigurationProperties(SecurityProperties.class)
@MapperScan("com.chuanjie.platform.platform.biz.mapper")
public class PlatformWebConfig implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    public PlatformWebConfig(AuthInterceptor authInterceptor) {
        this.authInterceptor = authInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/admin-api/**")
                .excludePathPatterns(
                        "/admin-api/v1/auth/login",
                        "/admin-api/v1/auth/refresh",
                        "/admin-api/v1/auth/logout",
                        "/admin-api/v1/system/ping"
                );
    }

    /** MyBatis Plus：分页 + 乐观锁。 */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.H2));
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
        return interceptor;
    }
}
