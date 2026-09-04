# ProjectGuide —— <项目名>（<一句话副标题>）

> 本文件为项目最高纲领。任何思考与执行前必须先对照本文件；涉及以下内容的新增或修改必须同步更新本文件。
> 存放位置：`_Documentation/ProjectGuide.md`（Unity 工程：`Assets/_SCRIPT/_Documentation/ProjectGuide.md`）。
> **本文件只写纲领**：每条「一行结论 + 指针」。功能模块的契约级细节在 [Modules.md](Modules.md)，逐条阶段 / 版本记录在 [Changelog.md](Changelog.md)，用到时按文档索引再去读。新增模块 → Modules.md 加一节 + 本文核心目标加一行；每次发布 → Changelog.md 加一条 + 本文「当前阶段」更新状态摘要。

## 项目定位

<这是什么 / 给谁用 / 解决什么问题 / 部署在哪。一段话说清。>

## 核心目标

编号与 [Modules.md](Modules.md) 各节一一对应；每条 ≤ 3 行，只写一句话定位与**不得破坏的契约**。

1. **<功能域 A>**：<一句话定位；对外契约 / 权限红线 / 数据去向。细节见 Modules.md 第 1 节。>
2. **<功能域 B>**：<…>
3. <…>

## 设计原则

- **视觉**：<千往系项目写「沿用全局技能 `choseway-style`（红黑赛博科技风），取值以其 tokens.json 为准，纯暗色」；其他项目写明参考与基调>
- **控件 / 交互约定**：<自绘组件集中位置、禁止的原生控件、右键 / 拖拽 / 快捷键约定>
- **安全**：<密码哈希 / 加密方式与密钥存放 / 会话机制 / 审计留痕>
- **资源红线**：<例如「长耗时 / 高 CPU 的活放客户端，服务端只发字节」「不往 NAS 放常驻重任务」>
- UI/UX 参考：https://github.com/VoltAgent/awesome-design-md 、https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

## 技术架构

- 前端：<框架 / 构建 / 相对路径与子路径部署支持>
- 后端：<运行时 / 框架 / 关键中间件>
- 数据库：<类型 / 文件位置 / 备份策略>
- 交付：<Docker 单容器 amd64 / 端口 / 数据卷；或安装包 / Unity 包等>
- 其他：<桌面壳 / 脚本 / 外部服务>

## 目标平台

- <浏览器 / 设备 / 响应式断点与降级规则；或 Unity 版本 / 目标平台>
- 部署：<NAS 路径 / 云 / 本地>
- 访问地址基线：
  - 本机开发：`http://localhost:<port>`
  - 内网直连：`http://192.168.50.2:<port>`
  - 域名反代：`http://qianwang/<path>`（DSM 系统 nginx，配置文件与 location 写明）

## 代码仓库

- <GitHub 地址（私有 / 公开）>，默认分支 `main`；不入库：<data/、密钥、构建产物、node_modules>。

## 当前阶段

逐条记录见 [Changelog.md](Changelog.md)；这里只保留状态摘要。

- **状态**：<上线状态 / 线上版本 / 已实现范围>
- **近期里程碑**：<MM-DD 一句话；MM-DD 一句话…>
- **待办**：<…>
- 迭代规范：本机开发（类型检查零错误）→ 本机 Docker 验证 → 确认通过后最后一步发布 NAS（流程见 Deploy.md）。

## 文档索引

- [Modules.md](Modules.md) —— 功能模块详细说明（核心目标各节的契约级细节；改模块逻辑前先读对应小节）
- [Changelog.md](Changelog.md) —— 版本更新记录（逐条阶段记录，按月分组）
- [Deploy.md](Deploy.md) —— 本机开发 / 本机 Docker 验证 / NAS 部署与反代 / 备份恢复 / 升级流程
- [<XXX-Design.md>](<XXX-Design.md>) —— <模块> 设计稿（<状态：评审中 / 已定稿 / 已实现>）
