---
name: project-guide
description: STQ / 千往的项目工作方法论与全局工作规则（agent 无关，Claude Code 与 Codex 通用）。以 `_Documentation/ProjectGuide.md` 为项目最高纲领：开工先对照、缺失先补建、变更即同步、文档全登记、回复首行标注「已对照 ProjectGuide.md」；附 ProjectGuide 模板、阶段记录写法、编码 / 输出 / 设计参考 / 飞书 / 技能仓库 / NAS 部署等全局规范与合规自检。当需要新建或补建 ProjectGuide、为新项目初始化文档体系、检查项目是否合规、把这套工作规范教给另一个 agent 或新机器、或用户提到「按我的全局规则 / 千往工作流 / ProjectGuide 那套方法」时使用。
---

# ProjectGuide 工作法 + 全局工作规则

> 这是 STQ（千往 / ChoseWay）所有工程通用的工作方式。原文版本见仓库 `global/claude/CLAUDE.md`（Claude Code 全局规则）与 `global/codex/AGENTS.md`（Codex 全局规则）；本技能是它们的方法论化与可移植版——任何 agent 读完本文件都应能以同样方式工作。

## 一、核心机制：ProjectGuide.md 是项目最高纲领

- **位置**：`_Documentation/ProjectGuide.md`；Unity 工程为 `Assets/_SCRIPT/_Documentation/ProjectGuide.md`。
- **开工先读**：每次思考与执行前先读它，以其内容为最高优先级上下文（高于一般记忆与惯例，低于用户当前明确指令）。
- **缺失先建**：找不到该文件时，先向用户确认五项须知 —— **项目定位 / 核心目标 / 设计原则 / 目标平台 / 当前阶段** —— 按 [templates/ProjectGuide.template.md](templates/ProjectGuide.template.md) 生成后再继续干活。
- **变更即同步**：对话中凡涉及上述内容的新增或修改（目标变了、加了模块、换了平台、阶段推进、发布了版本），当场更新 ProjectGuide，不留到「以后补」。
- **只存持久内容**：不记临时想法、过程性讨论、一次性命令；记决策、契约、约束、踩坑结论、阶段里程碑。
- **保持纲领性与简洁（三文件分工）**：ProjectGuide 每条只写「一行结论 + 指针」，全文超过约 150 行或 20KB 即拆分。功能模块的契约级细节进 `_Documentation/Modules.md`（编号与核心目标一一对应），逐条阶段 / 版本记录进 `_Documentation/Changelog.md`（按月分组），两者登记进文档索引；需要细节时按索引再读对应文档，不把细节搬回 ProjectGuide。新增模块 → Modules.md 加一节 + ProjectGuide 加一行；每次发布 → Changelog.md 加一条 + ProjectGuide 状态摘要更新。
- **文档索引库**：项目里生成的其他技术文档（设计稿、部署文档、接口说明…）都要在 ProjectGuide「文档索引」登记一行（链接 + 一句话用途 + 状态）。
- **回复首行标注**：每次回复用户开头显式写 `已对照 ProjectGuide.md`（找不到文件时写明「未找到，先补建」）。

## 二、ProjectGuide 的标准结构（模板摘要）

1. **项目定位** —— 一段话：这是什么、给谁用、部署在哪。
2. **核心目标** —— 编号列表，每条一个功能域、**≤ 3 行**：一句话定位 + 不得破坏的契约（对外接口、权限红线、数据去向）+ 指向 `Modules.md` 同编号小节；契约级细节（交互定稿、字段、接口）写在 Modules.md，让后来者不用翻代码就知道边界。
3. **设计原则** —— 视觉语言（千往系项目写明沿用 `choseway-style`）、控件约定、安全原则、资源红线（如「重活不放 NAS」）。
4. **技术架构** —— 前端 / 后端 / 数据库 / 交付形态 / 端口 / 数据卷。
5. **目标平台** —— 浏览器与设备、响应式断点、部署目标、**访问地址基线**（本机开发 / 内网直连 / 域名反代）。
6. **代码仓库** —— 远端地址、默认分支、不入库内容。
7. **当前阶段** —— 只留**状态摘要**（上线状态 / 线上版本 / 已实现范围）+ **近期里程碑**（一行几条）+ **待办** + **迭代规范**；逐条阶段记录写在 `Changelog.md`（见第三节）。
8. **文档索引** —— 其余文档登记表，`Modules.md` 与 `Changelog.md` 固定排前两行。

## 三、阶段记录（Changelog.md）的写法

