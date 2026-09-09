<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { loginApi } from '@cj/api-client'
import { setAccessToken, setRefreshToken } from '@cj/auth'
import ThemeSwitcher from '../components/ThemeSwitcher.vue'

const router = useRouter()
const route = useRoute()
const username = ref('admin')
const password = ref('Admin@123')
const loading = ref(false)

const brandChars = ['创', '界', '云', '枢']

async function handleLogin(): Promise<void> {
  loading.value = true
  try {
    const resp = await loginApi(username.value.trim(), password.value)
    if (resp.code !== 0 || !resp.data) {
      ElMessage.error(resp.message || '登录失败')
      return
    }
    setAccessToken(resp.data.accessToken)
    setRefreshToken(resp.data.refreshToken)
    ElMessage.success('登录成功')
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    await router.replace(redirect || '/')
  } catch (err) {
    ElMessage.error(err instanceof Error ? err.message : '登录请求失败')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="bg-layer" aria-hidden="true">
      <div class="mesh" />
      <div class="blob blob-a" />
      <div class="blob blob-b" />
      <div class="blob blob-c" />
      <div class="orbit orbit-a" />
      <div class="orbit orbit-b" />
      <div class="orbit orbit-c" />
      <span class="node n1" />
      <span class="node n2" />
      <span class="node n3" />
      <div class="grain" />
    </div>

    <div class="login-toolbar">
      <ThemeSwitcher on-dark />
    </div>

    <section class="stage">
      <header class="hero">
        <p class="eyebrow">
          <span class="eyebrow-dot" />
          Chuanjie · Yunshu
        </p>
        <h1 class="brand" aria-label="创界云枢">
          <span
            v-for="(ch, i) in brandChars"
            :key="ch"
            class="brand-char"
            :style="{ animationDelay: `${0.06 + i * 0.1}s` }"
          >{{ ch }}</span>
        </h1>
        <div class="brand-rule" aria-hidden="true" />
        <p class="lede">欢迎登录</p>
        <p class="sub">统一办公入口，登录后继续你的工作</p>
      </header>

      <form class="panel" @submit.prevent="handleLogin">
        <div class="panel-brand">
          <span class="panel-mark" aria-hidden="true" />
          <div>
            <strong>创界云枢</strong>
            <span>账号登录</span>
          </div>
        </div>
        <label class="field" style="--i: 0">
          <span>账号</span>
          <input v-model="username" name="username" autocomplete="username" placeholder="请输入账号" />
        </label>
        <label class="field" style="--i: 1">
          <span>密码</span>
          <input
            v-model="password"
            name="password"
            type="password"
            autocomplete="current-password"
            placeholder="请输入密码"
          />
        </label>
        <button class="submit" type="submit" :disabled="loading" style="--i: 2">
          <span class="submit-glow" aria-hidden="true" />
          {{ loading ? '登录中…' : '进入云枢' }}
        </button>
        <p class="hint">开发默认：admin / Admin@123</p>
      </form>
    </section>
  </div>
</template>

<style scoped>
.login-page {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  color: var(--cj-login-fg);
  background: var(--cj-login-page-bg);
}

.bg-layer {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.mesh {
  position: absolute;
  inset: -10%;
  opacity: 0.18;
  background-image:
    linear-gradient(color-mix(in srgb, var(--cj-login-fg) 14%, transparent) 1px, transparent 1px),
    linear-gradient(90deg, color-mix(in srgb, var(--cj-login-fg) 14%, transparent) 1px, transparent 1px);
  background-size: 56px 56px;
  mask-image: radial-gradient(ellipse 75% 65% at 40% 40%, #000 15%, transparent 72%);
  animation: cj-mesh-drift 28s linear infinite;
}

.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(48px);
  animation: cj-drift 16s ease-in-out infinite;
}

.blob-a {
  width: min(72vw, 560px);
  height: min(72vw, 560px);
  left: -16%;
  top: -22%;
  background: radial-gradient(circle, var(--cj-blob-a), transparent 68%);
}

.blob-b {
  width: min(60vw, 460px);
  height: min(60vw, 460px);
  right: -14%;
  bottom: -24%;
  background: radial-gradient(circle, var(--cj-blob-b), transparent 70%);
  animation-delay: -5s;
}

.blob-c {
  width: min(36vw, 280px);
  height: min(36vw, 280px);
  left: 38%;
  top: 42%;
  background: radial-gradient(circle, color-mix(in srgb, var(--cj-accent) 40%, transparent), transparent 70%);
  animation-duration: 20s;
  animation-delay: -9s;
  opacity: 0.75;
}

.orbit {
  position: absolute;
  border-radius: 50%;
  border: 1px solid color-mix(in srgb, var(--cj-login-fg) 14%, transparent);
  left: 58%;
  top: 44%;
}

.orbit-a {
  width: min(52vw, 380px);
  height: min(52vw, 380px);
  margin: calc(min(52vw, 380px) / -2) 0 0 calc(min(52vw, 380px) / -2);
  animation: cj-orbit-spin 40s linear infinite;
}

.orbit-b {
  width: min(36vw, 260px);
  height: min(36vw, 260px);
  margin: calc(min(36vw, 260px) / -2) 0 0 calc(min(36vw, 260px) / -2);
  border-style: dashed;
  opacity: 0.65;
  animation: cj-orbit-spin 26s linear infinite reverse;
}

.orbit-c {
  width: min(20vw, 150px);
  height: min(20vw, 150px);
  margin: calc(min(20vw, 150px) / -2) 0 0 calc(min(20vw, 150px) / -2);
  border-color: color-mix(in srgb, var(--cj-accent) 50%, transparent);
  animation: cj-orbit-pulse 4.8s ease-in-out infinite;
}

.node {
  position: absolute;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--cj-accent);
  box-shadow: 0 0 14px color-mix(in srgb, var(--cj-accent) 65%, transparent);
  animation: cj-node-float 8s ease-in-out infinite;
}

.n1 { left: 62%; top: 30%; }
.n2 { left: 74%; top: 52%; width: 4px; height: 4px; animation-delay: -2s; }
.n3 { left: 52%; top: 64%; animation-delay: -3.5s; }

.grain {
  position: absolute;
  inset: 0;
  opacity: 0.32;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.45'/%3E%3C/svg%3E");
  mix-blend-mode: soft-light;
  animation: cj-grain 8s ease-in-out infinite;
}

.login-toolbar {
  position: absolute;
  z-index: 2;
  top: 20px;
  right: 24px;
  animation: cj-fade-up 0.5s ease both;
}

.stage {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  display: grid;
  align-content: center;
  gap: 40px;
  padding: clamp(24px, 6vw, 64px);
  max-width: 560px;
}

.eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  margin: 0 0 16px;
  font-size: 0.78rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--cj-login-muted);
  animation: cj-fade-up 0.55s ease both;
}

