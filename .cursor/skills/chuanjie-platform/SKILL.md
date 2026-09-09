---
name: chuanjie-platform
description: >-
  创界新后台完整系统专用规范：以《完整系统项目架构》为总纲，覆盖五阶段建设路径、
  Project ID / SPU-SKU 主线、前后端工程约束、注释要求；强制「先写入 skill 骨架/拆解文档并评审通过，才能开始开发」，以及进度必更新。
  Use when working in the chuanjie repo, cj-platform-web/server, OA/项目/商品/供应链/财务,
  创业者端/供应商端, planning, coding, PR review, or progress updates.
disable-model-invocation: true
---

# 创界新后台 Platform Skill

## V2 当前技术基线

- [architecture-v2-saas.md](architecture-v2-saas.md) ← **已评审通过的多租户 SaaS 技术架构，最高技术优先级**
- [v2-rebuild.md](v2-rebuild.md) ← V2 重建阶段、门禁与验收
- [r1-saas-control-plane.md](r1-saas-control-plane.md) ← R1 SaaS控制面专项设计（已评审通过，开发中）
- [progress.md](progress.md) ← 过程状态真相

旧 S0～S5 文档与代码作为 V1 历史参考，当前暂停；不得继续按单公司、自建 JWT、Redis/MinIO 路线开发。任何旧实现删除前必须先完成可恢复基线、删除清单和用户评审。

## 业务源文档（本仓库）

- `创界新后台完整系统项目架构.docx` ← **产品与建设总纲**
- `创界新后台前后端项目规范.docx` ← 工程约束
- `创界AI科技中心项目进度表.docx` ← 进度（过程以 progress.md 为准）

按需阅读：

- 架构/产品：[architecture.md](architecture.md) / [product-plan.md](product-plan.md)
- 工程：[tech-spec.md](tech-spec.md)
- **S0 骨架：** [s0-scaffold.md](s0-scaffold.md)
- 进度：[progress.md](progress.md)
- 后续阶段骨架：`s1-*.md` / `s2-*.md` …（未产出前禁止进入该阶段开发）

冲突时：**V2 技术与部署以 architecture-v2-saas.md 为准**；原始 docx 确定业务需求；V2 未覆盖的工程约束沿用 tech-spec；进度以 progress.md 为准。

## 项目宗旨

**减少人员繁琐操作和沟通。** 统一业务数据与端到端协作，不复制旧页面。

## 文档先行（硬性，所有阶段通用）

**没有写进本 skill（或 skill 目录下对应骨架/拆解 md）并写明白，就不能开始开发。**

适用于 S0 脚手架，也适用于 S1～S5 及任一子功能：

1. **先写文档**：在 `.cursor/skills/chuanjie-platform/` 落地阶段/功能骨架或详细拆解（范围、非目标、目录或模块、接口/表字段、状态流转、验收、依赖）。  
2. **再挂进度**：`progress.md` 编号、状态改为「待评审」，并链接该文档。  
3. **再评审**：人确认通过后，状态才可改为「开发中」。  
4. **最后编码**：严格按已通过的 skill 文档实现；文档未覆盖的点先补文档再改代码。  

| 阶段 | 开工前必须存在的 skill 文档 | 当前 |
|------|------------------------------|------|
| S0 | [s0-scaffold.md](s0-scaffold.md) | 已完成 |
| S1 | [s1-platform-oa.md](s1-platform-oa.md)（基础平台与 OA 骨架） | **已评审通过，开发中（S1-01）** |
| S2 | `s2-project-ops.md`（项目经营闭环骨架） | **未产出 → 禁止开发 S2** |
| S3 | `s3-product-supply.md` | **未产出 → 禁止开发 S3** |
| S4 | `s4-finance-collab.md` | **未产出 → 禁止开发 S4** |
| S5 | `s5-data-ai.md` | **未产出 → 禁止开发 S5** |

子功能若复杂（如 S2-01 创业者档案），除阶段骨架外，还须有专项拆解（可写在 progress 专节或独立 `s2-01-*.md`），同样评审后才能写该子功能代码。

**Agent 禁止行为：** 用户说「先写着」「边做边补文档」时仍直接铺业务代码；必须先补齐 skill 文档并请用户评审。

## 强制开发门禁

```text
开工前：
- [ ] 本阶段/本功能的 skill 骨架或拆解 md 已存在且写明白（见上表）
- [ ] progress.md 已有功能编号，并链接到上述文档
- [ ] 已拆解：范围、非目标、子任务、接口/字段、状态流转、验收标准
- [ ] 状态 ≥ 待评审 且评审通过
- [ ] 文档缺失 / 未写明白 / 未评审 → 禁止写任何实现代码（含「先搭一点」）

收工/合并前：
- [ ] 实现与已通过的 skill 文档一致；有偏差先改文档再改代码
- [ ] 接口、字段、SQL、**数据库及其它配置**注释齐全（配置须说明干什么用）
- [ ] 已更新总表状态与进度%
- [ ] 已追加进度日志（做到哪、完成什么、下一步）
- [ ] 无进度更新 → 不得合并
```

