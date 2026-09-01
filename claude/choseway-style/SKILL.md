---
name: choseway-style
description: 千往（ChoseWay）红黑赛博科技风 UI 设计系统（跨平台）。当用户提到「choseway 风格 / 千往风格 / 红黑风 / 赛博科技风 / 与 ChoseWayManager、报价单工具、AssetsViewer 统一视觉」，或要求 Web 页面、Tauri/Electron 客户端、WPF/WinUI 窗口、Unity 编辑器窗口（UI Toolkit / IMGUI）、设计稿、原型套用本套设计语言时使用。提供平台无关 tokens.json、完整规范、跨平台适配指南与降级矩阵，以及可直接引入的 theme.css / USS / C# IMGUI 助手 / XAML 资源字典。
---

# ChoseWay 红黑赛博科技风（千往风格）

> 源头：`W:\Project\AI\AI_ChoseWayManager\web\src\styles.css`（ChoseWay Manager 内网总平台），与报价单工具、ChoseWayAssetsViewer 共用同一视觉语言。本技能是该设计系统的固化版，**新项目按本技能落地即视为「千往风格」**。

## 何时使用

- 用户说：套用 choseway / 千往 / 红黑 / 赛博科技 风格；「和 ChoseWayManager 一样的样子」；「公司统一 UI」。
- 新建 Web 页面、桌面小组件、Claude Design 设计稿、HTML 原型、Artifact 预览，需要与千往系列产品视觉一致。
- 评审别人的页面是否符合千往风格。
- **非 Web 载体**：WPF / WinUI / Avalonia 桌面窗口、Unity 编辑器扩展窗口或运行时 UI、Qt、Flutter、终端 TUI、Figma / Claude Design 设计稿——规则层不变，实现层按 [PLATFORMS.md](PLATFORMS.md) 的降级矩阵落地。

## 快速落地（三步）

> 先判断载体：Web / Tauri / Electron → 用 theme.css；其他平台 → 先读 PLATFORMS.md，取对应子目录的现成文件（`wpf/`、`unity/`），取值一律以 tokens.json 为准。

1. **引入主题样式**：把本目录 [theme.css](theme.css) 复制进项目（或作为全局 CSS 的开头部分）。它包含全部 CSS 变量、body 背景三层配方、滚动条、以及 `.btn / .input / .select / .tag / .chip / .seg / .panel / .modal / .toast / .tbl / .dd-menu / .ctx-menu / .empty / .status-dot / .avatar-fallback` 等基础控件，类名与源项目保持一致。
2. **按规范组装页面**：布局、组件、动效、状态色、层级、响应式的完整规则见 [DESIGN.md](DESIGN.md)。写任何新样式前先查那里有没有既有约定。
3. **自检**：对照 DESIGN.md 末尾「落地清单」逐条核对，尤其是禁止项。

## 核心规则速查（记不住别的，记住这十条）

1. **纯暗色**，`color-scheme: dark`，不做亮色主题；底色 `#070707`，页面背景 = 竖向深灰渐变 + 左上角红色径向光晕 + 右上角微弱白晕 + 全屏 34px 细网格纹理向下渐隐。
2. **红只做一件事：强调**。品牌红 `#d4121f`、亮红 `#ff3748`；主按钮 / 头像兜底 / Logo 方块用 `linear-gradient(135deg, #d4121f, #ff3748)` 并带红色投影；红也承担「危险 / 逾期 / 急且重 / 今天线」语义。大面积色块一律黑灰，**红的占比要小**。
3. **文字暖白**：正文 `#f4efe9`、次要 `#b9aea4`、更弱 `rgba(255,255,255,.42)`；红色系文字用 `#ffb3ba`（不用纯红写正文）。
4. **玻璃拟态面板**：`linear-gradient(180deg, rgba(255,255,255,.04), rgba(255,255,255,.018))` + `1px solid rgba(255,255,255,.09)` 边框 + `backdrop-filter: blur(12px)`；弹出层（菜单 / 弹窗 / toast）在上面再垫一层 `rgba(14~18,14~18,14~18,.9~.97)` 实底。
5. **大圆角梯度**：28（登录卡 / 弹窗 / 侧栏）→ 22（面板 / 看板列）→ 18（行卡）→ 14（小卡 / 输入框 / 导航项）→ 12（图标块）→ 9（菜单项）；按钮 / 标签 / 筛选胶囊一律 `999px` 胶囊。
6. **字体**：`"Segoe UI", "PingFang SC", "Microsoft YaHei", system-ui, sans-serif`，基准 14px / 1.6；标题 26px 700 `-0.03em`；面板眉标 12px 700 大写 `letter-spacing .08em` 62% 白；大号数字（进度 / 计数）用 `Bahnschrift / DIN Alternate` **斜体 + 描边**（`-webkit-text-stroke`）；等宽用 Consolas。
7. **状态语义色固定**：绿 `#46c576` = 在线 / 成功；金 `#d9a13b` = 临期 / 警告 / 仅重要；橙 `#ff8c3b` = 仅紧急；亮红 = 逾期 / 离线 / 急且重；灰 = 普通（整体降暗 0.68）。状态点 8px 圆 + 同色 8px 辉光。
8. **交互反馈克制**：悬停 = 边框提亮到 16% 白 + 背景 4%→7% 白；卡片悬停上浮 `translateY(-3px)` + 深投影；过渡 0.15s（卡片 180ms）；焦点环 = 红边 + `0 0 0 3px rgba(212,18,31,.16)`。
9. **动效有开关**：脉动 / 呼吸 / 流动纹理只给「需要被看见」的元素（急且重、今天线、定位闪烁），周期经 CSS 变量 `--fx-speed / --fx-glow` 可调，且 **`prefers-reduced-motion: reduce` 下必须降级为静态**。
10. **控件全自绘**：不使用原生 `select / confirm / alert / prompt`；下拉、右键菜单、确认框、toast 全部是同一套深色玻璃浮层（`.dd-menu / .ctx-menu / .modal / .toast`），`dd-in` 0.12s 淡入下移 4px。
11. **图标用 coolicons 线性描边**（导航 / 按钮等结构性图标），内联 SVG + `currentColor`，不用 emoji / Unicode 字符；映射与落地方式见 [icons/ICONS.md](icons/ICONS.md)。

