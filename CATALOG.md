# 技能清单

> 新增 / 迁移技能时在这里登记一行。「适用」= 该技能实际被哪个 agent 加载（通过 link-skills.ps1 链接）。

| 技能 | 目录 | 用途 | 触发 | 来源 | 适用 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| choseway-style | `claude/choseway-style` | 千往 / ChoseWay 红黑赛博科技风 UI 设计系统（跨平台）：tokens.json、DESIGN.md 规范、PLATFORMS.md 降级指南、theme.css / WPF XAML / Unity USS + IMGUI 助手 | 「choseway 风格 / 千往风格 / 红黑风 / 赛博科技风 / 与 ChoseWayManager 统一视觉」，Web / Tauri / WPF / Unity 窗口 / 设计稿套用 | 自制（2026-08-23，源自 AI_ChoseWayManager `web/src/styles.css`） | Claude + Codex（CrossLink） | 源项目样式变更须同步更新；C# IMGUI 助手未经 Unity 编译验证 |
| project-guide | `claude/project-guide` | ProjectGuide 工作法（开工先对照 / 缺失先建 / 变更即同步 / 文档登记 / 首行标注 / 三文件分工：ProjectGuide 纲领 + Modules.md 模块细节 + Changelog.md 阶段记录）+ 全局工作规则细则（编码 / 输出 / 设计 / 飞书 / 技能仓库 / NAS 部署 / 安全）+ ProjectGuide 模板 + 合规自检 | 新建或补建 ProjectGuide、新项目初始化文档体系、检查合规、把工作规范教给另一个 agent / 新机器、「按我的全局规则 / 千往工作流」 | 自制（2026-08-23，源自 ~/.claude/CLAUDE.md 与 ChoseWayManager 实践） | Claude + Codex（CrossLink） | 原文快照在 `global/`，用 sync-global-rules.ps1 同步 |
| feishu-doc | `claude/feishu-doc` | 经飞书开放平台 API 读取云文档 / 表格 / 知识库（`scripts/feishu-doc.ps1`） | 收到 `*.feishu.cn` 链接 | 自制 | Claude + Codex（CrossLink） | 凭证在 `W:\Project\AI\_Config\feishu.json`（不入库）；403 时提示用户把应用「Claude文档读取」加为协作者 |

## 链接到 Codex

三个技能都是 agent 无关的，Codex 侧用交叉链接：`pwsh -File scripts/link-skills.ps1 -ToCodex choseway-style,feishu-doc,project-guide`；新机器上手见 [ONBOARDING-CODEX.md](ONBOARDING-CODEX.md)。

## 待收编（Codex 侧，按需执行 `scripts/adopt-skill.ps1 -Agent codex -Name <name>`）

`~/.codex/skills/` 目前看起来属于自制 / 定制的有：`hatch-pet`、`unity-mcp-skill`、`unity-asset-library-showcase`；`doc` / `pdf` / `playwright`（OpenAI 官方带 LICENSE）、`ui-ux-pro-max`（第三方整包）、`.system/*`（系统内置）不建议入库。
