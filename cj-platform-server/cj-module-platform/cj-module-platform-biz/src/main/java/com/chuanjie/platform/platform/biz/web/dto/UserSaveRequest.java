package com.chuanjie.platform.platform.biz.web.dto;

import jakarta.validation.constraints.NotBlank;

/** 创建/更新用户请求。 */
public class UserSaveRequest {
    /** 登录账号（创建必填） */
    @NotBlank(message = "账号不能为空")
    private String username;
    /** 明文密码（创建必填；更新时可空表示不改） */
    private String password;
    /** 显示名 */
    @NotBlank(message = "显示名不能为空")
    private String displayName;
    private String mobile;
    private String email;
    /** 默认 INTERNAL */
    private String userType = "INTERNAL";
    private Long deptId;
    /** 角色 ID 列表 */
    private java.util.List<Long> roleIds;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public java.util.List<Long> getRoleIds() { return roleIds; }
    public void setRoleIds(java.util.List<Long> roleIds) { this.roleIds = roleIds; }
}
