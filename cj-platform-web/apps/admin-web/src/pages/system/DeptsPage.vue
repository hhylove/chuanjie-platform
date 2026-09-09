<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  createDeptApi,
  deptTreeApi,
  disableDeptApi,
  enableDeptApi,
  updateDeptApi,
  type DeptNode,
  type DeptSaveBody,
} from '@cj/api-client'

const loading = ref(false)
const tree = ref<DeptNode[]>([])
/** 默认启用中；all 可看停用 */
const statusFilter = ref('active')
const dialogVisible = ref(false)
const editingId = ref<number | null>(null)
const parentId = ref<number | null>(null)
const form = reactive({
  name: '',
  sortNo: 0,
})

const parentTreeData = computed(() => {
  const base = statusFilter.value === 'active' ? tree.value : tree.value
  if (editingId.value == null) return base
  return filterOutSelf(base, editingId.value)
})

function filterOutSelf(nodes: DeptNode[], selfId: number): DeptNode[] {
  return nodes
    .filter((n) => n.id !== selfId)
    .map((n) => ({
      ...n,
      children: n.children?.length ? filterOutSelf(n.children, selfId) : [],
    }))
}

async function loadTree(): Promise<void> {
  loading.value = true
  try {
    const resp = await deptTreeApi(statusFilter.value)
    if (resp.code !== 0) {
      ElMessage.error(resp.message || '加载失败')
      return
    }
    tree.value = resp.data
  } finally {
    loading.value = false
  }
}

function openCreateRoot(): void {
  editingId.value = null
  parentId.value = null
  form.name = ''
  form.sortNo = 0
  dialogVisible.value = true
}

function openCreateChild(node: DeptNode): void {
  editingId.value = null
  parentId.value = node.id
  form.name = ''
  form.sortNo = 0
  dialogVisible.value = true
}

function openEdit(node: DeptNode): void {
  editingId.value = node.id
  parentId.value = node.parentId === 0 ? null : node.parentId
  form.name = node.name
  form.sortNo = node.sortNo
  dialogVisible.value = true
}

async function handleSave(): Promise<void> {
  if (!form.name?.trim()) {
    ElMessage.warning('请填写部门名称')
    return
  }
  const body: DeptSaveBody = {
    parentId: parentId.value ?? 0,
    name: form.name.trim(),
    sortNo: form.sortNo ?? 0,
  }
  const resp =
    editingId.value == null ? await createDeptApi(body) : await updateDeptApi(editingId.value, body)
  if (resp.code !== 0) {
    ElMessage.error(resp.message || '保存失败')
    return
  }
  ElMessage.success('已保存')
  dialogVisible.value = false
  await loadTree()
}

async function handleToggle(node: DeptNode): Promise<void> {
  const disable = node.status === 'active'
  await ElMessageBox.confirm(
    disable ? `确认停用「${node.name}」？停用后默认列表不再显示。` : `确认启用「${node.name}」？`,
    '提示',
  )
  const resp = disable ? await disableDeptApi(node.id) : await enableDeptApi(node.id)
  if (resp.code !== 0) {
    ElMessage.error(resp.message || '操作失败')
    return
  }
  ElMessage.success('已更新状态')
  await loadTree()
}

onMounted(loadTree)
</script>

<template>
  <section class="panel">
    <header class="head">
      <div>
        <h2>部门管理</h2>
        <p class="sub">默认只显示启用中的部门；可筛选已停用。不物理删除。</p>
      </div>
      <div class="actions">
        <el-select v-model="statusFilter" style="width: 130px" @change="loadTree">
          <el-option label="启用中" value="active" />
          <el-option label="已停用" value="disabled" />
          <el-option label="全部" value="all" />
        </el-select>
        <el-button type="primary" @click="openCreateRoot">新建根部门</el-button>
      </div>
    </header>

    <el-tree
      v-loading="loading"
      :data="tree"
      node-key="id"
      default-expand-all
      :props="{ label: 'name', children: 'children' }"
    >
      <template #default="{ data }">
        <div class="node-row">
          <span>
            {{ data.name }}
            <el-tag v-if="data.status === 'disabled'" size="small" type="info" class="tag">已停用</el-tag>
          </span>
          <span class="ops">
            <el-button link type="primary" @click.stop="openCreateChild(data)">添加下级</el-button>
            <el-button link type="primary" @click.stop="openEdit(data)">编辑</el-button>
            <el-button link type="warning" @click.stop="handleToggle(data)">
              {{ data.status === 'active' ? '停用' : '启用' }}
            </el-button>
          </span>
        </div>
      </template>
    </el-tree>

    <el-dialog
      v-model="dialogVisible"
      :title="editingId == null ? '新建部门' : '编辑部门'"
      width="460px"
    >
      <el-form label-position="top">
        <el-form-item label="上级部门">
          <el-tree-select
            v-model="parentId"
            :data="parentTreeData"
            check-strictly
            clearable
            filterable
            :render-after-expand="false"
            placeholder="不选则作为根部门"
            :props="{ label: 'name', value: 'id', children: 'children' }"
            style="width: 100%"
          />
          <p class="hint">不选择上级 = 根部门；从树上点「添加下级」会自动带上当前部门。</p>
        </el-form-item>
        <el-form-item label="部门名称" required>
          <el-input v-model="form.name" placeholder="例如：市场部" maxlength="64" show-word-limit />
        </el-form-item>
        <el-form-item label="显示顺序">
          <el-input-number v-model="form.sortNo" :min="0" style="width: 100%" />
          <p class="hint">数字越小越靠前，一般保持 0 即可。</p>
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

.node-row {
  flex: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-right: 8px;
  gap: 8px;
}

.tag {
  margin-left: 8px;
}

.ops {
  opacity: 0.85;
  flex-shrink: 0;
}

.hint {
  margin: 6px 0 0;
  font-size: 0.78rem;
  color: var(--cj-text-muted);
  line-height: 1.4;
}
</style>
