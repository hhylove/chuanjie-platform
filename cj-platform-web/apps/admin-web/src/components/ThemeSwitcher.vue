<script setup lang="ts">
import { useTheme, type ThemeId } from '../composables/useTheme'

withDefaults(
  defineProps<{
    /** 登录页深色底上使用浅色样式 */
    onDark?: boolean
  }>(),
  { onDark: false },
)

const { themeId, themes, setTheme } = useTheme()

function onChange(event: Event): void {
  const value = (event.target as HTMLSelectElement).value as ThemeId
  setTheme(value)
}
</script>

<template>
  <label class="theme-switcher" :class="{ 'theme-switcher--on-dark': onDark }">
    <span class="theme-switcher__label">主题</span>
    <select class="theme-switcher__select" :value="themeId" aria-label="切换界面主题" @change="onChange">
      <option v-for="item in themes" :key="item.id" :value="item.id">
        {{ item.label }}
      </option>
    </select>
  </label>
</template>

<style scoped>
.theme-switcher {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 0.82rem;
  color: var(--cj-text-muted);
}

.theme-switcher__label {
  white-space: nowrap;
}

.theme-switcher__select {
  appearance: none;
  border: 1px solid var(--cj-line);
  border-radius: 999px;
  padding: 7px 28px 7px 12px;
  font: inherit;
  font-size: 0.82rem;
  color: var(--cj-ink);
  background-color: var(--cj-surface-solid);
  background-image: linear-gradient(45deg, transparent 50%, var(--cj-text-muted) 50%),
    linear-gradient(135deg, var(--cj-text-muted) 50%, transparent 50%);
  background-position:
    calc(100% - 14px) 55%,
    calc(100% - 9px) 55%;
  background-size:
    5px 5px,
    5px 5px;
  background-repeat: no-repeat;
  cursor: pointer;
  outline: none;
  transition:
    border-color 0.2s ease,
    box-shadow 0.2s ease;
}

.theme-switcher__select:focus {
  border-color: var(--cj-accent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--cj-accent) 22%, transparent);
}

.theme-switcher--on-dark .theme-switcher__label {
  color: var(--cj-login-muted);
}

.theme-switcher--on-dark .theme-switcher__select {
  color: var(--cj-login-fg);
  background-color: color-mix(in srgb, var(--cj-login-panel-bg) 70%, transparent);
  border-color: color-mix(in srgb, var(--cj-login-fg) 22%, transparent);
}
</style>
