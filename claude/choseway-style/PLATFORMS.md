# 千往风格 · 跨平台适配指南

> 设计语言分两层：**规则层**（token、圆角梯度、排版、语义色、组件行为、动效原则、用色比例）在所有平台不变；**实现层**（backdrop-blur、辉光、网格纹理、CSS 动画、渐变）按平台能力降级。本文按平台给出「取值来源 → 能降级什么 → 现成文件 → 注意事项」。所有取值以 [tokens.json](tokens.json) 为准。

## 0. 平台无关的硬规则（任何载体都要满足）

1. 底色 `#070707`，纯暗色；层次靠白色透明度阶梯（4% 面 / 7% 悬停 / 9% 描边 / 16% 强描边），不用灰色实色。
2. 红只做强调：主操作 + 语义警示 + 角落氛围；面积 ≤ 5%。主按钮 = `#D4121F→#FF3748` 135° 渐变（无渐变能力就用 `#E0232F` 单色）。
3. 文字暖白 `#F4EFE9` / 次要 `#B9AEA4`；红底文字 `#FFB3BA`。
4. 圆角梯度 28 / 22 / 18 / 14 / 12 / 9，按钮与标签胶囊（无胶囊能力用最大可用圆角）。
5. 眉标：12px 700 大写 +8% 字距 62% 白；标题 26（窗口小则 18~21）700 负字距。
6. 语义色固定：红逾期 / 金临期 / 橙仅紧急 / 绿在线 / 灰普通。
7. 悬停 = 描边 9%→16% + 底 4%→7%；过渡 150ms；焦点 = 红描边。
8. 动效只给需要被看见的元素，可调、可关、跟随系统减少动态。
9. 控件自绘、风格统一：不要出现平台默认的灰色原生按钮 / 下拉 / 对话框混在红黑界面里。

## 1. 能力降级矩阵

| 效果 | Web / Tauri / Electron | WPF / WinUI 3 / Avalonia | Unity UI Toolkit (USS) | Unity IMGUI (EditorWindow) | Qt (QSS) | 终端 TUI |
| --- | --- | --- | --- | --- | --- | --- |
| 玻璃模糊 backdrop | ✅ | ❌ → 实底 `#121212` 94%（WinUI 可用 Acrylic/Mica 但颜色要压暗） | ❌ → 实底 | ❌ → 实底 | ❌ → 实底 | ❌ |
| 线性 / 径向渐变 | ✅ | ✅ Brush | ❌ → 单色或 9-slice 贴图 | ❌ → 单色 / Texture2D | ✅ qlineargradient | ❌ |
| 大圆角 / 胶囊 | ✅ | ✅ CornerRadius | ✅ border-radius | ❌ → 圆角贴图 9-slice 或平角 | ✅ border-radius | ❌ |
| 投影 / 辉光 | ✅ box-shadow | ✅ DropShadowEffect（慎用，耗性能） | ❌ → 外圈 1px 半透明红描边替代 | ❌ → 同左 | ❌（需 QGraphicsEffect） | ❌ → 颜色变亮 |
| 34px 网格纹理 | ✅ | ✅ DrawingBrush TileMode | ⚠ 平铺贴图 | ⚠ 平铺贴图 | ⚠ 平铺图 | ❌ |
| 脉动 / 呼吸动画 | ✅ CSS | ✅ Storyboard | ⚠ transition 可做颜色脉动（2021.3+），无 box-shadow 动画 | ⚠ Repaint + Mathf.PingPong | ✅ QPropertyAnimation | ❌ |
| 描边斜体大数字 | ✅ text-stroke | ⚠ 用半透明实色替代 | ⚠ -unity-font-style italic + 半透明色 | ⚠ 同左 | ⚠ | ❌ |
| 自绘下拉 / 右键 | ✅ | ✅ 自定义模板 | ✅ | ✅ GenericMenu 不可改色 → 自绘弹层 | ✅ | n/a |

降级原则：**先保色、再保形、最后保光**。把模糊、辉光、纹理全去掉后仍然是千往风格；把颜色或圆角换掉就不是了。

## 2. Web 派生：Tauri / Electron / WebView2 桌面客户端

- 直接引入 [theme.css](theme.css)，零改动。桌面小组件（`widget/`）就是这样做的：无边框透明窗 + 22px 圆角容器 + 11% 白描边 + 同配方背景。
- 透明窗口：`html, body { background: transparent }`，把背景三层配方画在根容器上，网格纹理放到容器 `::before`。
- 系统托盘 / 通知卡片也用同一套：实底 `rgba(18,18,18,.94)`、14px 圆角、红渐变头像兜底。

