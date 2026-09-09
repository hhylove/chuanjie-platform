package com.chuanjie.platform.platform.biz.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.chuanjie.platform.framework.error.BizException;
import com.chuanjie.platform.platform.biz.domain.PlatformRole;
import com.chuanjie.platform.platform.biz.domain.PlatformUser;
import com.chuanjie.platform.platform.biz.domain.PlatformUserRole;
import com.chuanjie.platform.platform.biz.error.PlatformErrorCodes;
import com.chuanjie.platform.platform.biz.mapper.PlatformRoleMapper;
import com.chuanjie.platform.platform.biz.mapper.PlatformUserMapper;
import com.chuanjie.platform.platform.biz.mapper.PlatformUserRoleMapper;
import com.chuanjie.platform.platform.biz.security.JwtTokenService;
import com.chuanjie.platform.platform.biz.security.RefreshTokenStore;
import com.chuanjie.platform.platform.biz.web.dto.TokenResponse;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/** 登录/登出/刷新/当前用户。 */
@Service
public class AuthService {

    private final PlatformUserMapper userMapper;
    private final PlatformUserRoleMapper userRoleMapper;
    private final PlatformRoleMapper roleMapper;
    private final JwtTokenService jwtTokenService;
    private final RefreshTokenStore refreshTokenStore;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AuthService(
            PlatformUserMapper userMapper,
            PlatformUserRoleMapper userRoleMapper,
            PlatformRoleMapper roleMapper,
            JwtTokenService jwtTokenService,
            RefreshTokenStore refreshTokenStore) {
        this.userMapper = userMapper;
        this.userRoleMapper = userRoleMapper;
        this.roleMapper = roleMapper;
        this.jwtTokenService = jwtTokenService;
        this.refreshTokenStore = refreshTokenStore;
    }

    /** 账号密码登录，返回 access/refresh 与用户摘要。 */
    @Transactional(readOnly = true)
    public TokenResponse login(String username, String password) {
        PlatformUser user = userMapper.selectOne(new LambdaQueryWrapper<PlatformUser>()
                .eq(PlatformUser::getUsername, username));
        if (user == null) {
            throw new BizException(PlatformErrorCodes.USER_NOT_FOUND, "账号不存在");
        }
        if (!"active".equalsIgnoreCase(user.getStatus())) {
            throw new BizException(PlatformErrorCodes.USER_DISABLED, "账号已停用，无法登录");
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new BizException(PlatformErrorCodes.BAD_PASSWORD, "密码错误");
        }
        return issueTokens(user);
    }

    /** 使用 refreshToken 换发新 access（并轮换 refresh）。 */
    @Transactional(readOnly = true)
    public TokenResponse refresh(String refreshToken) {
        Long userId = refreshTokenStore.getUserId(refreshToken);
        if (userId == null) {
            throw new BizException(PlatformErrorCodes.TOKEN_INVALID, "刷新令牌无效或已过期，请重新登录");
        }
        PlatformUser user = userMapper.selectById(userId);
        if (user == null || !"active".equalsIgnoreCase(user.getStatus())) {
            refreshTokenStore.remove(refreshToken);
            throw new BizException(PlatformErrorCodes.USER_DISABLED, "账号不可用，请重新登录");
        }
        refreshTokenStore.remove(refreshToken);
        return issueTokens(user);
    }

    /** 登出：作废 refresh。 */
    public void logout(String refreshToken) {
        if (refreshToken != null && !refreshToken.isBlank()) {
            refreshTokenStore.remove(refreshToken);
        }
    }

    /** 当前用户摘要（含角色码；权限码 S1-02 再补全）。 */
    @Transactional(readOnly = true)
    public TokenResponse.UserSummary me(long userId) {
        PlatformUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BizException(PlatformErrorCodes.USER_NOT_FOUND, "用户不存在");
        }
        return toSummary(user);
    }

    private TokenResponse issueTokens(PlatformUser user) {
        String access = jwtTokenService.createAccessToken(user.getId(), user.getUsername());
        String refresh = UUID.randomUUID().toString().replace("-", "");
        refreshTokenStore.save(refresh, user.getId(), jwtTokenService.refreshExpireSeconds());
        return new TokenResponse(access, refresh, jwtTokenService.accessExpireSeconds(), toSummary(user));
    }

    private TokenResponse.UserSummary toSummary(PlatformUser user) {
        List<Long> roleIds = userRoleMapper.selectList(new LambdaQueryWrapper<PlatformUserRole>()
                        .eq(PlatformUserRole::getUserId, user.getId()))
                .stream().map(PlatformUserRole::getRoleId).toList();
        List<String> roleCodes = new ArrayList<>();
        String dataScope = "SELF";
        if (!roleIds.isEmpty()) {
            List<PlatformRole> roles = roleMapper.selectBatchIds(roleIds);
            for (PlatformRole role : roles) {
                if (role != null && "active".equalsIgnoreCase(role.getStatus())) {
                    roleCodes.add(role.getCode());
                    if ("ALL".equalsIgnoreCase(role.getDataScope())) {
                        dataScope = "ALL";
                    } else if ("DEPT".equalsIgnoreCase(role.getDataScope()) && !"ALL".equals(dataScope)) {
                        dataScope = "DEPT";
                    }
                }
            }
        }
        return new TokenResponse.UserSummary(
                user.getId(),
                user.getUsername(),
                user.getDisplayName(),
                user.getUserType(),
                user.getDeptId(),
                roleCodes,
                List.of(),
                dataScope
        );
    }
}
