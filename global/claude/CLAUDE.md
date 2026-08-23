# 全局工作规则（适用于所有工程的所有对话）

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
- 回复用户时，在开头显式说明：`已对照 ProjectGuide.md`。
- 新建 / 补建 ProjectGuide、初始化新项目文档体系、检查项目合规、或要把这套工作规范讲给另一个 agent / 新机器时，调用全局技能 `project-guide`（含 ProjectGuide 模板、阶段记录写法、全局规范细则与合规自检）。本文件是规则原文，技能是其方法论化版本；本文件修改后运行 `W:\Project\AI\AI_Skills\scripts\sync-global-rules.ps1 -Pull` 并提交，保持仓库快照同步。

## 设计参考

- 前端 UI/UX 设计参考：https://github.com/VoltAgent/awesome-design-md 、https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- **千往 / ChoseWay 风格（红黑赛博科技风）**：用户提到「choseway 风格 / 千往风格 / 红黑风 / 赛博科技风 / 与 ChoseWayManager、报价单工具、AssetsViewer 统一视觉」时，一律调用全局技能 `choseway-style`（`~/.claude/skills/choseway-style`：`SKILL.md` 速查 + `DESIGN.md` 完整规范 + `tokens.json` 平台无关 token + `PLATFORMS.md` 跨平台降级指南 + `theme.css` / `wpf/*.xaml` / `unity/*.uss|*.cs` 现成实现），按其 token / 配方 / 组件 / 动效 / 响应式规则落地，不要凭印象另起一套配色。**不限于 Web**：WPF / WinUI 窗口、Unity 编辑器窗口（UI Toolkit / IMGUI）、Tauri / Electron 客户端、设计稿都按该技能套用，取值一律以 tokens.json 为准。源头实现为 `W:\Project\AI\AI_ChoseWayManager\web\src\styles.css`；该设计系统有变更时同步更新技能文件。

## 飞书云文档读取（全局）

- 遇到 `*.feishu.cn` 云文档/表格/知识库链接时，一律调用全局技能 `feishu-doc`（`~/.claude/skills/feishu-doc`，脚本 `scripts/feishu-doc.ps1`）经飞书开放平台 API 读取；凭证在 `W:\Project\AI\_Config\feishu.json`，严禁在对话输出中回显凭证与 token。
- WebFetch 无法读取飞书文档（登录墙 + canvas 渲染），不要尝试；浏览器截图仅作应急。
- API 返回 403 时提示用户：在该文档「分享→邀请协作者」中添加应用「Claude文档读取」为可阅读。

## 技能仓库（全局）

- 自制技能统一存放在 Git 仓库 `W:\Project\AI\AI_Skills`（GitHub 私有 `ChoseWay/AI_Skills`），按 `claude/<name>/` 与 `codex/<name>/` 分目录；`~/.claude/skills/<name>` 只是指向仓库的 junction。**新建或修改技能一律在该仓库内进行并 git 提交**，新增技能要登记仓库 `CATALOG.md`；换机器 / 重装后执行 `scripts/link-skills.ps1` 恢复链接；已在 agent 目录里写好的技能用 `scripts/adopt-skill.ps1 -Agent claude|codex -Name <name>` 收编。
- `SKILL.md` 必须为 UTF-8 无 BOM（带 BOM 会导致 frontmatter 解析失败、技能不触发）；技能内严禁写入凭证，只写 `W:\Project\AI\_Config\` 下的路径。

## 编码与文件规范

- 所有包含中文的代码文件必须以 UTF-8（建议 UTF-8 with BOM）编码读写，并且只允许通过保持原编码的编辑方式修改，禁止使用会改变文件编码或代码页的批量替换/重写命令。

## 输出规范

- 所有回复默认使用简体中文，除非明确要求用其他语言。
- 所有文档格式默认输出为 .md 格式，除非明确要求用其他格式。

## NAS 部署通用流程（群晖 DSM，内网 192.168.50.2，主机名 qianwang）

- 通道：SSH 密钥认证 `-i %USERPROFILE%\.ssh\quote_nas_ed25519` 登录 `agent@192.168.50.2`；agent 已配置 docker 免密 sudo（/etc/sudoers.d/agent-docker，仅限 /usr/local/bin/docker）。
- 安全约定：任何密码一律不明文记录、不由 Claude 代输；需要 sudo 密码或 DSM 网页登录的操作，准备好命令/步骤后交由用户执行。
- 镜像发布通用步骤（amd64）：本机 `docker build` → `docker save -o <项目>.tar` → `scp -O` 上传到 `/var/services/homes/agent/` → ssh 远程执行 `sudo -n /usr/local/bin/docker load` / `rm -f <容器>` / `run -d --restart unless-stopped -p <端口> -v /volume1/docker/<项目>/data:/data` 重建容器 → HTTP 冒烟验证 → 删除 tar。数据一律放挂载卷，升级不受影响。
- 域名反代：用 DSM 系统 nginx（80/443 已被其占用，勿再起 nginx 容器）。按主机名的反代走 DSM「登录门户→高级→反向代理」UI；按路径的反代将 server 配置放入 `/usr/local/etc/nginx/sites-enabled/`（写入与 `nginx -t && nginx -s reload` 需用户 sudo 执行）。应用需支持子路径部署（前端相对路径）。
- 迭代规范：日常开发与测试全部在本机完成（含本机 Docker 验证），确认通过后最后一步才发布到 NAS。