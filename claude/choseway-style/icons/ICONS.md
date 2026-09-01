# 千往统一图标（coolicons）

千往系产品（ChoseWayManager 千往控制台、AI_报价单生成工具 报价平台等）的**界面图标统一使用 [coolicons](https://github.com/krystonschwarze/coolicons)**（v4.1，440+ 线性描边图标，CC BY 4.0 可商用——使用的项目须在 README 注明来源署名）。不要用 emoji / Unicode 字符做导航、按钮、徽章图标（渲染因平台而异、彩色 emoji 与红黑暗色 UI 违和）。2026-09-01 两平台已全量替换并发布 NAS。

## 落地方式（Web / React）

- 每个项目放一份 `web/src/components/Icon.tsx`：把用到的图标 path 内联为 `Ico` 组件（`<Ico name="house" size={16} />`），24×24 viewBox、`stroke="currentColor"`、strokeWidth 2，随主题着色；零 npm 依赖、零字体文件，兼容子路径部署。
- 该文件由本目录 `gen-icons.mjs` 生成（SRC 指向 coolicons 仓库本地 checkout，增删图标改脚本里的 MAP 后重新生成，**两个项目的 Icon.tsx 同时覆盖，勿手改路径数据**）。
- 配套 CSS（两个项目 styles.css 已带）：
  ```css
  .ico > svg, .dd-arrow > svg, .dd-check > svg { display: block; margin: 0 auto; }
  .nav-item .ico { display: inline-flex; align-items: center; justify-content: center; }
  ```
- 组件内已带 `vertical-align: -0.18em` 默认值，文字旁内联（按钮文案前）无需额外处理。

## 现役图标与语义映射（本目录 *.svg 即源文件）

### 第一期 · 导航与通用操作

| 名称 | coolicons 源 | 用途（替换的原字符） |
| --- | --- | --- |
| house | Navigation/House_01 | 首页 🏠 |
| kanban | Edit/Columns | 任务看板 📋（含来源徽章） |
| gantt | Interface/Chart_Bar_Horizontal_01 | 项目看板/甘特 📽️（含项目徽章） |
| archive | File/Archive | 公司资产 📦 / 物资补充卡 |
| lock | Interface/Lock | 公共仓库 🔐 / 编辑锁 🔒 / 私人标签 / 复制密码 🔑 |
| users | User/Users_Group | 人力资源 👥（含来源徽章、团队卡） |
| user | User/User_01 | 账号 👤 / 复制账号 |
| settings | Interface/Settings | 设置 ⚙️ / 列设置 / 阶段设置 |
| shield | Shape/Shield | 管理 🛡️ |
| log-out | Interface/Log_Out | 退出登录 ⏻ |
| close | Menu/Close_MD | 关闭/删除条目按钮 ✕ |
| check | Interface/Check | 选中/确认/已保存/已面试 ✓ |
| caret-down / caret-up | Arrow/Caret_*_SM | 下拉箭头 ▾、展开收起 ▼▲ |
| arrow-up / arrow-down | Arrow/Arrow_*_SM | 上移/下移 ↑↓ |
| chevrons-left / chevrons-right | Arrow/Chevron_*_Duo | 升一级 ⇤ / 降一级 ⇥ |
| download | Interface/Download | 下载/导出 ⬇ |
| folders | File/Folders | 项目列表 ▤ |
| trash / trash-full | Interface/Trash_* | 回收站 ↺ / 删除 🗑 |
| warning | Warning/Triangle_Warning | 警示 ⚠ |

### 第二期 · 语义徽章与页面按钮（全量）

| 名称 | coolicons 源 | 用途（替换的原字符） |
| --- | --- | --- |
| bell-ring | Communication/Bell_Ring | ⚡ 系统提醒分区标题 |
| speaker | Media/Volume_Max | 📢 重要公告卡 |
| list-check | Edit/List_Check | 📌 提醒事项卡 |
| repeat | Arrow/Arrows_Reload_01 | 🔁 重复徽章 |
| external-link | Interface/External_Link | 🚀 平台入口卡 |
| edit | Edit/Edit_Pencil_01 | ✎ 编辑/重命名按钮 |
| folder | File/Folder | 🗂 归档区 |
| link | Interface/Link | 🔗 联动徽章/提示 |
| note | File/Note | 🗒 备注徽章 |
| alarm | Calendar/Alarm | 🔥 紧急胶囊开关 |
| star | Interface/Star | ⭐ 重要胶囊开关 / ★ 评分 |
| timer | Calendar/Timer | ⏱ 截止徽章 / 整组工时 |
| camera | System/Camera | 📷 拍照 |
| image | Media/Image_01 | 🖼️ 相册 |
| tag | Interface/Tag | 🏷️ 分类 |
| map-pin | Navigation/Map_Pin | 📍 位置 |
| desktop | System/Desktop | 🗄️ 固定资产占位图 |
| water-drop | Environment/Water_Drop | 🧻 消耗品占位图 |
| swap | Arrow/Arrow_Left_Right | 🤝 借用占位图/来源 |
| calendar | Calendar/Calendar | 📥 借入日期 |
| cart | Interface/Shopping_Cart_01 | 🛒 购买时间 |
| return | Arrow/Arrow_Undo_Up_Left | 📤 归还日期 |
| expand / shrink | Arrow/Expand · Shrink | ⤢ 放大预览 / ⤡ 恢复并排 |
| sub-right | Arrow/Arrow_Sub_Down_Right | ⤷ 添加子级 |
| flag | Navigation/Flag | 备用（Deadline ⚑ 保留字符，见下） |

## 刻意保留（不替换）

- **甘特 Deadline ⚑**：CSS `content: "⚑"` 标记、图例、右键菜单文字三处统一保留字符（单色字形、跨处一致）。
- **平台入口条目图标**：管理员在界面自配的 emoji，属用户数据不属 UI。
- **状态圆点 ●**、RichText 工具条 ⌫、快捷键键帽 ⌘/⌫/↑↓（键盘语义字符）。
- **GenderIcon ♂♀**：既有定稿自绘（冷蓝/暖粉双色），不套线性单色。
- **桌面小组件分区图标**：Widget.tsx 内自带手绘线性 `ICO` 集（bolt/horn/clock，coolicons 无闪电字形），风格已一致，保留。
