<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { getHealth, getPing } from '@cj/api-client'
import type { ApiResponse } from '@cj/shared-types'
import type { PingData } from '@cj/api-client'

const healthText = ref('未检测')
const pingText = ref('未检测')
const loading = ref(false)
const errorText = ref('')

onMounted(() => {
  // 布局已拉取当前用户
})

async function handleCheck(): Promise<void> {
  loading.value = true
  errorText.value = ''
  try {
    const health = await getHealth()
    healthText.value = health.status
    const ping: ApiResponse<PingData> = await getPing()
    pingText.value = JSON.stringify(ping)
  } catch (err) {
    errorText.value = err instanceof Error ? err.message : '请求失败'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="workbench">
    <header class="wb-head">
      <div>
        <h2>工作台</h2>
        <p class="desc">欢迎使用创界云枢。可从左侧进入用户 / 部门 / 角色管理。</p>
      </div>
      <button type="button" class="probe" :disabled="loading" @click="handleCheck">
        {{ loading ? '检测中…' : '检测后端' }}
      </button>
    </header>
    <div class="wb-cards">
      <div class="card">
        <span class="label">服务状态</span>
        <strong>{{ healthText }}</strong>
      </div>
      <div class="card wide">
        <span class="label">Ping</span>
        <strong class="mono">{{ pingText }}</strong>
      </div>
    </div>
    <p v-if="errorText" class="err">{{ errorText }}</p>
  </section>
</template>

<style scoped>
.workbench {
  background: var(--cj-surface-solid);
  border: 1px solid var(--cj-line);
  border-radius: 10px;
  padding: 18px 20px;
  min-height: 360px;
}

.wb-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

h2 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 700;
}

.desc {
  margin: 8px 0 0;
  color: var(--cj-text-muted);
  line-height: 1.55;
  font-size: 0.92rem;
}

.probe {
  border: 0;
  border-radius: 8px;
  padding: 9px 14px;
  font: inherit;
  font-weight: 600;
  font-size: 0.88rem;
  color: #fff;
  background: var(--cj-accent);
  cursor: pointer;
  white-space: nowrap;
}

.probe:disabled {
  opacity: 0.65;
  cursor: wait;
}

.wb-cards {
  display: grid;
  grid-template-columns: 180px 1fr;
  gap: 12px;
}

.card {
  border: 1px solid var(--cj-line);
  border-radius: 10px;
  padding: 14px 16px;
  background: color-mix(in srgb, var(--cj-paper) 70%, var(--cj-surface-solid));
  display: grid;
  gap: 8px;
}

.card .label {
  font-size: 0.78rem;
  color: var(--cj-text-muted);
}

.card strong {
  font-size: 1.05rem;
  word-break: break-all;
}

.mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 0.85rem !important;
  font-weight: 500 !important;
}

.err {
  color: #b42318;
  margin-top: 12px;
}

@media (max-width: 720px) {
  .wb-head {
    flex-direction: column;
  }

  .wb-cards {
    grid-template-columns: 1fr;
  }
}
</style>
