<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  createRoleApi,
  disableRoleApi,
  enableRoleApi,
  listRolesApi,
  updateRoleApi,
  type PlatformRole,
  type RoleSaveBody,
} from '@cj/api-client'

const loading = ref(false)
const list = ref<PlatformRole[]>([])
const statusFilter = ref('active')
const dialogVisible = ref(false)
const editingId = ref<number | null>(null)
const form = reactive<RoleSaveBody>({
  code: '',
  name: '',
  remark: '',
  dataScope: 'SELF',
})

async function loadList(): Promise<void> {
  loading.value = true
  try {
    const resp = await listRolesApi(statusFilter.value)
    if (resp.code !== 0) {
      ElMessage.error(resp.message || '加载失败')
      return
    }
    list.value = resp.data
  } finally {
    loading.value = false
  }
}

function openCreate(): void {
  editingId.value = null
  form.code = ''
  form.name = ''
  form.remark = ''
  form.dataScope = 'SELF'
  dialogVisible.value = true
}

function openEdit(row: PlatformRole): void {
  editingId.value = row.id
  form.code = row.code
  form.name = row.name
  form.remark = row.remark ?? ''
  form.dataScope = row.dataScope || 'SELF'
  dialogVisible.value = true
}

async function handleSave(): Promise<void> {
  if (!form.code.trim() || !form.name.trim()) {
    ElMessage.warning('编码与名称必填')
    return
  }
  const body: RoleSaveBody = {
    code: form.code.trim(),
    name: form.name.trim(),
    remark: form.remark,
    dataScope: form.dataScope,
  }
  const resp =
    editingId.value == null ? await createRoleApi(body) : await updateRoleApi(editingId.value, body)
  if (resp.code !== 0) {
    ElMessage.error(resp.message || '保存失败')
    return
  }
  ElMessage.success('已保存')
  dialogVisible.value = false
  await loadList()
}

async function handleToggle(row: PlatformRole): Promise<void> {
  const disable = row.status === 'active'
  await ElMessageBox.confirm(
    disable ? `确认停用角色「${row.name}」？` : `确认启用角色「${row.name}」？`,
    '提示',
  )
  const resp = disable ? await disableRoleApi(row.id) : await enableRoleApi(row.id)
  if (resp.code !== 0) {
    ElMessage.error(resp.message || '操作失败')
    return
  }
  ElMessage.success('已更新状态')
  await loadList()
}

onMounted(loadList)
</script>

<template>
  <section class="panel">
    <header class="head">
      <div>
        <h2>角色管理</h2>
        <p class="sub">默认只显示启用中的角色；系统管理员角色不可停用。</p>
      </div>
      <div class="actions">
        <el-select v-model="statusFilter" style="width: 130px" @change="loadList">
          <el-option label="启用中" value="active" />
          <el-option label="已停用" value="disabled" />
          <el-option label="全部" value="all" />
        </el-select>
        <el-button type="primary" @click="openCreate">新建角色</el-button>
      </div>
    </header>

    <el-table v-loading="loading" :data="list" stripe>
      <el-table-column prop="code" label="编码" min-width="120" />
      <el-table-column prop="name" label="名称" min-width="140" />
      <el-table-column prop="dataScope" label="数据范围" width="120" />
      <el-table-column prop="status" label="状态" width="90" />
      <el-table-column prop="remark" label="备注" min-width="160" />
      <el-table-column label="操作" width="160" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          <el-button
            link
            type="warning"
            :disabled="row.code === 'ADMIN'"
            @click="handleToggle(row)"
          >
            {{ row.status === 'active' ? '停用' : '启用' }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="editingId == null ? '新建角色' : '编辑角色'" width="460px">
      <el-form label-position="top">
        <el-form-item label="编码">
          <el-input v-model="form.code" :disabled="editingId != null" />
        </el-form-item>
        <el-form-item label="名称">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="数据范围">
          <el-select v-model="form.dataScope" style="width: 100%">
            <el-option label="本人 SELF" value="SELF" />
            <el-option label="本部门 DEPT" value="DEPT" />
            <el-option label="全部 ALL" value="ALL" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" />
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
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 14px;
}

.actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

h2 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
}

.sub {
  margin: 6px 0 0;
  font-size: 0.88rem;
  color: var(--cj-text-muted);
}
</style>
