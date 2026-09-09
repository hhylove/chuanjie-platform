package com.chuanjie.platform.platform.biz.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.chuanjie.platform.framework.error.BizException;
import com.chuanjie.platform.platform.biz.domain.PlatformDept;
import com.chuanjie.platform.platform.biz.error.PlatformErrorCodes;
import com.chuanjie.platform.platform.biz.mapper.PlatformDeptMapper;
import com.chuanjie.platform.platform.biz.web.dto.DeptSaveRequest;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 部门树维护。 */
@Service
public class DeptAdminService {

    private final PlatformDeptMapper deptMapper;

    public DeptAdminService(PlatformDeptMapper deptMapper) {
        this.deptMapper = deptMapper;
    }

    public List<PlatformDept> listAll() {
        return listAll(null);
    }

    /**
     * 列表；status 为空查全部，否则按 active/disabled 过滤。
     * 默认业务侧传 active，已停用需显式筛选。
     */
    public List<PlatformDept> listAll(String status) {
        LambdaQueryWrapper<PlatformDept> q = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(status)) {
            q.eq(PlatformDept::getStatus, status);
        }
        q.orderByAsc(PlatformDept::getSortNo).orderByAsc(PlatformDept::getId);
        return deptMapper.selectList(q);
    }

    /** 组装树；status 默认 active。 */
    public List<Map<String, Object>> tree(String status) {
        String filter = StringUtils.hasText(status) ? status : "active";
        // all = 查全部时不过滤，便于管理端看停用节点
        List<PlatformDept> all = "all".equalsIgnoreCase(filter) ? listAll(null) : listAll(filter);
        Map<Long, Map<String, Object>> nodes = new HashMap<>();
        for (PlatformDept d : all) {
            Map<String, Object> n = new HashMap<>();
            n.put("id", d.getId());
            n.put("parentId", d.getParentId());
            n.put("name", d.getName());
            n.put("sortNo", d.getSortNo());
            n.put("status", d.getStatus());
            n.put("children", new ArrayList<Map<String, Object>>());
            nodes.put(d.getId(), n);
        }
        List<Map<String, Object>> roots = new ArrayList<>();
        for (PlatformDept d : all) {
            Map<String, Object> n = nodes.get(d.getId());
            Long parentId = d.getParentId() == null ? 0L : d.getParentId();
            if (parentId == 0L || !nodes.containsKey(parentId)) {
                roots.add(n);
            } else {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> children = (List<Map<String, Object>>) nodes.get(parentId).get("children");
                children.add(n);
            }
        }
        return roots;
    }

    /** 停用/启用部门（非物理删除）。 */
    public void setStatus(long id, String status, String operator) {
        PlatformDept dept = deptMapper.selectById(id);
        if (dept == null) {
            throw new BizException(PlatformErrorCodes.DEPT_NOT_FOUND, "部门不存在");
        }
        dept.setStatus(status);
        dept.setUpdater(operator);
        dept.setUpdateTime(LocalDateTime.now());
        deptMapper.updateById(dept);
    }

    public Long create(DeptSaveRequest req, String operator) {
        PlatformDept dept = new PlatformDept();
        dept.setParentId(req.getParentId() == null ? 0L : req.getParentId());
        dept.setName(req.getName());
        dept.setSortNo(req.getSortNo() == null ? 0 : req.getSortNo());
        dept.setStatus("active");
        dept.setCreator(operator);
        dept.setCreateTime(LocalDateTime.now());
        dept.setUpdater(operator);
        dept.setUpdateTime(LocalDateTime.now());
        dept.setDeleted(false);
        dept.setVersion(0);
        deptMapper.insert(dept);
        return dept.getId();
    }

    public void update(long id, DeptSaveRequest req, String operator) {
        PlatformDept dept = deptMapper.selectById(id);
        if (dept == null) {
            throw new BizException(PlatformErrorCodes.DEPT_NOT_FOUND, "部门不存在");
        }
        dept.setParentId(req.getParentId() == null ? 0L : req.getParentId());
        dept.setName(req.getName());
        if (req.getSortNo() != null) {
            dept.setSortNo(req.getSortNo());
        }
        dept.setUpdater(operator);
        dept.setUpdateTime(LocalDateTime.now());
        deptMapper.updateById(dept);
    }
}
