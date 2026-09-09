<script setup lang="ts">
import { computed, ref } from "vue";

import { createTenantContext } from "@cj/tenant-context";

const tenantContext = createTenantContext();
const isPanelOpen = ref(false);
const activeTenant = computed(() => tenantContext.current());

function handleOpenTenantPanel(): void {
  isPanelOpen.value = true;
}

function handleCloseTenantPanel(): void {
  isPanelOpen.value = false;
}
</script>

<template>
  <main class="shell">
    <header class="topbar">
      <a class="brand" href="#" aria-label="创界云枢首页">
        <span class="brand-mark" aria-hidden="true">界</span>
        <span>
          <strong>创界云枢</strong>
          <small>OPERATING CLOUD</small>
        </span>
      </a>

      <button class="tenant-button" type="button" @click="handleOpenTenantPanel">
        <span class="status-dot" aria-hidden="true"></span>
        {{ activeTenant ? "当前公司" : "选择公司" }}
        <span aria-hidden="true">↗</span>
      </button>
    </header>

    <section class="hero" aria-labelledby="hero-title">
      <div class="hero-copy">
        <p class="eyebrow">V2 · SAAS FOUNDATION</p>
        <h1 id="hero-title">从可信租户开始，<br /><em>重新组织经营。</em></h1>
        <p class="intro">
          全新的多租户底座正在建立。身份、数据与权限都将围绕公司边界运行，
          普通客户共享基础设施，大客户可平滑迁移到独立数据库。
        </p>
        <div class="hero-actions">
          <button class="primary-action" type="button" @click="handleOpenTenantPanel">
            进入租户选择
          </button>
          <a href="#foundation">查看底座范围</a>
        </div>
      </div>

      <div class="orbit" aria-hidden="true">
        <div class="orbit-ring orbit-ring--outer"></div>
        <div class="orbit-ring orbit-ring--inner"></div>
        <div class="orbit-core">
          <span>CONTROL</span>
          <strong>可信边界</strong>
          <small>Tenant-aware</small>
        </div>
        <span class="orbit-label orbit-label--a">身份</span>
        <span class="orbit-label orbit-label--b">数据</span>
        <span class="orbit-label orbit-label--c">权限</span>
      </div>
    </section>

    <section id="foundation" class="foundation" aria-labelledby="foundation-title">
      <div class="section-heading">
        <span>01</span>
        <div>
          <p>CONTROL PLANE</p>
          <h2 id="foundation-title">第一阶段建设范围</h2>
        </div>
      </div>

      <div class="capability-grid">
        <article>
          <span>IDENTITY</span>
          <h3>一个自然人账号</h3>
          <p>通过标准OIDC连接身份服务，一个账号可加入并切换多家公司。</p>
        </article>
        <article>
          <span>TENANCY</span>
          <h3>可信的公司边界</h3>
          <p>租户身份来自签名会话，前端不能用请求参数伪造公司编号。</p>
        </article>
        <article>
          <span>PLACEMENT</span>
          <h3>共享与独库同源</h3>
          <p>同一套代码支持共享数据库、大客户独立数据库和私有部署。</p>
        </article>
      </div>
    </section>

    <footer>
      <span>R1 / 基础骨架</span>
      <span>服务状态：等待OIDC与PostgreSQL接入</span>
    </footer>

    <div v-if="isPanelOpen" class="overlay" @click.self="handleCloseTenantPanel">
      <section class="tenant-panel" role="dialog" aria-modal="true" aria-labelledby="tenant-title">
        <button class="close-button" type="button" aria-label="关闭" @click="handleCloseTenantPanel">×</button>
        <p class="eyebrow">TENANT SESSION</p>
        <h2 id="tenant-title">选择要进入的公司</h2>
        <p>OIDC登录和租户列表将在R1后续接入。当前页面不使用模拟公司数据。</p>
        <div class="empty-state">
          <span aria-hidden="true">⌁</span>
          <strong>尚未建立登录会话</strong>
          <small>完成身份认证后，这里只显示你有权访问的公司。</small>
        </div>
      </section>
    </div>
  </main>
</template>
