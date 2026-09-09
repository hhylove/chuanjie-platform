package com.chuanjie.platform.control.identity;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 验证OIDC未配置时不会产生临时账号，也不会意外放开业务接口。
 */
@SpringBootTest(classes = OidcDisabledTest.TestApplication.class,
        properties = {
                "cj.identity.oidc.enabled=false",
                "springdoc.api-docs.enabled=false"
        })
@AutoConfigureMockMvc
class OidcDisabledTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void reportsLoginUnavailableWithoutProviderConfiguration() throws Exception {
        mockMvc.perform(get("/api/v1/auth/oidc/login"))
                .andExpect(status().isServiceUnavailable());
    }

    @Test
    void deniesNonPublicBusinessEndpointsWhileIdentityIsDisabled() throws Exception {
        mockMvc.perform(get("/admin-api/v1/private-check"))
                .andExpect(status().isForbidden());
    }

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @Import({OidcClientConfiguration.class, OidcLoginController.class})
    static class TestApplication {
    }
}
