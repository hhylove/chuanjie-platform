package com.chuanjie.platform.platform.biz.web.dto;

import jakarta.validation.constraints.NotBlank;

/** 部门保存请求。 */
public class DeptSaveRequest {
    /** 上级部门，根传 0 */
    private Long parentId = 0L;
    @NotBlank(message = "部门名称不能为空")
    private String name;
    private Integer sortNo = 0;

    public Long getParentId() { return parentId; }
    public void setParentId(Long parentId) { this.parentId = parentId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getSortNo() { return sortNo; }
    public void setSortNo(Integer sortNo) { this.sortNo = sortNo; }
}
