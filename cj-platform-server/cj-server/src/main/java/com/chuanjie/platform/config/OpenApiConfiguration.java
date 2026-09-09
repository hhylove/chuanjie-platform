package com.chuanjie.platform.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 配置创界云枢对外接口文档的产品信息和统一认证方式。
 *
 * <p>OIDC负责登录，平台后续接口使用OIDC流程换取的平台Bearer访问令牌。
 */
@Configuration(proxyBeanMethods = false)
public class OpenApiConfiguration {

    public static final String BEARER_AUTH = "bearerAuth";

    /**
     * 创建全局OpenAPI描述；业务Controller通过OpenAPI注解补充标签、参数和返回语义。
     *
     * @return 包含产品元信息和Bearer认证定义的OpenAPI模型
     */
    @Bean
    public OpenAPI chuanjieOpenApi() {
        SecurityScheme bearerScheme = new SecurityScheme()
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")
                .description("通过平台OIDC登录流程取得的租户绑定访问令牌");

        return new OpenAPI()
                .info(new Info()
                        .title("创界云枢 SaaS API")
                        .version("v1")
                        .description("多公司SaaS平台接口。租户业务接口必须使用服务端签发的租户绑定Bearer令牌。")
                        .contact(new Contact().name("创界AI科技中心")))
                .components(new Components().addSecuritySchemes(BEARER_AUTH, bearerScheme));
    }
}
