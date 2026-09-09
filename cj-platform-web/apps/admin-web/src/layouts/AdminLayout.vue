<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter, type RouteLocationNormalizedLoaded } from 'vue-router'
import { ElMessage } from 'element-plus'
import { logoutApi, meApi, type AuthUserSummary } from '@cj/api-client'
import { clearAuthTokens, getRefreshToken } from '@cj/auth'
import ThemeSwitcher from '../components/ThemeSwitcher.vue'

type NavLeaf = { to: string; name: string; title: string }
type NavGroup = { key: string; title: string; children: NavLeaf[] }
type TabItem = { name: string; path: string; title: string }

const route = useRoute()
const router = useRouter()
const me = ref<AuthUserSummary | null>(null)
const openGroups = ref<string[]>(['org'])

/** 顶层仅一条「工作台」，避免分组再套一层同名菜单 */
const homeLink: NavLeaf = { to: '/', name: 'home', title: '工作台' }
const navGroups: NavGroup[] = [
  {
    key: 'org',
    title: '组织管理',
    children: [
      { to: '/system/users', name: 'users', title: '用户管理' },
      { to: '/system/depts', name: 'depts', title: '部门管理' },
      { to: '/system/roles', name: 'roles', title: '角色管理' },
    ],
  },
]

const tabs = ref<TabItem[]>([{ name: 'home', path: '/', title: '工作台' }])

const activeName = computed(() => String(route.name ?? ''))
const pageTitle = computed(() => String(route.meta.title ?? '工作台'))
const crumbs = computed(() => {
  const group = String(route.meta.groupTitle ?? '')
  const title = pageTitle.value
  if (!group || group === title) {
    return [{ label: '首页' }, { label: title }]
  }
  return [{ label: '首页' }, { label: group }, { label: title }]
})

function toggleGroup(key: string): void {
  if (openGroups.value.includes(key)) {
    openGroups.value = openGroups.value.filter((k) => k !== key)
  } else {
    openGroups.value = [...openGroups.value, key]
  }
}

function ensureTab(r: RouteLocationNormalizedLoaded): void {
  const name = String(r.name ?? '')
  if (!name) return
  const title = String(r.meta.title ?? name)
  const path = r.path
  if (!tabs.value.some((t) => t.name === name)) {
    tabs.value.push({ name, path, title })
  }
  const groupKey = String(r.meta.groupKey ?? '')
  if (groupKey && groupKey !== 'work' && !openGroups.value.includes(groupKey)) {
    openGroups.value = [...openGroups.value, groupKey]
  }
}

watch(
  () => route.fullPath,
  () => ensureTab(route),
  { immediate: true },
)

async function goTab(tab: TabItem): Promise<void> {
  if (tab.name === activeName.value) return
  await router.push(tab.path)
}

async function closeTab(tab: TabItem, event: Event): Promise<void> {
  event.stopPropagation()
  if (tab.name === 'home') return
  const idx = tabs.value.findIndex((t) => t.name === tab.name)
  if (idx < 0) return
  const wasActive = tab.name === activeName.value
  tabs.value.splice(idx, 1)
  if (wasActive) {
    const next = tabs.value[Math.max(0, idx - 1)] ?? tabs.value[0]
    await router.push(next.path)
  }
}

onMounted(async () => {
  try {
    const resp = await meApi()
    if (resp.code === 0) {
      me.value = resp.data
    } else {
      clearAuthTokens()
      await router.replace({ name: 'login' })
    }
  } catch {
    clearAuthTokens()
    await router.replace({ name: 'login' })
  }
})

async function handleLogout(): Promise<void> {
  try {
    await logoutApi(getRefreshToken())
  } catch {
    // 忽略
  }
  clearAuthTokens()
  ElMessage.success('已退出')
  await router.replace({ name: 'login' })
}
</script>

