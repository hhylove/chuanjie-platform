import { getHttpClient } from './http'
import type { ApiResponse } from '@cj/shared-types'

/** 用户列表项（不含密码） */
export interface PlatformUserView {
  id: number
  username: string
  displayName: string
  mobile?: string | null
  email?: string | null
  userType: string
  status: string
  deptId?: number | null
  createTime?: string
  roleIds: number[]
}

export interface PageResult<T> {
  list: T[]
  total: number
  pageNo: number
  pageSize: number
}

export interface UserSaveBody {
  username: string
  password?: string
  displayName: string
  mobile?: string
  email?: string
  userType?: string
  deptId?: number | null
  roleIds?: number[]
}

export interface DeptNode {
  id: number
  parentId: number
  name: string
  sortNo: number
  status: string
  children: DeptNode[]
}

export interface DeptSaveBody {
  parentId?: number
  name: string
  sortNo?: number
}

export interface PlatformRole {
  id: number
  code: string
  name: string
  remark?: string | null
  status: string
  dataScope: string
}

export interface RoleSaveBody {
  code: string
  name: string
  remark?: string
  dataScope?: string
}

/** 用户分页 */
export async function listUsersApi(
  pageNo = 1,
  pageSize = 20,
  keyword?: string,
  status = 'active',
): Promise<ApiResponse<PageResult<PlatformUserView>>> {
  const { data } = await getHttpClient().get<ApiResponse<PageResult<PlatformUserView>>>(
    '/admin-api/v1/platform/users',
    { params: { pageNo, pageSize, keyword, status } },
  )
  return data
}

/** 创建用户 */
export async function createUserApi(body: UserSaveBody): Promise<ApiResponse<{ id: number }>> {
  const { data } = await getHttpClient().post<ApiResponse<{ id: number }>>(
    '/admin-api/v1/platform/users',
    body,
  )
  return data
}

/** 更新用户 */
export async function updateUserApi(id: number, body: UserSaveBody): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().put<ApiResponse<null>>(
    `/admin-api/v1/platform/users/${id}`,
    body,
  )
  return data
}

/** 停用 */
export async function disableUserApi(id: number): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>(
    `/admin-api/v1/platform/users/${id}/disable`,
  )
  return data
}

/** 启用 */
export async function enableUserApi(id: number): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>(
    `/admin-api/v1/platform/users/${id}/enable`,
  )
  return data
}

/** 部门树；status: active | disabled | all */
export async function deptTreeApi(status = 'active'): Promise<ApiResponse<DeptNode[]>> {
  const { data } = await getHttpClient().get<ApiResponse<DeptNode[]>>(
    '/admin-api/v1/platform/depts/tree',
    { params: { status } },
  )
  return data
}

/** 新建部门 */
export async function createDeptApi(body: DeptSaveBody): Promise<ApiResponse<{ id: number }>> {
  const { data } = await getHttpClient().post<ApiResponse<{ id: number }>>(
    '/admin-api/v1/platform/depts',
    body,
  )
  return data
}

/** 更新部门 */
export async function updateDeptApi(id: number, body: DeptSaveBody): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().put<ApiResponse<null>>(
    `/admin-api/v1/platform/depts/${id}`,
    body,
  )
  return data
}

/** 停用部门 */
export async function disableDeptApi(id: number): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>(
    `/admin-api/v1/platform/depts/${id}/disable`,
  )
  return data
}

/** 启用部门 */
export async function enableDeptApi(id: number): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>(
    `/admin-api/v1/platform/depts/${id}/enable`,
  )
  return data
}

/** 角色列表；status: active | disabled | all */
export async function listRolesApi(status = 'active'): Promise<ApiResponse<PlatformRole[]>> {
  const { data } = await getHttpClient().get<ApiResponse<PlatformRole[]>>(
    '/admin-api/v1/platform/roles',
    { params: { status } },
  )
  return data
}

/** 新建角色 */
export async function createRoleApi(body: RoleSaveBody): Promise<ApiResponse<{ id: number }>> {
  const { data } = await getHttpClient().post<ApiResponse<{ id: number }>>(
    '/admin-api/v1/platform/roles',
    body,
  )
  return data
}

/** 更新角色 */
export async function updateRoleApi(id: number, body: RoleSaveBody): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().put<ApiResponse<null>>(
    `/admin-api/v1/platform/roles/${id}`,
    body,
  )
  return data
}

/** 停用角色 */
export async function disableRoleApi(id: number): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>(
    `/admin-api/v1/platform/roles/${id}/disable`,
  )
  return data
}

/** 启用角色 */
export async function enableRoleApi(id: number): Promise<ApiResponse<null>> {
  const { data } = await getHttpClient().post<ApiResponse<null>>(
    `/admin-api/v1/platform/roles/${id}/enable`,
  )
  return data
}