.eyebrow-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  color: var(--cj-accent);
  background: var(--cj-accent);
  animation: cj-live-ping 2.2s ease-out infinite;
}

.brand {
  margin: 0;
  display: flex;
  flex-wrap: wrap;
  gap: 0.04em;
  font-family: var(--cj-font-display);
  font-size: clamp(3.2rem, 11vw, 5rem);
  font-weight: 650;
  letter-spacing: 0.1em;
  line-height: 1.02;
  color: var(--cj-login-fg);
}

.brand-char {
  display: inline-block;
  opacity: 0;
  animation: cj-char-in 0.75s cubic-bezier(0.22, 1, 0.36, 1) both;
}

.brand-rule {
  width: 0;
  height: 3px;
  margin-top: 20px;
  border-radius: 999px;
  background: linear-gradient(90deg, var(--cj-accent), transparent);
  animation: cj-rule-grow 0.9s ease 0.5s both;
}

.lede {
  margin: 18px 0 0;
  font-size: 1.35rem;
  font-weight: 650;
  letter-spacing: 0.06em;
  color: var(--cj-login-fg);
  animation: cj-fade-up 0.65s ease 0.35s both;
}

.sub {
  margin: 8px 0 0;
  max-width: 22em;
  font-size: 0.98rem;
  line-height: 1.55;
  color: var(--cj-login-muted);
  animation: cj-fade-up 0.65s ease 0.45s both;
}

.panel {
  display: grid;
  gap: 14px;
  padding: 22px;
  border-radius: calc(var(--cj-radius) + 2px);
  border: 1px solid var(--cj-line);
  background: var(--cj-login-panel-bg);
  color: var(--cj-ink);
  box-shadow: var(--cj-shadow);
  backdrop-filter: blur(var(--cj-glass-blur));
  animation: cj-panel-in 0.75s cubic-bezier(0.22, 1, 0.36, 1) 0.18s both;
}

.panel-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 4px;
}

.panel-mark {
  width: 10px;
  height: 28px;
  border-radius: 999px;
  background: linear-gradient(180deg, var(--cj-accent), var(--cj-ink));
}

.panel-brand strong {
  display: block;
  font-family: var(--cj-font-display);
  font-size: 1.05rem;
  letter-spacing: 0.06em;
}

