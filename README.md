# AI_Skills —— 个人 Agent 技能仓库（Claude Code + Codex）

> 目的：把散落在 `~/.claude/skills/`、`~/.codex/skills/` 里的自制技能统一纳入版本控制，卸载 / 重装 / 换机器都不丢；各 agent 的技能目录只放**指向本仓库的目录链接（junction）**。

## 目录规范

```
AI_Skills/
├─ claude/                 Claude Code 技能（每个子目录一个技能，必须含 SKILL.md）
│  ├─ choseway-style/      千往红黑赛博科技风设计系统（跨平台：Web / WPF / Unity）
│  └─ feishu-doc/          飞书云文档 API 读取
│  └─ project-guide/       ProjectGuide 工作法 + 全局工作规则（agent 无关，可 CrossLink 给 Codex）
├─ codex/                  Codex 技能（同为 Agent Skills 标准：SKILL.md + 可选 agents/openai.yaml、scripts/、references/）
├─ global/                 agent 全局规则文件的原文快照（不是技能，不会被链接）
│  ├─ claude/CLAUDE.md     ← ~/.claude/CLAUDE.md
│  └─ codex/AGENTS.md      ← ~/.codex/AGENTS.md
├─ scripts/
│  ├─ link-skills.ps1      把仓库里的技能链接到 ~/.claude/skills 与 ~/.codex/skills（换机器 / 重装后执行一次）
│  ├─ adopt-skill.ps1      把已存在于 ~/.claude/skills 或 ~/.codex/skills 的技能「收编」进仓库并换成链接
│  ├─ sync-global-rules.ps1  全局规则快照同步：-Pull 本机→仓库（改完规则后）/ -Push 仓库→本机（恢复）
│  └─ scan-secrets.ps1     提交前扫凭证 / 密钥 / 个人邮箱（-History 连同全部历史）
├─ CATALOG.md              技能清单（名称 / 用途 / 触发 / 来源 / 适用 agent）—— 新增技能必须登记
└─ README.md
```

- **按 agent 分一级目录**（`claude/`、`codex/`），二级目录名 = 技能名（kebab-case，与 `SKILL.md` 的 `name` 一致）。
- 两边都用 [Agent Skills](https://agentskills.io) 的 `SKILL.md` 格式，一个技能若两边通用，**只保留一份**放在首次编写它的 agent 目录下，另一边用链接脚本的 `-ToCodex <名1>,<名2>` 再链一次（见 CATALOG 的「适用」列；新机器上手见 [ONBOARDING-CODEX.md](ONBOARDING-CODEX.md)）。
- 只收**自制或深度定制**的技能；官方内置（Codex `.system/`、`doc/pdf/playwright` 等带 LICENSE 的官方包）和第三方整包安装的技能不入库，需要时重新安装即可。
- 严禁提交凭证：密钥文件统一放 `W:\Project\AI\_Config\`（不在仓库内），技能里只写路径；每次提交前跑 `scripts/scan-secrets.ps1`（命中退出码 2）。仓库保持 GitHub **私有**——内容含内网 IP / 主机名 / SSH 用户名等基础设施标识，不可公开。
- `SKILL.md` 必须是 **UTF-8 无 BOM**（带 BOM 会让 Claude Code 解析不到 frontmatter，技能描述显示为 `---`）；其他 .md / .css / .cs 带不带都行。

## 日常流程

- **新建技能**：直接在本仓库对应目录下写（`claude/<name>/SKILL.md`），然后跑一次 `scripts/link-skills.ps1` 建链接；登记 CATALOG.md；提交。
- **已在 agent 目录里写好的技能**：`scripts/adopt-skill.ps1 -Agent claude -Name <name>`（或 `-Agent codex`）会把它搬进仓库、原位换成 junction。
- **修改技能**：链接是透明的，在任一侧编辑都是改仓库里的文件，改完 `git commit` 即可。
- **Claude 全局规则**（`~/.claude/CLAUDE.md`）里对技能的引用路径仍写 `~/.claude/skills/<name>`，不要写仓库绝对路径，保持链接层解耦。

## 全局规则（CLAUDE.md / AGENTS.md）

- 本机规则文件无法用 junction 链接（跨卷文件链接需管理员），所以走**快照同步**：改了 `~/.claude/CLAUDE.md` 或 `~/.codex/AGENTS.md` 之后跑 `scripts/sync-global-rules.ps1 -Pull` 再提交；新机器 `-Push` 写回。
- 规则的方法论化版本在技能 `claude/project-guide/`（含 ProjectGuide 模板与全局规范细则），给任何 agent 读都能照做。

## 换机器 / 重装恢复

```powershell
git clone https://github.com/ChoseWay/AI_Skills.git W:\Project\AI\AI_Skills
pwsh -File W:\Project\AI\AI_Skills\scripts\link-skills.ps1         # 加 -WhatIf 先预览
pwsh -File W:\Project\AI\AI_Skills\scripts\link-skills.ps1 -ToCodex choseway-style,feishu-doc,project-guide   # 通用技能也链给 Codex
pwsh -File W:\Project\AI\AI_Skills\scripts\sync-global-rules.ps1 -Push   # 恢复 CLAUDE.md / AGENTS.md
```

脚本会为 `claude/*` 在 `~/.claude/skills/` 下、`codex/*` 在 `~/.codex/skills/` 下分别创建 junction；目标已存在且不是链接时会跳过并提示（避免覆盖你本机的新内容，此时用 adopt-skill.ps1 收编）。

## 备注

- Windows 的目录 junction 不需要管理员权限，Claude Code / Codex 读取技能时与普通目录无异。
- 仓库根下没有 `SKILL.md`，所以不要把仓库根目录本身链接进 agent 的 skills 目录——按技能逐个链接。
