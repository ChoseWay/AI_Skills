# 全局工作规范细则（agent 无关完整版）

> 与 `global/claude/CLAUDE.md` 内容等价，但去掉了 Claude 专有措辞，便于 Codex 或其他 agent 直接采用。凡是路径、主机名、端口都是本机 / 内网的事实，不要改写。

## 1. 项目纲领文档

见 SKILL.md 第一至三节。补充：
- 多个仓库同属一个产品线时，每个仓库各自一份 ProjectGuide；跨仓库契约（如 SSO 共享 Cookie）在两边都写明「对外契约，修改不得破坏」。
- ProjectGuide 不放代码片段长文，放「结论 + 位置指针」；细节进独立设计文档并登记索引。
- 设计评审类文档标注状态（评审中 / 已定稿 / 已实现），实现后回写「已实现于 …」。

## 2. 输出规范

- 回复默认简体中文；文档默认 Markdown（`.md`）。
- 回复首行 `已对照 ProjectGuide.md`。
- 报告结果要如实：测试失败就贴输出；跳过的步骤写明跳过；完成并验证的就直说。

## 3. 编码与文件规范

- 含中文的代码文件：UTF-8（建议带 BOM）读写；只用保持原编码的方式编辑（逐段替换、按原编码写回），禁止会改变编码 / 代码页的批量替换或整文件重写命令。
- 动手前看一眼文件头三个字节决定是否带 BOM，写回时保持一致。
- **例外**：Agent 技能的 `SKILL.md` 必须 UTF-8 **无 BOM**（带 BOM 会让 frontmatter 解析失败、技能不触发）；技能内其他 .md / .css / .cs 不限。
- JSON 配置文件一律无 BOM（多数解析器不接受）。

## 4. 设计参考

- 通用：https://github.com/VoltAgent/awesome-design-md 、https://github.com/nextlevelbuilder/ui-ux-pro-max-skill 。
- 千往 / ChoseWay 系产品（ChoseWayManager、报价单工具、AssetsViewer、桌面小组件及其延伸）：一律调用技能 `choseway-style`——红黑赛博科技风；Web 引 `theme.css`，WPF 引 `wpf/ChoseWayTheme.xaml`，Unity 引 `unity/ChoseWayTheme.uss` 或 IMGUI 助手 `unity/ChoseWayEditorTheme.cs`；取值以 `tokens.json` 为准；源头实现 `AI_ChoseWayManager/web/src/styles.css` 变更时同步更新技能。
- 复杂 UI 改版先出设计稿（Claude Design / HTML 原型）评审定稿，再实现；定稿结论回写 ProjectGuide 设计原则或对应设计文档。

## 5. 飞书云文档

- `*.feishu.cn` 文档 / 表格 / 知识库链接：调用技能 `feishu-doc`（脚本 `scripts/feishu-doc.ps1`）经飞书开放平台 API 读取，只读、结构化、全量。
- 凭证文件 `W:\Project\AI\_Config\feishu.json`（`app_id` / `app_secret`），严禁在任何输出、日志、提交中回显凭证与 token。
- 浏览器 WebFetch 读不了飞书（登录墙 + canvas 渲染），不要尝试；截图仅应急。
- API 返回 403 / 1310213：提示用户在该文档「分享 → 邀请协作者」添加应用「Claude文档读取」为可阅读。

## 6. 技能仓库

- 自制技能统一存放 `W:\Project\AI\AI_Skills`（GitHub 私有 `ChoseWay/AI_Skills`）；目录 `claude/<name>/`、`codex/<name>/`、`global/`（全局规则快照）、`scripts/`。
- `~/.claude/skills/<name>`、`~/.codex/skills/<name>` 只是指向仓库的目录 junction；新建 / 修改技能一律在仓库内进行并 `git commit`；新增技能登记 `CATALOG.md`。
- 恢复：`git clone` 后运行 `scripts/link-skills.ps1`；收编已有技能用 `scripts/adopt-skill.ps1 -Agent claude|codex -Name <name>`；全局规则快照用 `scripts/sync-global-rules.ps1 -Pull|-Push`。
- 只收自制 / 深度定制技能；官方内置与第三方整包不入库。技能内不写凭证，只写 `W:\Project\AI\_Config\` 下的路径。

## 7. NAS 部署（群晖 DSM，内网 192.168.50.2，主机名 qianwang）

- 通道：`ssh -i %USERPROFILE%\.ssh\quote_nas_ed25519 agent@192.168.50.2`；`agent` 已配置 docker 免密 sudo（`/etc/sudoers.d/agent-docker`，仅限 `/usr/local/bin/docker`，用 `sudo -n`）。
- 安全：任何密码不明文记录、不代输；需要 sudo 密码或 DSM 网页登录的操作，准备好命令 / 步骤交给用户执行。
- 镜像发布（amd64）：本机 `docker build` → `docker save -o <项目>.tar` → `scp -O` 到 `/var/services/homes/agent/` → 远程 `sudo -n /usr/local/bin/docker load` → `docker rm -f <容器>` → `docker run -d --restart unless-stopped -p <端口> -v /volume1/docker/<项目>/data:/data <镜像>` → HTTP 冒烟（直连端口 + 域名反代双路）→ 删除 tar（可顺手 `image prune` 回收悬空层）。数据一律放挂载卷，升级不受影响。
- 反代：用 DSM 系统 nginx（80/443 已被占用，勿再起 nginx 容器）。按主机名 → DSM「登录门户 → 高级 → 反向代理」UI；按路径 → server 配置放 `/usr/local/etc/nginx/sites-enabled/`（写入与 `nginx -t && nginx -s reload` 需用户 sudo 在 NAS 上执行；本机 PowerShell 远程执行会双重报错）。应用须支持子路径部署（前端相对路径）。
- 资源红线：DS220+ 总内存约 1.7GB、空闲常剩 200~300MB，还跑着其他八九个容器；长耗时 / 高 CPU / 栅格化类任务一律放浏览器端或客户端，服务端只发字节；判断余量看整机 `available` 与 swap，不看单容器。曾因常驻转换容器拖垮整机 Docker（OOM 清场），不要重蹈。
- 迭代规范：日常开发与测试全部在本机完成（含本机 Docker 验证；Windows bind mount 下 SQLite WAL 会报 `SQLITE_IOERR_SHMOPEN`，本机验证改用命名卷），确认通过后最后一步才发布 NAS。
- 发布后回写 ProjectGuide 阶段记录：镜像大小 / 冒烟结果 / 生产数据卷未动 / NAS 剩余内存。

## 8. 安全基线（产品内）

- 密码哈希 bcrypt；敏感字段 AES-256-GCM，密钥文件随数据卷、不进镜像不进代码库；登录限速；会话 HMAC 签名 httpOnly Cookie；敏感操作审计留痕。
- 富文本 / 用户输入走白名单净化；附件 Content-Type 按扩展名判定不用客户端声明。
