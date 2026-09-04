# 全局工作规则（适用于所有工程的所有对话，Codex 版）

> 本文件是 Codex 的全局规则（`~/.codex/AGENTS.md`），与 Claude Code 的 `~/.claude/CLAUDE.md` 内容等价，原文快照在技能仓库 `AI_Skills/global/`。方法论化版本见技能 `project-guide`（`~/.codex/skills/project-guide/SKILL.md`），读完即可按同一套方式工作。

## 项目纲领文档（最高优先级）

- 在每次思考与执行前，先阅读 `_Documentation/ProjectGuide.md` 或 `Assets/_SCRIPT/_Documentation/ProjectGuide.md`，并以其内容作为当前项目的最高优先级上下文。
- 如果未找到该文件，先向用户询问并确认以下项目须知，按照路径生成好文档后再继续执行：
  - 项目定位
  - 核心目标
  - 设计原则
  - 目标平台
  - 当前阶段
- 当后续对话涉及以上内容的新增或修改时，必须及时同步更新 `_Documentation/ProjectGuide.md` 或 `Assets/_SCRIPT/_Documentation/ProjectGuide.md`。
- ProjectGuide.md 作为项目最高纲领，不记录临时内容，只记录需要持久化的内容，所有生成的其他技术文档需要注册到其中作为文档索引库。
- 保持纲领性与简洁：ProjectGuide 每条只写「一行结论 + 指针」，不堆细节。功能模块的契约级详细说明单开 `_Documentation/Modules.md`（编号与核心目标一一对应；大模块另有各自设计文档），逐条版本 / 阶段更新记录单开 `_Documentation/Changelog.md`（按月分组），两者都登记进文档索引。ProjectGuide「核心目标」每条 ≤ 3 行，只留一句话定位 + 不得破坏的契约；「当前阶段」只留状态摘要 + 近期里程碑 + 待办 + 迭代规范。需要细节时按索引再去读对应文档，不把细节搬回 ProjectGuide。全文超过约 150 行或 20KB 即拆分。新增模块 → Modules.md 加一节 + ProjectGuide 核心目标加一行；每次发布 → Changelog.md 加一条 + ProjectGuide 状态摘要更新。
- 回复用户时，在开头显式说明：`已对照 ProjectGuide.md`。
- 新建 / 补建 ProjectGuide、初始化新项目文档体系、检查项目合规、或要把这套工作规范讲给另一个 agent / 新机器时，使用技能 `project-guide`（含 ProjectGuide / Modules / Changelog 模板、阶段记录写法、全局规范细则与合规自检）。

## 技能的使用方式

- 自制技能统一放在 `~/.codex/skills/<name>/`（每个目录一个 `SKILL.md`，内含触发条件与用法）。开始任务前先看这些技能的 `SKILL.md` 描述，任务命中触发条件就按该技能的说明执行，不要凭印象另起一套。
- 现有技能：
  - `project-guide` —— ProjectGuide 工作法与全局规范细则（本文件的方法论版）。
  - `choseway-style` —— 千往 / ChoseWay 红黑赛博科技风 UI 设计系统（Web / WPF / Unity 跨平台）。
  - `feishu-doc` —— 经飞书开放平台 API 读取飞书云文档 / 表格 / 知识库。
