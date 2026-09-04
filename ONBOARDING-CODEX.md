# 新机器 / 新账号上手：让 Codex 使用本仓库的技能与全局规则

> 适用场景：团队成员用共享的 GPT 账号在自己电脑上跑 Codex，需要和 Claude Code 同一套技能（`project-guide` / `choseway-style` / `feishu-doc`）与全局工作规则。
> 前提（由人完成，Codex 不代做）：① 本机装好 Git、PowerShell 7（`pwsh`）、Codex CLI 或 Codex 桌面版；② 本 GitHub 账号已被加为私有仓库 `ChoseWay/AI_Skills` 的协作者，且本机 `git clone` 私有仓库能过认证（HTTPS 凭证管理器或 SSH key）；③ 如需飞书读取，向管理员索取 `feishu.json` 放到 `W:\Project\AI\_Config\`（不入库、不发聊天）。

## 一、直接粘贴给 Codex 的提示词

```text
请按下面步骤把我们团队的 Agent 技能仓库接入本机 Codex，并把全局规则装好。全程用 PowerShell 7（pwsh）执行，每一步都把实际输出贴给我，失败就停下来说明原因，不要自行绕过。

1. 克隆技能仓库（GitHub 私有仓库，我已加好协作者；若目标目录已存在就 git pull 更新）：
   git clone https://github.com/ChoseWay/AI_Skills.git W:\Project\AI\AI_Skills
   如果本机没有 W: 盘，改用 D:\Project\AI\AI_Skills 并告诉我你用了哪个路径。

2. 读一遍仓库根目录的 README.md 与 CATALOG.md，用三句话向我复述：仓库怎么分目录、技能怎么链接、全局规则怎么同步。

3. 把技能链接到 Codex 的技能目录（脚本会在 ~/.codex/skills/ 下建目录 junction，不复制文件）：
   pwsh -File W:\Project\AI\AI_Skills\scripts\link-skills.ps1 -ToCodex choseway-style,feishu-doc,project-guide
   然后列出 ~/.codex/skills/ 下这三个目录，确认它们是 Junction 且各自含 SKILL.md。

4. 安装全局规则：把仓库里的 global/codex/AGENTS.md 写到 ~/.codex/AGENTS.md：
   pwsh -File W:\Project\AI\AI_Skills\scripts\sync-global-rules.ps1 -Push
   如果 ~/.codex/AGENTS.md 已存在且内容不同，脚本会先备份为 .bak-时间戳 再覆盖；把备份文件名告诉我。脚本同时会尝试写 ~/.claude/CLAUDE.md，本机没装 Claude Code 也没关系。

5. 验证：
   - 打开 ~/.codex/AGENTS.md，确认开头是「# 全局工作规则（适用于所有工程的所有对话，Codex 版）」，并含「技能的使用方式」一节。
   - 分别打开 ~/.codex/skills/project-guide/SKILL.md、choseway-style/SKILL.md、feishu-doc/SKILL.md，各用一句话告诉我它的触发条件。
   - 确认三个 SKILL.md 文件开头没有 UTF-8 BOM（前三个字节不是 EF BB BF）。

6. 从现在起，本机所有对话都遵守 ~/.codex/AGENTS.md：开工先读项目的 _Documentation/ProjectGuide.md，回复首行写「已对照 ProjectGuide.md」；遇到千往 / choseway 风格用 choseway-style 技能，遇到 *.feishu.cn 链接用 feishu-doc 技能，新建或检查项目文档体系用 project-guide 技能。技能文件只能在 W:\Project\AI\AI_Skills 仓库内修改并 git 提交，新技能要登记 CATALOG.md；任何凭证只写路径不写值。

完成后给我一份清单：克隆路径、三个链接的目标路径、AGENTS.md 是否已安装、有无备份文件、验证结果。
```

## 二、Codex 的规则与技能放在哪里

| 项目 | 路径 | 来源 |
| --- | --- | --- |
| 全局规则 | `~/.codex/AGENTS.md` | 仓库 `global/codex/AGENTS.md`，`sync-global-rules.ps1 -Push` 写入；改了本机规则用 `-Pull` 收回仓库再提交 |
| 技能 | `~/.codex/skills/<name>/SKILL.md` | 仓库 `claude/<name>/`，经 `link-skills.ps1 -ToCodex` 建 junction |
| 凭证 | `W:\Project\AI\_Config\` | 不在仓库，人工分发 |

## 三、日常维护

- 规则或技能有更新：在任一台机器上 `git pull` 即可（junction 指向仓库目录，无需重跑链接脚本）；只有 `AGENTS.md` 是快照，更新后要再跑一次 `sync-global-rules.ps1 -Push`。
- 团队成员新写了技能：在仓库 `claude/<name>/` 下写 `SKILL.md`（UTF-8 无 BOM），登记 `CATALOG.md`，提交前跑 `scripts/scan-secrets.ps1`，push 后通知其他人 pull。
- 仓库含内网主机名 / IP / SSH 用户名，保持 GitHub 私有，不要 fork 到个人公开账号。
