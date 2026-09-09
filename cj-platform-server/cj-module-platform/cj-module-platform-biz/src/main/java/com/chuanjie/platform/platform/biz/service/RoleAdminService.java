package com.chuanjie.platform.platform.biz.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.chuanjie.platform.framework.error.BizException;
import com.chuanjie.platform.platform.biz.domain.PlatformRole;
import com.chuanjie.platform.platform.biz.error.PlatformErrorCodes;
import com.chuanjie.platform.platform.biz.mapper.PlatformRoleMapper;
import com.chuanjie.platform.platform.biz.web.dto.RoleSaveRequest;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/** 角色维护。 */
@Service
public class RoleAdminService {

    private final PlatformRoleMapper roleMapper;

    public RoleAdminService(PlatformRoleMapper roleMapper) {
        this.roleMapper = roleMapper;
    }

    public List<PlatformRole> listAll() {
        return listAll(null);
    }

    /**
     * 角色列表；status 为空查全部，否则按状态过滤。
     * 业务默认传 active。
     */
    public List<PlatformRole> listAll(String status) {
        LambdaQueryWrapper<PlatformRole> q = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(status) && !"all".equalsIgnoreCase(status)) {
            q.eq(PlatformRole::getStatus, status);
        }
        q.orderByAsc(PlatformRole::getId);
        return roleMapper.selectList(q);
    }

    /** 停用/启用角色（非物理删除）。 */
    public void setStatus(long id, String status, String operator) {
        PlatformRole role = roleMapper.selectById(id);
        if (role == null) {
            throw new BizException(PlatformErrorCodes.ROLE_NOT_FOUND, "角色不存在");
        }
        if ("ADMIN".equalsIgnoreCase(role.getCode()) && "disabled".equalsIgnoreCase(status)) {
            throw new BizException(PlatformErrorCodes.ROLE_PROTECTED, "系统管理员角色不可停用");
        }
        role.setStatus(status);
        role.setUpdater(operator);
        role.setUpdateTime(LocalDateTime.now());
        roleMapper.updateById(role);
    }

    public Long create(RoleSaveRequest req, String operator) {
        PlatformRole role = new PlatformRole();
        role.setCode(req.getCode());
        role.setName(req.getName());
        role.setRemark(req.getRemark());
        role.setDataScope(StringUtils.hasText(req.getDataScope()) ? req.getDataScope() : "SELF");
        role.setStatus("active");
        role.setCreator(operator);
        role.setCreateTime(LocalDateTime.now());
        role.setUpdater(operator);
        role.setUpdateTime(LocalDateTime.now());
        role.setDeleted(false);
        role.setVersion(0);
        roleMapper.insert(role);
        return role.getId();
    }

    public void update(long id, RoleSaveRequest req, String operator) {
        PlatformRole role = roleMapper.selectById(id);
        if (role == null) {
            throw new BizException(PlatformErrorCodes.ROLE_NOT_FOUND, "角色不存在");
        }
        role.setCode(req.getCode());
        role.setName(req.getName());
        role.setRemark(req.getRemark());
        if (StringUtils.hasText(req.getDataScope())) {
            role.setDataScope(req.getDataScope());
        }
        role.setUpdater(operator);
        role.setUpdateTime(LocalDateTime.now());
        roleMapper.updateById(role);
    }
}
