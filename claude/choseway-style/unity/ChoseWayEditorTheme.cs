// ============================================================
// ChoseWay（千往）红黑赛博科技风 —— Unity IMGUI 编辑器主题助手
// 放入任意 Editor/ 目录。取值来源：tokens.json；降级规则见 PLATFORMS.md 第 5 节。
// 用法（EditorWindow.OnGUI）：
//   CW.FillWindowBackground(position);            // 底色 + 左上红晕 + 34px 网格
//   CW.BeginPanel("团队状态");                     // 面板（圆角 9-slice 贴图 + 眉标）
//   if (CW.Button("刷新")) ...; if (CW.Button("发布", CW.Kind.Primary)) ...;
//   name = CW.TextField("名称", name);
//   CW.Tag("逾期", CW.Kind.Danger);  CW.StatusDot(true);
//   CW.EndPanel();
//   if (CW.Animating) Repaint();                    // 急且重脉动等动效需要持续重绘
// ============================================================
#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public static class CW
{
    // ———— 颜色（与 tokens.json 一致） ————
    public static class Colors
    {
        public static readonly Color Bg          = Hex("#070707");
        public static readonly Color PanelSolid  = new Color(18 / 255f, 18 / 255f, 18 / 255f, 0.94f);
        public static readonly Color PanelSoft   = new Color(1, 1, 1, 0.035f);
        public static readonly Color Card        = new Color(1, 1, 1, 0.04f);
        public static readonly Color CardHover   = new Color(1, 1, 1, 0.07f);
        public static readonly Color Line        = new Color(1, 1, 1, 0.09f);
        public static readonly Color LineSoft    = new Color(1, 1, 1, 0.07f);
        public static readonly Color LineStrong  = new Color(1, 1, 1, 0.16f);
        public static readonly Color InputBg     = new Color(0, 0, 0, 0.20f);
        public static readonly Color Text        = Hex("#F4EFE9");
        public static readonly Color Muted       = Hex("#B9AEA4");
        public static readonly Color Faint       = new Color(1, 1, 1, 0.42f);
        public static readonly Color Eyebrow     = new Color(1, 1, 1, 0.62f);
        public static readonly Color Red         = Hex("#D4121F");
        public static readonly Color RedBright   = Hex("#FF3748");
        public static readonly Color RedMid      = Hex("#E0232F");   // 主按钮单色（无渐变）
        public static readonly Color RedFill     = new Color(212 / 255f, 18 / 255f, 31 / 255f, 0.16f);
        public static readonly Color RedBorder   = new Color(1f, 82 / 255f, 95 / 255f, 0.40f);
        public static readonly Color RedText     = Hex("#FFB3BA");
        public static readonly Color RedTint     = new Color(212 / 255f, 18 / 255f, 31 / 255f, 0.10f); // 左上氛围晕
        public static readonly Color Gold        = Hex("#E8B54A");
        public static readonly Color GoldText    = Hex("#FFD98A");
        public static readonly Color Warn        = Hex("#D9A13B");
        public static readonly Color Orange      = Hex("#FF8C3B");
        public static readonly Color Ok          = Hex("#46C576");
        public static readonly Color Link        = Hex("#7FA0DC");
        public static readonly Color NeutralBar  = new Color(1, 1, 1, 0.22f);

        public static Color Hex(string hex) { ColorUtility.TryParseHtmlString(hex, out var c); return c; }
        public static Color A(Color c, float a) { c.a = a; return c; }
    }

    public enum Kind { Default, Primary, Ghost, Danger, Warn, Ok, Gold }

    // ———— 动效参数（对应 --fx-speed / --fx-glow；EditorPrefs 持久化） ————
    public static float FxSpeed { get => EditorPrefs.GetFloat("CW.FxSpeed", 1.8f); set => EditorPrefs.SetFloat("CW.FxSpeed", value); }
    public static bool FxEnabled { get => EditorPrefs.GetBool("CW.FxEnabled", true); set => EditorPrefs.SetBool("CW.FxEnabled", value); }
    /// <summary>本帧是否有动效在跑（调用方据此 Repaint）。</summary>
    public static bool Animating { get; private set; }
    /// <summary>0~1 往返脉动值，周期 = FxSpeed。</summary>
    public static float Pulse() { Animating = FxEnabled; return FxEnabled ? Mathf.PingPong((float)(EditorApplication.timeSinceStartup / (FxSpeed * 0.5f)), 1f) : 1f; }

    // ———— 贴图：单色 / 圆角 9-slice（白底，GUI 着色） ————
    static readonly Dictionary<string, Texture2D> _tex = new Dictionary<string, Texture2D>();
    public static Texture2D Solid(Color c)
    {
        var key = "s" + ColorUtility.ToHtmlStringRGBA(c);
        if (_tex.TryGetValue(key, out var t) && t) return t;
        t = new Texture2D(1, 1, TextureFormat.RGBA32, false) { hideFlags = HideFlags.HideAndDontSave };
        t.SetPixel(0, 0, c); t.Apply();
        return _tex[key] = t;
    }
    /// <summary>圆角矩形贴图（SDF 抗锯齿，fill + 1px border），用 GUIStyle.border = radius 做 9-slice。</summary>
    public static Texture2D RoundRect(int radius, Color fill, Color border, int borderW = 1)
    {
        var key = $"r{radius}_{ColorUtility.ToHtmlStringRGBA(fill)}_{ColorUtility.ToHtmlStringRGBA(border)}_{borderW}";
        if (_tex.TryGetValue(key, out var t) && t) return t;
        int size = radius * 2 + 3;                       // 中间留 3px 可拉伸区
        t = new Texture2D(size, size, TextureFormat.RGBA32, false) { hideFlags = HideFlags.HideAndDontSave, filterMode = FilterMode.Bilinear, wrapMode = TextureWrapMode.Clamp };
        float half = size / 2f;
        for (int y = 0; y < size; y++)
            for (int x = 0; x < size; x++)
            {
                // 到圆角矩形边缘的有符号距离（外 > 0）
                float px = Mathf.Abs(x + 0.5f - half) - (half - radius), py = Mathf.Abs(y + 0.5f - half) - (half - radius);
                float d = new Vector2(Mathf.Max(px, 0), Mathf.Max(py, 0)).magnitude + Mathf.Min(Mathf.Max(px, py), 0) - radius;
                float outside = Mathf.Clamp01(0.5f - d);                 // 1 = 在形状内
                float inner = Mathf.Clamp01(0.5f - (d + borderW));       // 1 = 在描边内侧
                Color c = Color.Lerp(border, fill, inner);
                c.a *= outside; if (inner < 1) c.a = Mathf.Max(c.a, border.a * outside * (1 - inner));
                t.SetPixel(x, y, c);
            }
        t.Apply();
        return _tex[key] = t;
    }

    // ———— 样式 ————
    public static class Styles
    {
        static GUIStyle _panel, _card, _btn, _btnPrimary, _btnGhost, _btnDanger, _input, _eyebrow, _title, _sub, _muted, _faint, _tag, _bigNum;
        static Font _font;
        static Font F => _font ? _font : (_font = Font.CreateDynamicFontFromOSFont(new[] { "Segoe UI", "Microsoft YaHei UI", "PingFang SC", "Arial" }, 12));
        static GUIStyle Base(GUIStyle src) { var s = new GUIStyle(src) { font = F, richText = true }; s.normal.textColor = Colors.Text; return s; }

        public static GUIStyle Panel => _panel ?? (_panel = Box(18, Colors.A(Color.white, 0.05f), Colors.Line, new RectOffset(16, 16, 14, 14)));
        public static GUIStyle Card => _card ?? (_card = Box(14, new Color(18 / 255f, 18 / 255f, 18 / 255f, 0.9f), Colors.Line, new RectOffset(12, 12, 10, 10)));
        public static GUIStyle Button => _btn ?? (_btn = Btn(Colors.Card, Colors.A(Color.white, 0.12f), Colors.CardHover, Colors.LineStrong, Color.white));
        public static GUIStyle ButtonPrimary => _btnPrimary ?? (_btnPrimary = Btn(Colors.RedMid, Colors.A(Colors.RedBright, 0.5f), Colors.RedBright, Colors.RedBright, Color.white));
        public static GUIStyle ButtonGhost => _btnGhost ?? (_btnGhost = Btn(Color.clear, Color.clear, Colors.Card, Color.clear, Colors.Muted, Colors.Text));
        public static GUIStyle ButtonDanger => _btnDanger ?? (_btnDanger = Btn(Colors.A(Colors.Red, 0.14f), Colors.A(Colors.RedBorder, 0.55f), Colors.A(Colors.Red, 0.24f), Colors.RedBorder, Colors.RedText, Color.white));
        public static GUIStyle Input
        {
            get
            {
                if (_input != null) return _input;
                _input = Base(EditorStyles.textField);
                _input.normal.background = _input.hover.background = RoundRect(12, Colors.A(Color.black, 0.35f), Colors.A(Color.white, 0.10f));
                _input.focused.background = _input.active.background = RoundRect(12, Colors.A(Color.black, 0.35f), Colors.RedBorder);
                _input.border = new RectOffset(12, 12, 12, 12); _input.padding = new RectOffset(12, 12, 6, 6);
                _input.fixedHeight = 30; _input.fontSize = 12; _input.normal.textColor = _input.focused.textColor = Color.white;
                return _input;
            }
        }
        public static GUIStyle Eyebrow => _eyebrow ?? (_eyebrow = Text(11, FontStyle.Bold, Colors.Eyebrow));
        public static GUIStyle Title => _title ?? (_title = Text(18, FontStyle.Bold, Colors.Text));
        public static GUIStyle Sub => _sub ?? (_sub = Text(11, FontStyle.Normal, Colors.Muted));
        public static GUIStyle Muted => _muted ?? (_muted = Text(12, FontStyle.Normal, Colors.Muted));
        public static GUIStyle Faint => _faint ?? (_faint = Text(11, FontStyle.Normal, Colors.Faint));
        public static GUIStyle BigNum => _bigNum ?? (_bigNum = Text(32, FontStyle.BoldAndItalic, Colors.A(Colors.RedBright, 0.55f)));
        public static GUIStyle Tag
        {
            get
            {
                if (_tag != null) return _tag;
                _tag = Text(10, FontStyle.Bold, Colors.Muted);
                _tag.alignment = TextAnchor.MiddleCenter; _tag.fixedHeight = 22; _tag.padding = new RectOffset(9, 9, 0, 0);
                _tag.border = new RectOffset(11, 11, 11, 11);
                return _tag;
            }
        }

        static GUIStyle Text(int size, FontStyle fs, Color col) { var s = Base(EditorStyles.label); s.fontSize = size; s.fontStyle = fs; s.normal.textColor = col; s.wordWrap = false; return s; }
        static GUIStyle Box(int radius, Color fill, Color border, RectOffset pad)
        {
            var s = new GUIStyle();
            s.normal.background = RoundRect(radius, fill, border);
            s.border = new RectOffset(radius, radius, radius, radius); s.padding = pad; s.margin = new RectOffset(0, 0, 0, 10);
            return s;
        }
        static GUIStyle Btn(Color fill, Color border, Color hoverFill, Color hoverBorder, Color text, Color? hoverText = null)
        {
            var s = Base(EditorStyles.label);
            s.alignment = TextAnchor.MiddleCenter; s.fontSize = 12; s.fontStyle = FontStyle.Bold;
            s.fixedHeight = 32; s.padding = new RectOffset(16, 16, 0, 0); s.margin = new RectOffset(0, 6, 2, 2);
            s.border = new RectOffset(16, 16, 16, 16);
            s.normal.background = RoundRect(16, fill, border); s.normal.textColor = text;
            s.hover.background = RoundRect(16, hoverFill, hoverBorder); s.hover.textColor = hoverText ?? text;
            s.active.background = s.hover.background; s.active.textColor = s.hover.textColor;
            return s;
        }
    }

    // ———— 绘制助手 ————
    /// <summary>窗口底：#070707 + 左上红晕 + 34px 网格（仅 Repaint 时画）。</summary>
    public static void FillWindowBackground(Rect windowPos, bool grid = true)
    {
        var r = new Rect(0, 0, windowPos.width, windowPos.height);
        EditorGUI.DrawRect(r, Colors.Bg);
        if (Event.current.type != EventType.Repaint) return;
        // 红晕：三层递减的矩形近似径向
        EditorGUI.DrawRect(new Rect(0, 0, r.width * 0.42f, r.height * 0.34f), Colors.A(Colors.Red, 0.05f));
        EditorGUI.DrawRect(new Rect(0, 0, r.width * 0.26f, r.height * 0.22f), Colors.A(Colors.Red, 0.06f));
        EditorGUI.DrawRect(new Rect(0, 0, r.width * 0.12f, r.height * 0.10f), Colors.A(Colors.Red, 0.08f));
        if (!grid) return;
        var c = Handles.color; Handles.color = new Color(1, 1, 1, 0.025f);
        for (float x = 0; x < r.width; x += 34) Handles.DrawLine(new Vector3(x, 0), new Vector3(x, r.height * 0.92f));
        Handles.color = new Color(1, 1, 1, 0.018f);
        for (float y = 0; y < r.height * 0.92f; y += 34) Handles.DrawLine(new Vector3(0, y), new Vector3(r.width, y));
        Handles.color = c;
    }

    public static void BeginPanel(string eyebrow = null)
    {
        GUILayout.BeginVertical(Styles.Panel);
        if (!string.IsNullOrEmpty(eyebrow)) { GUILayout.Label(eyebrow.ToUpperInvariant(), Styles.Eyebrow); GUILayout.Space(6); }
    }
    public static void EndPanel() => GUILayout.EndVertical();
    public static void BeginCard() => GUILayout.BeginVertical(Styles.Card);
    public static void EndCard() => GUILayout.EndVertical();

    public static bool Button(string label, Kind kind = Kind.Default, params GUILayoutOption[] opts)
    {
        var st = kind == Kind.Primary ? Styles.ButtonPrimary : kind == Kind.Ghost ? Styles.ButtonGhost : kind == Kind.Danger ? Styles.ButtonDanger : Styles.Button;
        return GUILayout.Button(label, st, opts);
    }
    public static string TextField(string label, string value, params GUILayoutOption[] opts)
    {
        GUILayout.BeginVertical();
        if (!string.IsNullOrEmpty(label)) GUILayout.Label(label, Styles.Faint);
        var v = EditorGUILayout.TextField(value, Styles.Input, opts);
        GUILayout.EndVertical();
        return v;
    }
    public static void Title(string text) => GUILayout.Label(text, Styles.Title);
    public static void Sub(string text) => GUILayout.Label(text, Styles.Sub);

    public static void Tag(string text, Kind kind = Kind.Default)
    {
        Color fill, border, col;
        switch (kind)
        {
            case Kind.Danger: fill = Colors.RedFill; border = Colors.A(Colors.RedBorder, 0.55f); col = Colors.RedText; break;
            case Kind.Warn:   fill = Colors.A(Colors.Warn, 0.12f); border = Colors.A(Colors.Warn, 0.35f); col = Colors.Warn; break;
            case Kind.Ok:     fill = Colors.A(Colors.Ok, 0.10f); border = Colors.A(Colors.Ok, 0.30f); col = Colors.Ok; break;
            case Kind.Gold:   fill = Colors.A(Colors.Gold, 0.13f); border = Colors.A(Colors.Gold, 0.42f); col = Colors.GoldText; break;
            default:          fill = Colors.PanelSoft; border = Colors.Line; col = Colors.Muted; break;
        }
        var st = new GUIStyle(Styles.Tag); st.normal.background = RoundRect(11, fill, border); st.normal.textColor = col;
        GUILayout.Label(text, st, GUILayout.ExpandWidth(false));
    }

    /// <summary>8px 状态点：on 绿 / off 亮红 / null 灰。</summary>
    public static void StatusDot(bool? on, float size = 8)
    {
        var r = GUILayoutUtility.GetRect(size, size, GUILayout.Width(size), GUILayout.Height(size));
        r.y += 2;
        var c = on == true ? Colors.Ok : on == false ? Colors.RedBright : Colors.Faint;
        GUI.DrawTexture(r, Texture2D.whiteTexture, ScaleMode.StretchToFill, true, 0, c, 0f, size / 2);
    }

    /// <summary>卡片左缘象限色条：iu 急且重（脉动）/ i 仅重要 / u 仅紧急（脉动）/ n 普通。在 BeginCard 之后取 GUILayoutUtility.GetLastRect 或传入卡片 Rect。</summary>
    public static void QuadBar(Rect cardRect, string quad)
    {
        Color c; float a = 1f;
        switch (quad)
        {
            case "iu": c = Colors.RedBright; a = Mathf.Lerp(0.4f, 1f, Pulse()); break;
            case "i":  c = Colors.Gold; a = 0.9f; break;
            case "u":  c = Colors.Orange; a = Mathf.Lerp(0.4f, 1f, Pulse()); break;
            default:   c = Colors.NeutralBar; break;
        }
        EditorGUI.DrawRect(new Rect(cardRect.x, cardRect.y + 12, 3, cardRect.height - 24), Colors.A(c, a * c.a));
        if (quad == "iu") // 呼吸描边（无辉光能力：用描边透明度代替）
        {
            var glow = Colors.A(Colors.RedBright, Mathf.Lerp(0.15f, 0.6f, Pulse()));
            GUI.DrawTexture(cardRect, Texture2D.whiteTexture, ScaleMode.StretchToFill, true, 0, glow, 1f, 14f);   // 只画 1px 圆角描边
        }
    }

    /// <summary>细进度条（6px 胶囊）。</summary>
    public static void Progress(float p01, float height = 6)
    {
        var r = GUILayoutUtility.GetRect(10, height, GUILayout.ExpandWidth(true));
        GUI.DrawTexture(r, Texture2D.whiteTexture, ScaleMode.StretchToFill, true, 0, Colors.A(Color.white, 0.12f), 0f, height / 2);
        var f = r; f.width = Mathf.Max(height, r.width * Mathf.Clamp01(p01));
        GUI.DrawTexture(f, Texture2D.whiteTexture, ScaleMode.StretchToFill, true, 0, Colors.Red, 0f, height / 2);
    }

    public static void Divider() { var r = GUILayoutUtility.GetRect(1, 1, GUILayout.ExpandWidth(true)); r.y += 4; EditorGUI.DrawRect(r, Colors.LineSoft); GUILayout.Space(8); }
}
#endif
