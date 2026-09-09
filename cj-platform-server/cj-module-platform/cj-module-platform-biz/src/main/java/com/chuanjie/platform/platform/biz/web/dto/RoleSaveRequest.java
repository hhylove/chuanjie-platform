package com.chuanjie.platform.platform.biz.web.dto;

import jakarta.validation.constraints.NotBlank;

/** 角色保存请求。 */
public class RoleSaveRequest {
    @NotBlank(message = "角色编码不能为空")
    private String code;
    @NotBlank(message = "角色名称不能为空")
    private String name;
    private String remark;
    /** SELF / DEPT / ALL */
    private String dataScope = "SELF";

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public String getDataScope() { return dataScope; }
    public void setDataScope(String dataScope) { this.dataScope = dataScope; }
}
