# 千往统一图标（coolicons）

千往系产品（ChoseWayManager 千往控制台、AI_报价单生成工具 报价平台等）的**结构性图标统一使用 [coolicons](https://github.com/krystonschwarze/coolicons)**（v4.1，440+ 线性描边图标，CC BY 4.0 可商用——使用的项目须在 README 注明来源署名）。不要再用 emoji / Unicode 字符做导航与按钮图标（渲染因平台而异、彩色 emoji 与红黑暗色 UI 违和）。

## 落地方式（Web / React）

- 每个项目放一份 `web/src/components/Icon.tsx`：把用到的图标 path 内联为 `Ico` 组件（`<Ico name="house" size={16} />`），24×24 viewBox、`stroke="currentColor"`、strokeWidth 2，随主题着色；零 npm 依赖、零字体文件，兼容子路径部署。
- 该文件由本目录 `gen-icons.mjs` 生成（SRC 指向 coolicons 仓库本地 checkout，增删图标改脚本里的 MAP 后重新生成，两个项目同时覆盖）。
- 配套 CSS（两个项目 styles.css 已带）：
  ```css
  .ico > svg, .dd-arrow > svg, .dd-check > svg { display: block; margin: 0 auto; }
  .nav-item .ico { display: inline-flex; align-items: center; justify-content: center; }
  ```
- 组件内已带 `vertical-align: -0.18em` 默认值，文字旁内联（按钮文案前）无需额外处理。

## 现役图标与语义映射（本目录 *.svg 即源文件）

| 名称 | coolicons 源 | 用途（替换的原字符） |
| --- | --- | --- |
| house | Navigation/House_01 | 首页 🏠 |
| kanban | Edit/Columns | 任务看板 📋 |
| gantt | Interface/Chart_Bar_Horizontal_01 | 项目看板/甘特 📽️ |
| archive | File/Archive | 公司资产 📦 |
| lock | Interface/Lock | 公共仓库 🔐 / 编辑锁 🔒 |
| users | User/Users_Group | 人力资源 👥 |
| user | User/User_01 | 账号 👤 |
| settings | Interface/Settings | 设置 ⚙️ |
| shield | Shape/Shield | 管理 🛡️ |
| log-out | Interface/Log_Out | 退出登录 ⏻ |
| close | Menu/Close_MD | 关闭/删除条目按钮 ✕ |
| check | Interface/Check | 选中/确认/已保存 ✓ |
| caret-down / caret-up | Arrow/Caret_*_SM | 下拉箭头 ▾、展开收起 ▼▲ |
| arrow-up / arrow-down | Arrow/Arrow_*_SM | 上移/下移 ↑↓ |
| chevrons-left / chevrons-right | Arrow/Chevron_*_Duo | 升一级 ⇤ / 降一级 ⇥ |
| download | Interface/Download | 下载/导出 ⬇ |
| folders | File/Folders | 项目列表 ▤ |
| trash / trash-full | Interface/Trash_* | 回收站 ↺ / 删除 🗑 |
| warning | Warning/Warning | 警示 ⚠ |

## 边界（第一期范围，2026-09-01 定）

已统一：侧边栏导航、自绘 Select 的 ▾/✓、`icon-btn` 类关闭/删除按钮、下载导出按钮、编辑器工具条（升降级/上下移/垃圾桶）、锁定横幅。
**未动**（语义徽章类，改前按惯例先出设计稿评审）：🔁 重复徽章、⚡ 系统提醒 / 📢 公告 / 📌 待办分区标题、📋/📽/🔐 来源徽章、状态文案里的 ● 等。