.panel-brand span {
  display: block;
  margin-top: 2px;
  font-size: 0.78rem;
  color: var(--cj-text-muted);
}

.field {
  display: grid;
  gap: 6px;
  opacity: 0;
  animation: cj-fade-up 0.55s ease calc(0.35s + var(--i) * 0.08s) both;
}

.field span {
  font-size: 0.82rem;
  color: var(--cj-text-muted);
}

.field input {
  width: 100%;
  border: 1px solid var(--cj-line);
  border-radius: 10px;
  padding: 12px 14px;
  font: inherit;
  color: var(--cj-ink);
  background: var(--cj-surface-solid);
  outline: none;
  transition:
    border-color 0.2s ease,
    box-shadow 0.2s ease,
    transform 0.2s ease;
}

.field input:focus {
  border-color: color-mix(in srgb, var(--cj-accent) 55%, transparent);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--cj-accent) 18%, transparent);
  transform: translateY(-1px);
}

.submit {
  position: relative;
  overflow: hidden;
  margin-top: 4px;
  border: 0;
  border-radius: 999px;
  padding: 13px 16px;
  font: inherit;
  font-weight: 650;
  letter-spacing: 0.06em;
  color: #fff;
  background: linear-gradient(120deg, var(--cj-accent), var(--cj-accent-hover));
  cursor: pointer;
  opacity: 0;
  animation: cj-fade-up 0.55s ease calc(0.35s + var(--i) * 0.08s) both;
  transition:
    transform 0.15s ease,
    filter 0.2s ease,
    opacity 0.2s ease;
}

.submit-glow {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    110deg,
    transparent 30%,
    rgba(255, 255, 255, 0.28) 48%,
    transparent 66%
  );
  transform: translateX(-120%);
  animation: cj-sheen 4.5s ease-in-out 1.2s infinite;
}

.submit:hover:not(:disabled) {
  transform: translateY(-1px);
  filter: brightness(1.05);
}

.submit:disabled {
  opacity: 0.7;
  cursor: wait;
}

.hint {
  margin: 2px 0 0;
  font-size: 0.75rem;
  color: var(--cj-text-muted);
  text-align: center;
  opacity: 0;
  animation: cj-fade-up 0.5s ease 0.7s both;
}

@keyframes cj-mesh-drift {
  from { transform: translate3d(0, 0, 0); }
  to { transform: translate3d(-56px, -28px, 0); }
}

@keyframes cj-orbit-spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@keyframes cj-orbit-pulse {
  0%, 100% { opacity: 0.45; transform: scale(1); }
  50% { opacity: 0.9; transform: scale(1.04); }
}

@keyframes cj-node-float {
  0%, 100% { transform: translate3d(0, 0, 0); opacity: 0.55; }
  50% { transform: translate3d(6px, -10px, 0); opacity: 1; }
}

@keyframes cj-char-in {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.94);
    filter: blur(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
    filter: blur(0);
  }
}

@keyframes cj-rule-grow {
  from { width: 0; opacity: 0; }
  to { width: min(200px, 48%); opacity: 1; }
}

@keyframes cj-panel-in {
  from {
    opacity: 0;
    transform: translateY(22px) scale(0.98);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes cj-live-ping {
  0% { box-shadow: 0 0 0 0 color-mix(in srgb, var(--cj-accent) 50%, transparent); }
  70% { box-shadow: 0 0 0 8px transparent; }
  100% { box-shadow: 0 0 0 0 transparent; }
}

@keyframes cj-sheen {
  0%, 60% { transform: translateX(-120%); }
  80%, 100% { transform: translateX(120%); }
}

@media (min-width: 900px) {
  .stage {
    max-width: none;
    width: min(1120px, 92vw);
    margin: 0 auto;
    grid-template-columns: 1.2fr 0.8fr;
    align-items: center;
    gap: 64px;
  }

  .panel {
    max-width: 400px;
    justify-self: end;
  }
}

@media (max-width: 899px) {
  .orbit,
  .node {
    opacity: 0.35;
  }
}

@media (prefers-reduced-motion: reduce) {
  .mesh,
  .blob,
  .orbit,
  .node,
  .grain,
  .eyebrow-dot,
  .submit-glow,
  .brand-char,
  .brand-rule,
  .panel,
  .field,
  .submit,
  .hint,
  .lede,
  .sub,
  .eyebrow,
  .login-toolbar {
    animation: none !important;
    opacity: 1 !important;
    transform: none !important;
    filter: none !important;
  }

  .brand-rule {
    width: min(200px, 48%);
  }
}
</style>
