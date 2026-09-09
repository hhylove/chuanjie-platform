import { computed, ref } from 'vue'

/** localStorage 键：记住用户上次选择的 PC 主题 */
export const THEME_STORAGE_KEY = 'cj.admin.theme'

export const THEME_OPTIONS = [
  { id: 'daylight', label: '积云清爽' },
  { id: 'enterprise', label: '企业专业' },
  { id: 'glass', label: '科技毛玻璃' },
  { id: 'night', label: '深夜专注' },
  { id: 'warm', label: '暖经营' },
] as const

export type ThemeId = (typeof THEME_OPTIONS)[number]['id']

const DEFAULT_THEME: ThemeId = 'daylight'

const themeId = ref<ThemeId>(DEFAULT_THEME)

function isThemeId(value: string | null | undefined): value is ThemeId {
  return THEME_OPTIONS.some((item) => item.id === value)
}

/** 把主题写到 html[data-theme]，供 themes.css 生效 */
export function applyTheme(id: ThemeId): void {
  themeId.value = id
  document.documentElement.setAttribute('data-theme', id)
  try {
    localStorage.setItem(THEME_STORAGE_KEY, id)
  } catch {
    // 隐私模式等写失败时忽略，仍可当次会话切换
  }
}

/** 启动时读取本地偏好（index.html 已尽量先写 data-theme） */
export function initTheme(): ThemeId {
  let next: ThemeId = DEFAULT_THEME
  try {
    const saved = localStorage.getItem(THEME_STORAGE_KEY)
    if (isThemeId(saved)) {
      next = saved
    }
  } catch {
    // ignore
  }
  const fromDom = document.documentElement.getAttribute('data-theme')
  if (isThemeId(fromDom)) {
    next = fromDom
  }
  applyTheme(next)
  return next
}

export function useTheme() {
  const current = computed(() => themeId.value)
  const label = computed(
    () => THEME_OPTIONS.find((item) => item.id === themeId.value)?.label ?? themeId.value,
  )

  function setTheme(id: ThemeId): void {
    applyTheme(id)
  }

  return {
    themeId: current,
    themeLabel: label,
    themes: THEME_OPTIONS,
    setTheme,
  }
}
