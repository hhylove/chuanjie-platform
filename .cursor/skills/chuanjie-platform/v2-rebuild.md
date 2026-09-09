# V2 多租户 SaaS 重建骨架

> 状态：架构已评审；实施骨架待执行  
> 架构依据：[architecture-v2-saas.md](architecture-v2-saas.md)

## 1. 范围

重建统一的多租户 SaaS 底座，并在其上逐步交付组织权限、协作、项目、商品供应链、财务、第三方集成和数据智能。标准 SaaS、大客户独立数据库和私有部署共用一套代码与镜像。

## 2. 非目标

- 首期不拆微服务，不引入 Kubernetes、Kafka、OpenSearch 和 ClickHouse。
- 首期不做在线购买套餐，仅预留订单、支付和计费接口。
- 不复制旧页面；业务界面按用户任务重新设计。
- Casdoor不承载业务角色、部门、岗位和数据权限。
- 第三方适配器不直接修改其他业务模块的数据表。

## 3. 重建阶段

| 阶段 | 交付内容 | 开工门禁 |
|---|---|---|
| R0 | Git/只读归档、旧实现清单、新骨架、CI、Compose | 删除清单与回滚方法评审 |
| R1 | 全局账号、OIDC、租户、成员、套餐、配额、租户切换 | 身份、租户和数据库模型评审 |
| R2 | 组织、岗位、角色、功能/数据/字段权限、审计 | 权限矩阵与隔离测试评审 |
| R3 | 工作台、审批、任务、文件、通知中心 | 消息模型与流程边界评审 |
| R4 | 创业者、Project ID、项目、经营单元、协议、风险 | 项目状态机评审 |
| R5 | SPU/SKU、采购、供应商、库存、物流 | 主数据、库存账和幂等规则评审 |
| R6 | 预算、费用、付款、发票、对账、成本利润 | 财务口径和审计规则评审 |
| R7 | integration-hub、聚水潭、短信/邮件/企微等通道 | 主源、映射、重试和对账策略评审 |
| R8 | 报表、预警、知识库、AI受控接口 | 指标口径和数据权限评审 |
| R9 | 独库迁移、Cell扩展、私有部署、容灾验收 | 压测、恢复和迁移演练通过 |

## 4. 目标工程结构

```text
cj-platform-server/
  cj-dependencies/
  cj-framework/
  cj-server/
  cj-module-platform-control/{api,biz}/
  cj-module-tenant-foundation/{api,biz}/
  cj-module-collaboration/{api,biz}/
  cj-module-project/{api,biz}/
  cj-module-product-supply/{api,biz}/
  cj-module-finance/{api,biz}/
  cj-module-integration-hub/{api,biz}/
  cj-module-analytics-ai/{api,biz}/
cj-platform-web/
  apps/{admin-web,entrepreneur-web,supplier-web,mobile}/
  packages/{api-client,auth,configuration,design-system,shared-types,shared-utils}/
```

## 5. R0 清理规则

1. 先建立 Git 仓库并提交原始基线；若暂不建立 Git，则生成带校验和的只读归档。
2. 永久保留三个原始 `.docx` 和 V2 架构、计划、决策记录。
3. 列出旧源码、构建产物、运行日志和临时接口数据，分类为“删除、迁移、保留参考”。
4. 优先删除可再生内容：`target/`、`dist/`、运行日志、测试输出和临时 JSON。
5. 新工程骨架构建和健康检查通过后，才删除被替代的业务源码。
6. 删除后立即运行后端测试、前端类型检查、构建和 Compose 健康检查。

## 6. 全局验收标准

- 同一自然人可加入并切换多个租户，令牌租户上下文可信。
- 共享库跨租户访问在应用过滤和 PostgreSQL RLS 两层均被阻止。
- 大客户可迁移至独立数据库，迁移前后业务编号和数据校验一致。
- 订单、库存、财务和第三方写入重复执行不会重复记账。
- 聚水潭支持全量、增量、断点续传、对账、失败重放和状态可视化。
- 通知中心支持站内信、邮件、短信和企业消息；平台通道与租户自带通道均可配置。
- 关键操作可按租户、操作者、业务编号和请求编号审计。
- 备份恢复演练满足 RPO 5 分钟、RTO 1 小时目标。

## 7. 当前下一步

只执行 R0 文档与基线准备，不直接删除旧业务实现。待 R0 删除清单和目标骨架评审通过后，再开始清理与编码。