<template>
  <div class="oa">
    <header class="oa-header">
      <div class="brand">
        <span class="brand-mark" aria-hidden="true" />
        <div class="brand-text">
          <strong>创界云枢</strong>
          <span>网络办公系统</span>
        </div>
      </div>
      <div class="header-right">
        <ThemeSwitcher />
        <div class="who">
          <span class="avatar">{{ (me?.displayName || me?.username || 'U').slice(0, 1) }}</span>
          <div class="who-meta">
            <span class="who-name">{{ me?.displayName || me?.username || '…' }}</span>
            <span v-if="me?.username" class="who-id">{{ me.username }}</span>
          </div>
        </div>
        <button type="button" class="logout-btn" @click="handleLogout">退出</button>
      </div>
    </header>

    <div class="oa-body">
      <aside class="oa-aside" aria-label="主导航">
        <RouterLink
          :to="homeLink.to"
          class="nav-item nav-item--top"
          :class="{ active: activeName === homeLink.name }"
        >
          {{ homeLink.title }}
        </RouterLink>

        <div v-for="group in navGroups" :key="group.key" class="nav-group">
          <button
            type="button"
            class="nav-group-title"
            :aria-expanded="openGroups.includes(group.key)"
            @click="toggleGroup(group.key)"
          >
            <span>{{ group.title }}</span>
            <span class="chev" :class="{ open: openGroups.includes(group.key) }">▾</span>
          </button>
          <div v-show="openGroups.includes(group.key)" class="nav-children">
            <RouterLink
              v-for="item in group.children"
              :key="item.name"
              :to="item.to"
              class="nav-item"
              :class="{ active: activeName === item.name }"
            >
              {{ item.title }}
            </RouterLink>
          </div>
        </div>
      </aside>

      <div class="oa-main">
        <div class="oa-tabs" role="tablist" aria-label="已打开页面">
          <button
            v-for="tab in tabs"
            :key="tab.name"
            type="button"
            class="tab"
            role="tab"
            :aria-selected="activeName === tab.name"
            :class="{ active: activeName === tab.name }"
            @click="goTab(tab)"
          >
            <span>{{ tab.title }}</span>
            <span
              v-if="tab.name !== 'home'"
              class="tab-close"
              title="关闭"
              @click="closeTab(tab, $event)"
            >×</span>
          </button>
        </div>

        <nav class="oa-crumb" aria-label="面包屑">
          <span v-for="(c, i) in crumbs" :key="`${c.label}-${i}`" class="crumb-item">
            <span v-if="i > 0" class="sep">/</span>
            <span :class="{ current: i === crumbs.length - 1 }">{{ c.label }}</span>
          </span>
        </nav>

        <main class="oa-content">
          <RouterView />
        </main>
      </div>
    </div>
  </div>
</template>

<style scoped>
.oa {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--cj-paper);
  color: var(--cj-ink);
}

