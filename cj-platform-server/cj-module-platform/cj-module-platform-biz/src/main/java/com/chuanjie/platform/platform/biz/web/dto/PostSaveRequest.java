package com.chuanjie.platform.platform.biz.web.dto;

import jakarta.validation.constraints.NotBlank;

/** 岗位保存请求。 */
public class PostSaveRequest {
    @NotBlank(message = "岗位编码不能为空")
    private String code;
    @NotBlank(message = "岗位名称不能为空")
    private String name;
    private Integer sortNo = 0;

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getSortNo() { return sortNo; }
    public void setSortNo(Integer sortNo) { this.sortNo = sortNo; }
}