## 3. Windows 原生：WPF / WinUI 3 / Avalonia

现成文件：[wpf/ChoseWayTheme.xaml](wpf/ChoseWayTheme.xaml)（ResourceDictionary：全部画刷 + Window / Border 面板 / Button（默认 · Primary · Ghost · Danger）/ TextBox / TextBlock 眉标与标题 / CheckBox accent / 状态点样式）。

- 用法：`App.xaml` → `<ResourceDictionary.MergedDictionaries><ResourceDictionary Source="ChoseWayTheme.xaml"/>`；Window 设 `Background="{StaticResource CW.Brush.Bg}"`，面板用 `Style="{StaticResource CW.Panel}"`。
- 字体 `Segoe UI, Microsoft YaHei UI`；WPF / WinUI 的设备无关单位 = 1/96 英寸 = CSS px，**字号与尺寸直接用 token 的 px 值**（不要换算成 pt）。
- 圆角：`CornerRadius="28/22/18/14"`，胶囊按钮 `CornerRadius="19"`（高 38 的一半）。
- 玻璃替代：窗体底 `#070707` + 面板 `#0E0E0E`~`#141414` 实底 + 9% 白描边；想要真模糊用 WinUI `DesktopAcrylicBackdrop` 并把 TintColor 设 `#0E0E0E` / TintOpacity 0.9，否则会发灰。
- 红渐变主按钮用 `LinearGradientBrush StartPoint 0,0 EndPoint 1,1`；投影用 `DropShadowEffect Color=#D4121F Opacity .28 BlurRadius 28 ShadowDepth 8`，只给主按钮，不要给每个卡片。
- 悬停 / 按下：Trigger 改 Border 的 Background / BorderBrush，`Duration 0:0:0.15`。
- 焦点：`BorderBrush = CW.Brush.RedBorder` + 外圈 3px `#29D4121F` 描边（用双层 Border）。
- 下拉 / 菜单 / 消息框：全部自定义模板，背景 `#F5101010`、14px 圆角、6px 内边距、项 9px 圆角；不要用默认 `MessageBox`。
- Avalonia 语法几乎相同（`CornerRadius`、`BoxShadow="0 14 28 0 #48D4121F"` 原生支持）。

## 4. Unity 编辑器：UI Toolkit（EditorWindow / 运行时 UI 通用）

现成文件：[unity/ChoseWayTheme.uss](unity/ChoseWayTheme.uss)（变量 + `.cw-root / .cw-panel / .cw-btn(.primary/.ghost/.danger) / .cw-input / .cw-tag / .cw-chip / .cw-eyebrow / .cw-title / .cw-dot / .cw-quad-*` 等）。

- 用法：`rootVisualElement.styleSheets.Add(AssetDatabase.LoadAssetAtPath<StyleSheet>("…/ChoseWayTheme.uss")); rootVisualElement.AddToClassList("cw-root");`
- USS 支持：`border-radius`、`border-color/width`、`background-color`、`color`、`-unity-font-style`、`letter-spacing`（2021.2+）、`transition`（2021.3+）、`opacity`。**不支持**：渐变、box-shadow、backdrop-filter、text-stroke、`::before`。
  - 玻璃 → `background-color: rgba(255,255,255,.04)` 叠在 `#070707` 根上（视觉上与渐变面板几乎一致）。
  - 主按钮渐变 → 单色 `#E0232F`，hover `#FF3748`；想要渐变给 `background-image` 一张 2×2 渐变贴图 + `-unity-background-scale-mode: stretch-to-fill`。
  - 辉光 → 外层 1px `rgba(255,82,95,.45)` 描边；急且重呼吸 → `transition: border-color .9s` 配合脚本定时切换 class（或 `schedule.Execute().Every()`）。
  - 网格纹理 → 可省略；要的话 `background-image` 平铺一张 34×34 的 1px 线贴图（`-unity-background-image-tint-color` 调透明度）。
  - 大圆角在 USS 里是真圆角，胶囊用 `border-radius: 999px` 同样有效。
- 字体：编辑器默认 Inter / 系统字体即可；中文回退由 Unity 处理。字号按 token 缩 1~2px（编辑器窗口更紧凑：正文 12、眉标 11、标题 18）。
- 编辑器里要覆盖 Unity 默认控件样式（`Button`、`TextField`）时给它们加 `cw-btn` / `cw-input` 类并在 USS 里对 `.cw-input > #unity-text-input` 设置底色与描边，否则会露出默认灰。