.oa-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  height: 52px;
  padding: 0 16px 0 18px;
  background: var(--cj-header-bg, linear-gradient(90deg, #1f4f8a 0%, #3d6fb5 55%, #5b7fd1 100%));
  color: #fff;
  box-shadow: 0 1px 0 rgba(0, 0, 0, 0.06);
  z-index: 20;
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
}

.brand-mark {
  width: 8px;
  height: 22px;
  border-radius: 2px;
  background: #fff;
  flex-shrink: 0;
  opacity: 0.9;
}

.brand-text {
  display: flex;
  align-items: baseline;
  gap: 8px;
  min-width: 0;
}

.brand-text strong {
  font-family: var(--cj-font-body);
  font-size: 1.05rem;
  font-weight: 700;
  letter-spacing: 0.02em;
  white-space: nowrap;
}

.brand-text span {
  font-size: 0.78rem;
  opacity: 0.8;
  white-space: nowrap;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-right :deep(.theme-switcher__label) {
  color: rgba(255, 255, 255, 0.78);
}

.header-right :deep(.theme-switcher__select) {
  color: #16355c;
  background-color: rgba(255, 255, 255, 0.92);
  border-color: transparent;
}

.who {
  display: flex;
  align-items: center;
  gap: 8px;
}

.avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.82rem;
  background: rgba(255, 255, 255, 0.22);
  border: 1px solid rgba(255, 255, 255, 0.35);
}

.who-meta {
  display: none;
  flex-direction: column;
  line-height: 1.15;
}

.who-name {
  font-size: 0.85rem;
  font-weight: 600;
}

.who-id {
  font-size: 0.7rem;
  opacity: 0.75;
}

.logout-btn {
  border: 1px solid rgba(255, 255, 255, 0.35);
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  border-radius: 4px;
  padding: 5px 12px;
  font: inherit;
  font-size: 0.8rem;
  cursor: pointer;
}

.logout-btn:hover {
  background: rgba(255, 255, 255, 0.2);
}

.oa-body {
  flex: 1;
  min-height: 0;
  display: grid;
  grid-template-columns: 200px 1fr;
}

.oa-aside {
  background: var(--cj-aside-bg, #f5f7fb);
  border-right: 1px solid var(--cj-line);
  padding: 10px 8px;
  overflow: auto;
}

.nav-group {
  margin-top: 8px;
}

.nav-group-title {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 0;
  background: transparent;
  color: var(--cj-text-muted);
  font: inherit;
  font-size: 0.78rem;
  font-weight: 650;
  letter-spacing: 0.02em;
  padding: 8px 10px;
  cursor: pointer;
  border-radius: 4px;
}

.nav-group-title:hover {
  background: color-mix(in srgb, var(--cj-ink) 4%, transparent);
  color: var(--cj-ink);
}

.chev {
  font-size: 0.7rem;
  transition: transform 0.15s ease;
  transform: rotate(-90deg);
}

.chev.open {
  transform: rotate(0deg);
}

.nav-children {
  display: grid;
  gap: 2px;
  padding: 2px 0 4px;
}

.nav-item {
  text-decoration: none;
  padding: 9px 12px 9px 16px;
  border-radius: 4px;
  color: var(--cj-nav-item);
  font-size: 0.9rem;
  font-weight: 500;
}

.nav-item--top {
  padding-left: 12px;
  font-weight: 600;
}

.nav-item:hover {
  background: color-mix(in srgb, var(--cj-accent) 8%, transparent);
  color: var(--cj-ink);
}

.nav-item.active {
  background: color-mix(in srgb, var(--cj-accent) 12%, transparent);
  color: var(--cj-accent);
  font-weight: 650;
}

.oa-main {
  min-width: 0;
  display: flex;
  flex-direction: column;
  background: var(--cj-paper);
}

.oa-tabs {
  display: flex;
  gap: 2px;
  align-items: flex-end;
  padding: 8px 12px 0;
  background: var(--cj-tabs-bg, #eef2f8);
  border-bottom: 1px solid var(--cj-line);
  overflow-x: auto;
}

.tab {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: 1px solid transparent;
  border-bottom: 0;
  background: transparent;
  color: var(--cj-text-muted);
  padding: 8px 12px;
  border-radius: 4px 4px 0 0;
  font: inherit;
  font-size: 0.84rem;
  cursor: pointer;
  white-space: nowrap;
}

.tab:hover {
  color: var(--cj-ink);
  background: color-mix(in srgb, #fff 70%, transparent);
}

.tab.active {
  background: #fff;
  color: var(--cj-accent);
  border-color: var(--cj-line);
  font-weight: 650;
  box-shadow: 0 -1px 0 #fff;
}

.tab-close {
  width: 16px;
  height: 16px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 0.95rem;
  line-height: 1;
  opacity: 0.55;
}

.tab-close:hover {
  opacity: 1;
  background: color-mix(in srgb, var(--cj-ink) 8%, transparent);
}

.oa-crumb {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
  padding: 10px 16px 0;
  font-size: 0.8rem;
  color: var(--cj-text-muted);
}

.crumb-item .sep {
  margin-right: 4px;
  opacity: 0.5;
}

.crumb-item .current {
  color: var(--cj-ink);
  font-weight: 600;
}

.oa-content {
  flex: 1;
  min-height: 0;
  padding: 12px 16px 16px;
  overflow: auto;
}

@media (min-width: 960px) {
  .who-meta {
    display: flex;
  }
}

@media (max-width: 800px) {
  .oa-body {
    grid-template-columns: 1fr;
  }

  .oa-aside {
    border-right: 0;
    border-bottom: 1px solid var(--cj-line);
    max-height: 180px;
  }

  .brand-text span {
    display: none;
  }
}
</style>