每完成一轮有持久价值的工作在 `_Documentation/Changelog.md` 对应月份追加一条 `- YYYY-MM-DD：…`（同日多轮按发生顺序，可标「当日第 N 轮」），并同步刷新 ProjectGuide「当前阶段」的状态摘要。一条写清：**做了什么（定稿 / 实现 / 修复）→ 关键实现位置（文件 / 表 / 接口）→ 验证方式与结果（tsc / 冒烟 N/N / 浏览器实测要点）→ 发布状态（本机 / Docker / NAS）→ 踩坑与规避**。示例：

> - 2026-08-22：人力资源**性别 / 年龄拆为两项独立字段**（设计稿确认后实现）：库表新增 `gender` / `age`，启动迁移从旧列拆出；接口 `gender` / `age` 替代 `genderAge`；前端共用 `GenderIcon.tsx`。验证：`tsc` 零错误、迁移在副本实测、隔离实例 API 冒烟全部符合预期。当晚发布 NAS（直连与反代双路 JSON、生产库两列已创建）。

迭代规范（放在 ProjectGuide「当前阶段」末尾，长期有效）：**本机开发（类型检查零错误）→ 本机 Docker 验证 → 确认通过后最后一步才发布 NAS**。

## 四、全局工作规范（摘要，细则见 [references/global-rules.md](references/global-rules.md)）

| 领域 | 规则 |
| --- | --- |
| 输出 | 默认简体中文；文档默认 `.md` |
| 编码 | 含中文的代码文件 UTF-8（建议带 BOM）读写，只用保持原编码的方式编辑，禁止改变编码的批量重写；**例外：技能 `SKILL.md` 必须无 BOM** |
| 设计 | 通用参考 awesome-design-md / ui-ux-pro-max；千往系视觉一律调用技能 `choseway-style`（取值以其 tokens.json 为准，不凭印象配色） |
| 飞书 | `*.feishu.cn` 链接一律用技能 `feishu-doc` 经 API 读取；凭证在 `W:\Project\AI\_Config\feishu.json`，严禁回显；WebFetch 读不了别试；403 时提示用户加应用「Claude文档读取」为协作者 |
| 技能仓库 | 自制技能统一在 `W:\Project\AI\AI_Skills`（GitHub 私有 `ChoseWay/AI_Skills`），`claude/<name>` / `codex/<name>` 分目录，agent 的 skills 目录只是 junction；新增登记 `CATALOG.md`，改完 git 提交；技能内不写凭证 |
| NAS 部署 | 群晖 DSM `192.168.50.2`（qianwang），SSH 密钥 `agent@`，docker 免密 sudo；流程 build → save → scp → load → 重建容器（数据卷 `/volume1/docker/<项目>/data:/data`）→ 冒烟 → 删 tar；反代用 DSM 系统 nginx，不起 nginx 容器；密码从不明文、不代输；重活不放 NAS（1.7GB 内存） |
| 安全 | 密码哈希 bcrypt、敏感数据 AES-256-GCM 密钥随数据卷、敏感操作留痕；任何凭证只写路径不写值 |

## 五、合规自检（接手 / 收尾时过一遍）

- [ ] ProjectGuide.md 存在且八个章节齐全，首行回复已标注。
- [ ] 本轮涉及的目标 / 原则 / 平台 / 阶段变化已写入；新文档已登记索引。
- [ ] 阶段记录含「验证方式 + 结果 + 发布状态」，不是只有「做了 X」。
- [ ] ProjectGuide 仍是纲领版（≤ 约 150 行 / 20KB）：模块细节在 Modules.md、逐条记录在 Changelog.md，没有把细节搬回 ProjectGuide。
- [ ] 含中文文件编码未被破坏（BOM 状态与原文件一致）。
- [ ] 未在任何文件 / 输出中出现密码、token、app_secret。
- [ ] 若发布了 NAS：本机 Docker 已先验证；生产数据卷未动；冒烟（直连 + 反代）通过。
- [ ] 若新建 / 修改了技能：在 AI_Skills 仓库内操作并已提交；CATALOG 已登记。

## 文件索引

- [templates/ProjectGuide.template.md](templates/ProjectGuide.template.md) —— 新项目直接复制填空的 ProjectGuide 模板（含 Unity 路径变体说明）。
- [templates/Modules.template.md](templates/Modules.template.md) / [templates/Changelog.template.md](templates/Changelog.template.md) —— 配套的功能模块详细说明 / 版本更新记录模板。
- [references/global-rules.md](references/global-rules.md) —— 全局工作规范细则（agent 无关完整版：编码 / 输出 / 设计 / 飞书 / 技能仓库 / NAS 部署与反代 / 安全）。
- 原文快照：仓库 `global/claude/CLAUDE.md`、`global/codex/AGENTS.md`（用 `scripts/sync-global-rules.ps1` 与本机双向同步）。
