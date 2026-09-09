/** 当前会话选择的租户成员身份。 */
export interface TenantSelection {
  /** 租户唯一标识，仅用于本地展示；后端仍以受信会话为准。 */
  tenantId: string;
  /** 当前自然人在该租户内的成员标识。 */
  membershipId: string;
}

/** 租户上下文切换时需要清理的外部状态。 */
export interface TenantContextDependencies {
  /** 清理权限、菜单、查询缓存等租户范围数据。 */
  clearTenantCache?: () => void;
}

/**
 * 创建前端租户上下文。
 *
 * <p>这里不生成可提交给后端的tenantId请求头。真正的租户身份必须由后端
 * 根据已签名会话恢复，前端只保留当前成员提示。</p>
 */
export function createTenantContext(dependencies: TenantContextDependencies = {}) {
  let selection: TenantSelection | null = null;

  return {
    current(): TenantSelection | null {
      return selection === null ? null : { ...selection };
    },

    select(next: TenantSelection): void {
      if (selection !== null &&
          (selection.tenantId !== next.tenantId || selection.membershipId !== next.membershipId)) {
        dependencies.clearTenantCache?.();
      }
      selection = { ...next };
    },

    clear(): void {
      if (selection !== null) {
        dependencies.clearTenantCache?.();
      }
      selection = null;
    },

    sessionHint(): { membershipId: string } | null {
      return selection === null ? null : { membershipId: selection.membershipId };
    },
  };
}