## V2 建设顺序（勿颠倒顶层顺序）

R0 基线与新骨架 → R1 SaaS 控制面 → R2 租户组织权限 → R3 协作与通知 → R4 项目 → R5 商品供应链 → R6 财务 → R7 第三方集成 → R8 数据 AI → R9 独库、Cell、私有部署与容灾。

详细范围和开工门禁见 [v2-rebuild.md](v2-rebuild.md)。旧版五阶段业务顺序保留为领域交付参考，但必须建立在 V2 租户底座上。

## V1 历史五阶段（暂停，仅供需求追溯）

前置：工程脚手架（S0）— 文档见 [s0-scaffold.md](s0-scaffold.md)

1. **基础平台与 OA** — 账号组织权限、工作台、任务/审批/消息、人事考勤培训、行政、知识  
2. **项目经营闭环** — 创业者、立项、Project ID、项目空间、预算协议、经营单元/店铺、风险  
3. **商品供应链** — 选品→开发→SPU/SKU→成本定价→创意→采购供应商→仓库→清仓  
4. **财务与外部协作** — 项目/商品财务、创业者端、供应商端、对账结算、驾驶舱  
5. **数据与 AI** — 助手、分析、预警、知识库、Agent（仅受控接口）  

子功能拆解与状态见 [progress.md](progress.md)。

## 两条主线

- 创业经营：**Project ID** 贯穿  
- 商品主数据：**SPU / SKU**  
- 经营业务原则上关联 `project_id`；审批态 ≠ 业务态  

## 技术基线

| 层 | 选型 |
|----|------|
| Web | Vue 3、TS、Vite、Pinia、Element Plus |
| 移动 | uni-app + Vue 3 |
| 后端 | Java 21、Spring Boot 3.5、MyBatis Plus、Flowable 7 |
| 存储 | PostgreSQL 16、Valkey、SeaweedFS；分析达到瓶颈后再引入 ClickHouse |
| 形态 | 模块化单体；仓：`cj-platform-web` + `cj-platform-server` |
| 身份 | 标准 OIDC；默认 Casdoor；业务授权保留在平台 |
| 多租户 | 默认共享数据库；大客户独立数据库；私有部署共用同一代码与镜像 |
| 集成 | 独立 integration-hub；含聚水潭、短信、邮件、企业消息等适配器 |

## 注释硬性要求

以下无注释说明用途者，不得合并入库：

| 对象 | 必须说明 |
|------|----------|
| 对外接口 | 用途、关键参数、返回含义 |
| 业务字段（含 VO/DTO/表字段） | 含义、口径、约束；SQL 用 COMMENT |
| 复杂 SQL / 迁移脚本 | 目的、关联、注意事项 |
| **数据库与其它配置** | **每一项写清干什么用的**（见下） |

**配置注释范围（强制）：**

- 后端：`application*.yml` / `.properties`、数据源、Redis、MinIO、Flyway、端口、profile、Actuator 等  
- 前端：`.env*`、`vite.config` 代理、`apiBaseUrl` 等运行时配置  
- 基础设施：`docker-compose.yml` 中服务、端口、账号、卷、健康检查  
- 凡新增配置项，必须用同行/上方注释说明：**用途、默认值含义、切换场景（如 local vs nodocker）**；禁止只写裸键值  

收工门禁中的「注释齐全」包含上述配置注释。

## 前端可用性（强制）

面向内部员工的页面必须**让用户看得懂、点得动**，禁止把开发概念直接甩给业务用户。

| 要求 | 说明 |
|------|------|
| 文案用人话 | 用「上级部门」「显示顺序」，不用「parentId / 0 为根」等字段名当标签 |
| 选关系不填 ID | 组织、用户、角色、项目等关联用下拉/树选/搜索选名称；禁止让用户手填数据库主键 |
| 入口要有上下文 | 从树上点「添加下级」应自动带上当前上级；根节点用「不选上级 / 作为根」表达 |
| 少而清晰 | 弹窗字段宁少勿谜；必填标清；辅助说明写短句 |
| 验收视角 | 评审/联调时问：不看接口文档的同事能否独立完成该操作？不能则改 UI |

Agent 做管理页、表单、弹窗时默认按上表自检；发现「数字 ID 步进器选上级」一类交互必须改掉再交付。

## Agent 约定

1. **任何开发前**：检查 skill 内是否已有该阶段/功能的写明白的骨架或拆解文档；没有 → 只写文档，不写代码。  
2. 文档写完后更新 progress 为待评审，**询问用户是否通过**；未明确通过不编码。  
3. 实现遵守 [tech-spec.md](tech-spec.md) 与已通过的阶段骨架；模块边界对齐架构；**页面遵守「前端可用性」**。  
4. 每轮有效开发后更新 progress 日志。  
5. 架构或范围变更：先改 architecture / 对应 `s*-*.md` / progress，再改代码。
