# S1 附属：PC 端多主题切换（admin-web）

> 状态：**已确认可开发**（用户 2026-09-07「可以」）  
> 范围：仅 `cj-platform-web/apps/admin-web` 视觉主题；不接后端用户偏好接口。

## 1. 目标

PC 管理端提供 **5 套可切换主题**，登录页与登录后壳子共用同一套 CSS 变量；偏好本地持久化，刷新不丢。

## 2. 非目标

- 不做主题编辑器 / 自定义色板上传  
- 本期不写服务端「用户主题」字段（后续可挂 S1-10 参数或用户设置）  
- 不改移动端 / 创业者端 / 供应商端  

## 3. 五套主题

| id | 展示名 | 气质 |
|----|--------|------|
| `enterprise` | 企业专业 | 浅底墨青主色、干净表格感（默认） |
| `glass` | 科技毛玻璃 | 深色底 + 半透明面板 + blur（弱机可降级） |
| `daylight` | 昼间清爽 | 高对比浅色、冷灰蓝信息密度友好 |
| `night` | 深夜专注 | 深色护眼、低眩光 |
| `warm` | 暖经营 | 浅暖底 + 琥珀强调（经营舱氛围） |

## 4. 实现要点

- `html[data-theme="…"]` 切换 CSS 变量（色、表面、模糊、圆角、字体）  
- `localStorage` key：`cj.admin.theme`  
- 首屏：`index.html` 内联脚本先写 `data-theme`，避免闪白  
- 顶栏 + 登录页提供切换器  
- Element Plus：映射 `--el-color-primary` 等到主题 accent  
- `prefers-reduced-transparency`：关闭/减弱 `backdrop-filter`  

## 5. 验收

- [x] 五套主题均可切换，登录页与壳子同步  
- [x] 刷新后仍为上次选择  
- [x] 毛玻璃主题在 `prefers-reduced-transparency` 下不明显糊/卡（变量降级）  
- [x] 无后端改动、无新配置密钥  

## 6. 文件落位

- `apps/admin-web/src/styles/tokens.css` — 共享动画/基线  
- `apps/admin-web/src/styles/themes.css` — 五主题变量  
- `apps/admin-web/src/composables/useTheme.ts`  
- `apps/admin-web/src/components/ThemeSwitcher.vue`  
- 接入：`main.ts`、`AppShellLayout`、`LoginPage`、`index.html`  