## 禁止项

- 亮色主题、纯白底、浅灰卡片。
- 蓝色作为主色或主按钮（蓝 `#7fa0dc` 只做「关联 / 链接」类小标签；`#4fa3d9` 只出现在类别哈希色里）。
- 直角或 ≤6px 小圆角的主要容器；方形按钮。
- 原生控件、浏览器默认右键菜单、`window.confirm`。
- 冷白文字（`#fff` 只用于主按钮文字、激活态导航、弹窗内高亮）。
- 大面积红色背景、红色渐变铺满页面。
- 没有 reduced-motion 降级的无限动画。

## 文件索引

- [DESIGN.md](DESIGN.md) —— 完整设计规范（色彩 / 背景 / 排版 / 形状 / 组件 / 动效 / 状态 / 层级 / 响应式 / 工程约定 / 落地清单 / 反模式）。
- [tokens.json](tokens.json) —— **平台无关设计 token**（颜色 hex+rgba / 渐变 / 圆角 / 阴影 / 模糊 / 网格 / 字体 / 尺寸 / 动效 / 语义 / z-index / 断点），所有平台移植的唯一取值源。
- [PLATFORMS.md](PLATFORMS.md) —— **跨平台适配指南**：平台无关硬规则、能力降级矩阵（模糊 / 渐变 / 圆角 / 辉光 / 纹理 / 动画 / 描边数字 / 自绘弹层 × Web / WPF / USS / IMGUI / Qt / TUI）、各平台要点、新平台移植流程。
- [theme.css](theme.css) —— Web / Tauri / Electron 可直接引入的主题样式（变量 + 基础控件），类名与源项目一致。
- [icons/ICONS.md](icons/ICONS.md) —— **统一图标体系**：coolicons（CC BY 4.0）语义映射表、现役 SVG 源文件（`icons/*.svg`）、`Ico` 组件落地方式与生成脚本 `icons/gen-icons.mjs`（同时覆盖控制台与报价平台两份 Icon.tsx）。
- [wpf/ChoseWayTheme.xaml](wpf/ChoseWayTheme.xaml) —— WPF（WinUI / Avalonia 微调可用）ResourceDictionary：全部颜色与画刷（含红渐变 / 玻璃 / 窗口背景 DrawingBrush / 34px 网格）、文字样式、Panel / Card / Popup / Modal、Button（默认 / Primary / Ghost / Danger / Small）、NavItem、TextBox（红焦点环）、Tag、状态点。
- [unity/ChoseWayTheme.uss](unity/ChoseWayTheme.uss) —— Unity UI Toolkit 样式（EditorWindow / 运行时通用）：`.cw-root` 变量 + 面板 / 卡片 / 按钮 / 输入 / 标签 / 胶囊 / 分段 / 状态点 / 象限色条 / 进度 / 表格 / 滚动条覆写。
- [unity/ChoseWayEditorTheme.cs](unity/ChoseWayEditorTheme.cs) —— Unity IMGUI 编辑器助手（放 `Editor/`）：`CW.Colors` / `CW.Styles` / `FillWindowBackground`（底色 + 红晕 + 网格）/ `BeginPanel` / `Button(kind)` / `TextField` / `Tag` / `StatusDot` / `QuadBar`（脉动）/ `Progress`，圆角用 SDF 生成的 9-slice 贴图。
- 源项目参考：`W:\Project\AI\AI_ChoseWayManager\web\src\styles.css`（2100+ 行，含看板四象限动效 `.task-card.qd-*`、进度底板 `.task-fill`、开场动画 `.gi-*`、甘特 `.pj-*`、小组件 `.wg-*` / `.pk-*`），`web/src/components/ui.tsx`（Modal / Select / ContextMenu / confirmDialog / promptDialog / toast / Avatar 的自绘实现）。需要完整复刻某个复杂组件时直接去源文件抄。