- `~/.codex/skills/<name>` 只是指向 Git 仓库 `AI_Skills`（GitHub 私有 `ChoseWay/AI_Skills`，本机默认克隆到 `W:\Project\AI\AI_Skills`）的目录链接。新建或修改技能一律在该仓库内进行并 git 提交，新增技能要登记仓库 `CATALOG.md`；换机器 / 重装后执行 `scripts/link-skills.ps1` 恢复链接。
- `SKILL.md` 必须为 UTF-8 无 BOM；技能内严禁写入凭证，只写 `W:\Project\AI\_Config\` 下的路径。

## 设计参考

- 前端 UI/UX 设计参考：https://github.com/VoltAgent/awesome-design-md 、https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- 图标库首选 coolicons：https://github.com/krystonschwarze/coolicons （440+ 线性描边 SVG 图标，CC BY 4.0 可商用）。需要线性风格图标素材时优先到这里找；落地方式建议内联 SVG（stroke 用 `currentColor`，随主题变色）。
- 千往 / ChoseWay 风格（红黑赛博科技风）：用户提到「choseway 风格 / 千往风格 / 红黑风 / 赛博科技风 / 与 ChoseWayManager、报价单工具、AssetsViewer 统一视觉」时，一律使用技能 `choseway-style`（`SKILL.md` 速查 + `DESIGN.md` 完整规范 + `tokens.json` 平台无关 token + `PLATFORMS.md` 跨平台降级指南 + `theme.css` / `wpf/*.xaml` / `unity/*.uss|*.cs` 现成实现），按其 token / 配方 / 组件 / 动效 / 响应式规则落地，不要凭印象另起一套配色。不限于 Web：WPF / WinUI 窗口、Unity 编辑器窗口、Tauri / Electron 客户端、设计稿都按该技能套用，取值一律以 tokens.json 为准。

## 飞书云文档读取

- 遇到 `*.feishu.cn` 云文档 / 表格 / 知识库链接时，一律使用技能 `feishu-doc`（脚本 `scripts/feishu-doc.ps1`）经飞书开放平台 API 读取；凭证在 `W:\Project\AI\_Config\feishu.json`，严禁在对话输出中回显凭证与 token。
- 网页抓取无法读取飞书文档（登录墙 + canvas 渲染），不要尝试；浏览器截图仅作应急。
- API 返回 403 时提示用户：在该文档「分享 → 邀请协作者」中添加应用「Claude文档读取」为可阅读。

## 编码与文件规范

- 所有包含中文的代码文件必须以 UTF-8（建议 UTF-8 with BOM）编码读写，并且只允许通过保持原编码的编辑方式修改，禁止使用会改变文件编码或代码页的批量替换 / 重写命令。

## 输出规范

- 所有回复默认使用简体中文，除非明确要求用其他语言。
- 所有文档格式默认输出为 .md 格式，除非明确要求用其他格式。
- 如实报告结果：测试失败就贴输出；跳过的步骤写明跳过；完成并验证的直说。

## NAS 部署通用流程（群晖 DSM，内网 192.168.50.2，主机名 qianwang）

- 通道：SSH 密钥认证 `-i %USERPROFILE%\.ssh\quote_nas_ed25519` 登录 `agent@192.168.50.2`；agent 已配置 docker 免密 sudo（仅限 `/usr/local/bin/docker`，用 `sudo -n`）。没有这把密钥的机器不做 NAS 发布，把命令交给有权限的人执行。
- 安全约定：任何密码一律不明文记录、不代输；需要 sudo 密码或 DSM 网页登录的操作，准备好命令 / 步骤交由用户执行。
- 镜像发布通用步骤（amd64）：本机 `docker build` → `docker save -o <项目>.tar` → `scp -O` 上传到 `/var/services/homes/agent/` → ssh 远程执行 `sudo -n /usr/local/bin/docker load` / `rm -f <容器>` / `run -d --restart unless-stopped -p <端口> -v /volume1/docker/<项目>/data:/data` 重建容器 → HTTP 冒烟验证 → 删除 tar。数据一律放挂载卷，升级不受影响。
- 域名反代：用 DSM 系统 nginx（80/443 已被其占用，勿再起 nginx 容器）。按主机名的反代走 DSM「登录门户 → 高级 → 反向代理」UI；按路径的反代将 server 配置放入 `/usr/local/etc/nginx/sites-enabled/`（写入与 `nginx -t && nginx -s reload` 需用户 sudo 在 NAS 上执行）。应用需支持子路径部署（前端相对路径）。
- 资源红线：NAS 总内存约 1.7GB 且跑着多个容器，长耗时 / 高 CPU / 栅格化类任务一律放浏览器端或客户端，服务端只发字节。
- 迭代规范：日常开发与测试全部在本机完成（含本机 Docker 验证），确认通过后最后一步才发布到 NAS。