## 5. Unity 编辑器：IMGUI（`OnGUI` / `EditorWindow` / `Inspector`）

现成文件：[unity/ChoseWayEditorTheme.cs](unity/ChoseWayEditorTheme.cs)（放入任意 `Editor/` 目录；提供 `CW.Colors` 常量、`CW.Styles`（Panel / Button / PrimaryButton / GhostButton / DangerButton / Input / Eyebrow / Title / Tag / TagRed / TagWarn / TagOk / Muted / Faint）、`CW.Begin/EndPanel()`、`CW.StatusDot()`、`CW.QuadBar()`、`CW.Pulse()` 辅助）。

- IMGUI 没有圆角、渐变、模糊：用 `Texture2D` 单色底 + 1px 描边纹理（助手里已生成并缓存），圆角通过 9-slice 的小圆角贴图实现（助手含 14px 圆角贴图生成器，用 `RoundRectTex(radius, fill, border)`）。
- 整个窗口先 `EditorGUI.DrawRect(position, CW.Colors.Bg)` 铺底，再在左上角 `DrawRect` 一块低透明红（`new Color(0.83,0.07,0.12,0.10)`）当氛围晕，网格可用 `Handles.DrawLine` 每 34px 画一条 2.5% 白线（仅在 `Event.current.type == Repaint` 时）。
- 动效：`EditorApplication.update` 里 `Repaint()`，用 `Mathf.PingPong(EditorApplication.timeSinceStartup / fxSpeed, 1)` 驱动色条透明度；提供开关并默认读 `EditorPrefs`。
- 不要用 `EditorStyles.toolbarButton` 之类默认灰样式混排；所有按钮走 `CW.Styles.*`。
- 颜色运算：`GUI.backgroundColor` 会与贴图相乘，助手里的贴图都是白底，按 Colors 着色。

## 6. Unity 运行时 UI（UGUI）

- 用 UI Toolkit 的 USS 最省事；若必须 UGUI：Image 用 9-slice 圆角 sprite（白色，`Image.color` 着色为 token），材质无需；主按钮 sprite 做成红渐变 9-slice；字体 TMP，`Segoe UI`/思源黑体；辉光用 TMP Underlay 或 Outline，脉动用 `Color.Lerp` 协程。

## 7. Qt / QSS、Flutter、其它

- **Qt QSS**：语法与 CSS 高度一致，可从 theme.css 直接迁移 `background / border / border-radius / color / font`，渐变用 `qlineargradient(x1:0,y1:0,x2:1,y2:1, stop:0 #D4121F, stop:1 #FF3748)`；无 box-shadow / backdrop。
- **Flutter**：`ThemeData.dark()` 基础上：`scaffoldBackgroundColor 0xFF070707`、`cardColor` 用白 4% 叠色（`Color(0x0AFFFFFF)`）、`primaryColor 0xFFD4121F`、`colorScheme.error 0xFFFF3748`；`BoxDecoration` 支持渐变 / 投影 / 圆角，`BackdropFilter` 做玻璃。
- **终端 TUI**（只在必须时）：256 色近似 —— 底 `#080808`(232) / 文字 `#EEEEEE`(255) / 次要 `#A8A8A8`(248) / 红 `#D70000`(160) / 亮红 `#FF005F`(197) / 金 `#D7AF5F`(179) / 绿 `#5FD787`(78)；圆角用 `╭╮╰╯` 边框。

## 8. 设计稿 / 原型（Claude Design、Figma、HTML 原型）

- Claude Design 画布与 HTML 原型直接内联 theme.css；Figma 变量按 tokens.json 建「CW/…」集合。
- 出设计稿时仍要遵守用色比例：红占比小、大面积黑灰、暖白文字；截图对照 DESIGN.md 第 13 节清单自检。

## 9. 新平台移植流程

1. 读 tokens.json，先落颜色 + 圆角 + 字号三组。
2. 做 6 个基础件：根背景、面板、默认按钮、主按钮、输入框、标签；对照 theme.css 里的同名类逐项核对数值。
3. 按第 1 节矩阵决定哪些效果降级，记录到该项目的 ProjectGuide「设计原则」。
4. 截图与 ChoseWayManager 同屏对比：底色是否一样黑、红是否只有一抹、文字是否偏暖、圆角是否够大。
5. 新平台的移植文件回收进本技能对应子目录（`wpf/`、`unity/`、…），并在 SKILL.md 文件索引登记。
