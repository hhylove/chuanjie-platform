<script setup lang="ts">
import ThemeSwitcher from '../components/ThemeSwitcher.vue'

defineProps<{
  /** 当前用户显示名 */
  displayName?: string
  /** 登录账号 */
  username?: string
}>()

const emit = defineEmits<{
  logout: []
}>()
</script>

<template>
  <div class="shell">
    <header class="shell-bar">
      <div class="brand">
        <span class="brand-mark" aria-hidden="true" />
        <div class="brand-text">
          <strong>创界云枢</strong>
          <span>Ops</span>
        </div>
      </div>
      <div class="shell-actions">
        <ThemeSwitcher />
        <div v-if="displayName || username" class="who">
          <span class="who-name">{{ displayName || username }}</span>
          <span v-if="username" class="who-id">{{ username }}</span>
        </div>
        <button type="button" class="logout-btn" @click="emit('logout')">退出</button>
      </div>
    </header>
    <main class="shell-main">
      <slot />
    </main>
  </div>
</template>

<style scoped>
.shell {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background:
    radial-gradient(900px 420px at 0% -10%, var(--cj-shell-glow-a), transparent 55%),
    radial-gradient(700px 380px at 100% 0%, var(--cj-shell-glow-b), transparent 50%),
    var(--cj-paper);
}

.shell-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 28px;
  border-bottom: 1px solid var(--cj-line);
  background: var(--cj-bar-bg);
  backdrop-filter: blur(var(--cj-glass-blur));
  animation: cj-fade-up 0.45s ease both;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
}

.brand-mark {
  width: 12px;
  height: 28px;
  border-radius: 999px;
  background: linear-gradient(180deg, var(--cj-accent), var(--cj-ink));
}

.brand-text {
  display: flex;
  align-items: baseline;
  gap: 6px;
  line-height: 1;
}

.brand-text strong {
  font-family: var(--cj-font-display);
  font-size: 1.35rem;
  font-weight: 650;
  letter-spacing: 0.04em;
  color: var(--cj-ink);
}

.brand-text span {
  font-size: 0.85rem;
  color: var(--cj-text-muted);
}

.shell-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.who {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  line-height: 1.2;
}

.who-name {
  font-weight: 600;
  font-size: 0.92rem;
  color: var(--cj-ink);
}

.who-id {
  font-size: 0.75rem;
  color: var(--cj-text-muted);
}

.logout-btn {
  border: 1px solid var(--cj-line);
  background: transparent;
  color: var(--cj-ink);
  border-radius: 999px;
  padding: 8px 14px;
  font: inherit;
  font-size: 0.85rem;
  cursor: pointer;
  transition:
    background 0.2s ease,
    border-color 0.2s ease;
}

.logout-btn:hover {
  background: color-mix(in srgb, var(--cj-ink) 6%, transparent);
  border-color: color-mix(in srgb, var(--cj-ink) 28%, transparent);
}

.shell-main {
  flex: 1;
  padding: 28px;
  animation: cj-fade-up 0.55s ease 0.08s both;
}

@media (max-width: 640px) {
  .shell-bar,
  .shell-main {
    padding-left: 16px;
    padding-right: 16px;
  }

  .who {
    display: none;
  }
}
</style>
