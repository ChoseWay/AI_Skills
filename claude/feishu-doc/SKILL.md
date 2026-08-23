---
name: feishu-doc
description: 通过飞书开放平台 API 读取飞书云文档（电子表格 sheets / 新版文档 docx / 知识库 wiki）。当用户发来 *.feishu.cn 链接、要求读取/同步飞书云文档或表格数据时使用。凭证已配置在本机，读取为只读、结构化、全量，优于浏览器截图。
---

# 读取飞书云文档（自建应用 API）

## 凭证与前提

- 凭证文件：`W:\Project\AI\_Config\feishu.json`，格式 `{ "app_id": "...", "app_secret": "..." }`
- **凭证与 token 严禁回显到对话输出**（脚本已内部处理，只输出数据）。
- 应用只能读**已将其添加为协作者**的文档。收到 403/1310213 等权限错误时，提示用户：打开该文档 → 分享 → 邀请协作者 → 搜索应用「Claude文档读取」→ 添加为可阅读。

## 快速用法（首选）

用本技能自带脚本 `scripts/feishu-doc.ps1`（PowerShell 7）：

```powershell
# 列出表格全部页签（标题、sheetId、行列数）
pwsh -File "C:\Users\STQ\.claude\skills\feishu-doc\scripts\feishu-doc.ps1" -Url "<飞书链接>"

# 读取指定页签（页签名或 sheetId 均可；不给 -Range 则整页全量）
pwsh -File "C:\Users\STQ\.claude\skills\feishu-doc\scripts\feishu-doc.ps1" -Url "<飞书链接>" -Sheet "流程表（详）_0806"

# 读取指定范围 / 输出 JSON（供程序化处理）
pwsh -File "C:\Users\STQ\.claude\skills\feishu-doc\scripts\feishu-doc.ps1" -Url "<飞书链接>" -Sheet Um7MxV -Range A1:H50 -Format json
```

- 支持三类链接：`/sheets/{token}`（电子表格）、`/docx/{token}`（新版文档，输出纯文本）、`/wiki/{token}`（知识库节点，自动解析后按实际类型读取）。
- text 格式每行以 ` | ` 分隔单元格，适合直接阅读；json 格式为行数组，适合转换处理。

## 直接调 API（脚本不适用时）

1. 换 token：`POST https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal`，body `{app_id, app_secret}` → `tenant_access_token`（有效 2 小时，每次现取即可）；
2. 后续请求头 `Authorization: Bearer {token}`；
3. 常用端点：
   - 表格页签列表：`GET /open-apis/sheets/v3/spreadsheets/{token}/sheets/query`
   - 单元格读取：`GET /open-apis/sheets/v2/spreadsheets/{token}/values/{sheetId}!{A1:H50}?valueRenderOption=ToString`（单次上限约 10 万单元格，大表按行分段）
   - 新版文档纯文本：`GET /open-apis/docx/v1/documents/{token}/raw_content`
   - wiki 节点解析：`GET /open-apis/wiki/v2/spaces/get_node?token={token}` → `obj_type`/`obj_token` 再按类型读取

## 注意事项

- 表格链接 query 里的 `sheet=xxx` 即目标页签的 sheetId，优先用它。
- 空行/空列会原样返回 null，阅读时注意点位分块表格常用合并单元格——合并区只有左上角格有值。
- 若需要给新的飞书应用权限（如写入、评论），到 open.feishu.cn 开发者后台该应用「权限管理」添加并重新发布版本。
