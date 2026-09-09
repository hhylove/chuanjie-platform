package com.chuanjie.platform.control.identity;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * 验证OIDC登录入口由标准Spring Security协议栈生成state、nonce和PKCE参数。
 */
@SpringBootTest(
        classes = OidcLoginTest.TestApplication.class,
        properties = {
                "cj.identity.oidc.enabled=true",
                "springdoc.api-docs.enabled=false",
                "cj.identity.oidc.registration-id=casdoor",
                "cj.identity.oidc.client-id=test-client",
                "cj.identity.oidc.client-secret=test-secret",
                "cj.identity.oidc.issuer-uri=https://identity.example.test",
                "cj.identity.oidc.authorization-uri=https://identity.example.test/authorize",
                "cj.identity.oidc.token-uri=https://identity.example.test/token",
                "cj.identity.oidc.jwk-set-uri=https://identity.example.test/jwks",
                "cj.identity.oidc.user-info-uri=https://identity.example.test/userinfo"
        })
@AutoConfigureMockMvc
class OidcLoginTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void loginEndpointStartsAuthorizationCodeFlowWithStateNonceAndPkce() throws Exception {
        mockMvc.perform(get("/api/v1/auth/oidc/login"))
                .andExpect(status().isFound())
                .andExpect(redirectedUrl("/oauth2/authorization/casdoor"));

        String location = mockMvc.perform(get("/oauth2/authorization/casdoor"))
                .andExpect(status().isFound())
                .andReturn()
                .getResponse()
                .getRedirectedUrl();

        UriComponents authorization = UriComponentsBuilder.fromUri(URI.create(location)).build();
        assertThat(authorization.getScheme()).isEqualTo("https");
        assertThat(authorization.getHost()).isEqualTo("identity.example.test");
        assertThat(authorization.getPath()).isEqualTo("/authorize");
        assertThat(authorization.getQueryParams().getFirst("response_type")).isEqualTo("code");
        assertThat(authorization.getQueryParams().getFirst("client_id")).isEqualTo("test-client");
        assertThat(authorization.getQueryParams().getFirst("state")).isNotBlank();
        assertThat(authorization.getQueryParams().getFirst("nonce")).isNotBlank();
        assertThat(authorization.getQueryParams().getFirst("code_challenge")).isNotBlank();
        assertThat(authorization.getQueryParams().getFirst("code_challenge_method")).isEqualTo("S256");
    }

    @Test
    void callbackRejectsForgedStateBeforeCallingTokenEndpoint() throws Exception {
        mockMvc.perform(get("/login/oauth2/code/casdoor")
                        .param("code", "untrusted-code")
                        .param("state", "forged-state"))
                .andExpect(status().isFound())
                .andExpect(redirectedUrl("/login?error"));
    }

    @SpringBootConfiguration
    @EnableAutoConfiguration
    @Import({OidcClientConfiguration.class, OidcLoginController.class})
    static class TestApplication {
    }
}
