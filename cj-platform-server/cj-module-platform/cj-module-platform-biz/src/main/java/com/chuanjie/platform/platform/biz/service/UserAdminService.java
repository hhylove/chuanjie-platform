package com.chuanjie.platform.platform.biz.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.chuanjie.platform.framework.error.BizException;
import com.chuanjie.platform.platform.biz.domain.PlatformUser;
import com.chuanjie.platform.platform.biz.domain.PlatformUserRole;
import com.chuanjie.platform.platform.biz.error.PlatformErrorCodes;
import com.chuanjie.platform.platform.biz.mapper.PlatformUserMapper;
import com.chuanjie.platform.platform.biz.mapper.PlatformUserRoleMapper;
import com.chuanjie.platform.platform.biz.web.dto.UserSaveRequest;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 用户 CRUD（不含密码回传）。 */
@Service
public class UserAdminService {

    private final PlatformUserMapper userMapper;
    private final PlatformUserRoleMapper userRoleMapper;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserAdminService(PlatformUserMapper userMapper, PlatformUserRoleMapper userRoleMapper) {
        this.userMapper = userMapper;
        this.userRoleMapper = userRoleMapper;
    }

    /** 分页列表；keyword 匹配账号或显示名；status 默认 active，传 all 查全部。 */
    public Page<PlatformUser> page(long pageNo, long pageSize, String keyword, String status) {
        LambdaQueryWrapper<PlatformUser> q = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            q.and(w -> w.like(PlatformUser::getUsername, keyword)
                    .or().like(PlatformUser::getDisplayName, keyword));
        }
        if (!StringUtils.hasText(status) || !"all".equalsIgnoreCase(status)) {
            q.eq(PlatformUser::getStatus, StringUtils.hasText(status) ? status : "active");
        }
        q.orderByDesc(PlatformUser::getId);
        return userMapper.selectPage(new Page<>(pageNo, pageSize), q);
    }

    public PlatformUser get(long id) {
        PlatformUser user = userMapper.selectById(id);
        if (user == null) {
            throw new BizException(PlatformErrorCodes.USER_NOT_FOUND, "用户不存在");
        }
        return user;
    }

    /** 创建用户并绑定角色。 */
    @Transactional
    public Long create(UserSaveRequest req, String operator) {
        Long exists = userMapper.selectCount(new LambdaQueryWrapper<PlatformUser>()
                .eq(PlatformUser::getUsername, req.getUsername()));
        if (exists != null && exists > 0) {
            throw new BizException(PlatformErrorCodes.USERNAME_EXISTS, "账号已存在");
        }
        if (!StringUtils.hasText(req.getPassword())) {
            throw new BizException(100400, "创建用户时密码不能为空");
        }
        PlatformUser user = new PlatformUser();
        user.setUsername(req.getUsername());
        user.setPasswordHash(passwordEncoder.encode(req.getPassword()));
        fillUser(user, req);
        user.setCreator(operator);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdater(operator);
        user.setUpdateTime(LocalDateTime.now());
        user.setDeleted(false);
        user.setVersion(0);
        userMapper.insert(user);
        bindRoles(user.getId(), req.getRoleIds());
        return user.getId();
    }

    /** 更新用户；密码空则不改。 */
    @Transactional
    public void update(long id, UserSaveRequest req, String operator) {
        PlatformUser user = get(id);
        if (StringUtils.hasText(req.getPassword())) {
            user.setPasswordHash(passwordEncoder.encode(req.getPassword()));
        }
        fillUser(user, req);
        user.setUpdater(operator);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
        if (req.getRoleIds() != null) {
            userRoleMapper.delete(new LambdaQueryWrapper<PlatformUserRole>()
                    .eq(PlatformUserRole::getUserId, id));
            bindRoles(id, req.getRoleIds());
        }
    }

    /** 停用/启用。 */
    public void setStatus(long id, String status, String operator) {
        PlatformUser user = get(id);
        user.setStatus(status);
        user.setUpdater(operator);
        user.setUpdateTime(LocalDateTime.now());
        userMapper.updateById(user);
    }

    /** 转为前端安全视图（去掉 passwordHash）。 */
    public Map<String, Object> toView(PlatformUser user) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", user.getId());
        m.put("username", user.getUsername());
        m.put("displayName", user.getDisplayName());
        m.put("mobile", user.getMobile());
        m.put("email", user.getEmail());
        m.put("userType", user.getUserType());
        m.put("status", user.getStatus());
        m.put("deptId", user.getDeptId());
        m.put("createTime", user.getCreateTime());
        List<Long> roleIds = userRoleMapper.selectList(new LambdaQueryWrapper<PlatformUserRole>()
                        .eq(PlatformUserRole::getUserId, user.getId()))
                .stream().map(PlatformUserRole::getRoleId).toList();
        m.put("roleIds", roleIds);
        return m;
    }

    private void fillUser(PlatformUser user, UserSaveRequest req) {
        user.setDisplayName(req.getDisplayName());
        user.setMobile(req.getMobile());
        user.setEmail(req.getEmail());
        user.setUserType(StringUtils.hasText(req.getUserType()) ? req.getUserType() : "INTERNAL");
        user.setDeptId(req.getDeptId());
        if (user.getStatus() == null) {
            user.setStatus("active");
        }
    }

    private void bindRoles(Long userId, List<Long> roleIds) {
        if (roleIds == null) {
            return;
        }
        for (Long roleId : roleIds) {
            PlatformUserRole ur = new PlatformUserRole();
            ur.setUserId(userId);
            ur.setRoleId(roleId);
            ur.setCreateTime(LocalDateTime.now());
            userRoleMapper.insert(ur);
        }
    }
}
