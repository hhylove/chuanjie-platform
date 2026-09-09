<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  createUserApi,
  disableUserApi,
  enableUserApi,
  listRolesApi,
  listUsersApi,
  updateUserApi,
  deptTreeApi,
  type DeptNode,
  type PlatformRole,
  type PlatformUserView,
  type UserSaveBody,
} from '@cj/api-client'

const loading = ref(false)
const keyword = ref('')
/** 默认只看启用中；可选 disabled / all */
const statusFilter = ref('active')
const pageNo = ref(1)
const pageSize = ref(10)
const total = ref(0)
const list = ref<PlatformUserView[]>([])
const roles = ref<PlatformRole[]>([])
const depts = ref<DeptNode[]>([])

const dialogVisible = ref(false)
const editingId = ref<number | null>(null)
const form = reactive<UserSaveBody>({
  username: '',
  password: '',
  displayName: '',
  mobile: '',
  email: '',
  userType: 'INTERNAL',
  deptId: null,
  roleIds: [],
})

function flattenDepts(nodes: DeptNode[], acc: { id: number; name: string }[] = [], prefix = ''): { id: number; name: string }[] {
  for (const n of nodes) {
    acc.push({ id: n.id, name: `${prefix}${n.name}` })
    if (n.children?.length) {
      flattenDepts(n.children, acc, `${prefix}${n.name} / `)
    }
  }
  return acc
}

const deptOptions = ref<{ id: number; name: string }[]>([])

async function loadMeta(): Promise<void> {
  const [roleResp, deptResp] = await Promise.all([listRolesApi('all'), deptTreeApi('active')])
  if (roleResp.code === 0) roles.value = roleResp.data.filter((r) => r.status === 'active')
  if (deptResp.code === 0) {
    depts.value = deptResp.data
    deptOptions.value = flattenDepts(deptResp.data)
  }
}

async function loadList(): Promise<void> {
  loading.value = true
  try {
    const resp = await listUsersApi(
      pageNo.value,
      pageSize.value,
      keyword.value || undefined,
      statusFilter.value,
    )
    if (resp.code !== 0) {
      ElMessage.error(resp.message || '加载失败')
      return
    }
    list.value = resp.data.list
    total.value = resp.data.total
  } finally {
    loading.value = false
  }
}

function handleStatusChange(): void {
  pageNo.value = 1
  void loadList()
}

function openCreate(): void {
  editingId.value = null
  form.username = ''
  form.password = ''
  form.displayName = ''
  form.mobile = ''
  form.email = ''
  form.userType = 'INTERNAL'
  form.deptId = deptOptions.value[0]?.id ?? null
  form.roleIds = roles.value[0] ? [roles.value[0].id] : []
  dialogVisible.value = true
}

function openEdit(row: PlatformUserView): void {
  editingId.value = row.id
  form.username = row.username
  form.password = ''
  form.displayName = row.displayName
  form.mobile = row.mobile ?? ''
  form.email = row.email ?? ''
  form.userType = row.userType
  form.deptId = row.deptId ?? null
  form.roleIds = [...(row.roleIds ?? [])]
  dialogVisible.value = true
}

async function handleSave(): Promise<void> {
  if (!form.username.trim() || !form.displayName.trim()) {
    ElMessage.warning('账号与显示名必填')
    return
  }
  if (editingId.value == null && !form.password) {
    ElMessage.warning('新建时密码必填')
    return
  }
  const body: UserSaveBody = {
    username: form.username.trim(),
    displayName: form.displayName.trim(),
    mobile: form.mobile || undefined,
    email: form.email || undefined,
    userType: form.userType,
    deptId: form.deptId,
    roleIds: form.roleIds,
  }
  if (form.password) body.password = form.password

  const resp =
    editingId.value == null
      ? await createUserApi(body)
      : await updateUserApi(editingId.value, body)
  if (resp.code !== 0) {
    ElMessage.error(resp.message || '保存失败')
    return
  }
  ElMessage.success('已保存')
  dialogVisible.value = false
  await loadList()
}

async function handleToggle(row: PlatformUserView): Promise<void> {
  const disable = row.status === 'active'
  await ElMessageBox.confirm(
    disable ? `确认停用 ${row.username}？` : `确认启用 ${row.username}？`,
    '提示',
  )
  const resp = disable ? await disableUserApi(row.id) : await enableUserApi(row.id)
  if (resp.code !== 0) {
    ElMessage.error(resp.message || '操作失败')
    return
  }
  ElMessage.success('已更新状态')
  await loadList()
}

function roleLabel(ids: number[]): string {
  if (!ids?.length) return '—'
  const map = new Map(roles.value.map((r) => [r.id, r.name]))
  return ids.map((id) => map.get(id) ?? String(id)).join('、')
}

onMounted(async () => {
  await loadMeta()
  await loadList()
})
</script>

<template>
  <section class="panel">
    <header class="head">
      <h2>用户管理</h2>
      <div class="actions">
        <el-select v-model="statusFilter" style="width: 130px" @change="handleStatusChange">
          <el-option label="启用中" value="active" />
          <el-option label="已停用" value="disabled" />
          <el-option label="全部" value="all" />
        </el-select>
        <el-input v-model="keyword" clearable placeholder="账号/显示名" style="width: 200px" @keyup.enter="loadList" />
        <el-button @click="loadList">查询</el-button>
        <el-button type="primary" @click="openCreate">新建</el-button>
      </div>
    </header>

    <el-table v-loading="loading" :data="list" stripe>
      <el-table-column prop="username" label="账号" min-width="110" />
      <el-table-column prop="displayName" label="显示名" min-width="120" />
      <el-table-column label="角色" min-width="140">
        <template #default="{ row }">{{ roleLabel(row.roleIds) }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="90" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button link type="warning" @click="handleToggle(row)">
            {{ row.status === 'active' ? '停用' : '启用' }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <div class="pager">
      <el-pagination
        v-model:current-page="pageNo"
        v-model:page-size="pageSize"
        layout="total, prev, pager, next"
        :total="total"
        @current-change="loadList"
      />
    </div>

    <el-dialog v-model="dialogVisible" :title="editingId == null ? '新建用户' : '编辑用户'" width="480px">
      <el-form label-position="top">
        <el-form-item label="账号">
          <el-input v-model="form.username" :disabled="editingId != null" />
        </el-form-item>
        <el-form-item :label="editingId == null ? '密码' : '密码（空则不改）'">
          <el-input v-model="form.password" type="password" show-password />
        </el-form-item>
        <el-form-item label="显示名">
          <el-input v-model="form.displayName" />
        </el-form-item>
        <el-form-item label="部门">
          <el-select v-model="form.deptId" clearable style="width: 100%">
            <el-option v-for="d in deptOptions" :key="d.id" :label="d.name" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="form.roleIds" multiple style="width: 100%">
            <el-option v-for="r in roles" :key="r.id" :label="r.name" :value="r.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </section>
</template>

<style scoped>
.panel {
  padding: 16px 18px;
  border-radius: 10px;
  border: 1px solid var(--cj-line);
  background: var(--cj-surface-solid);
}

.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

h2 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
}

.actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.pager {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
