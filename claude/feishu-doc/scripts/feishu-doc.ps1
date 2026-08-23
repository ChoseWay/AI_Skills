# 读取飞书云文档（电子表格 / 新版文档 / 知识库节点）
# 用法见同目录 SKILL.md。凭证与 token 不回显。
param(
    [Parameter(Mandatory = $true)][string]$Url,   # 飞书链接（sheets/docx/wiki）或裸 token（视为表格）
    [string]$Sheet = "",                          # 页签名或 sheetId；空 = 仅列出页签清单
    [string]$Range = "",                          # 如 A1:H50；空 = 按页签行列数整页读取
    [string]$CredPath = "W:\Project\AI\_Config\feishu.json",
    [ValidateSet("text", "json")][string]$Format = "text"
)

$ErrorActionPreference = "Stop"
$Base = "https://open.feishu.cn/open-apis"

# ---------- token ----------
$cred = Get-Content $CredPath -Raw | ConvertFrom-Json
$body = @{ app_id = $cred.app_id; app_secret = $cred.app_secret } | ConvertTo-Json
$tok = (Invoke-RestMethod -Method Post -Uri "$Base/auth/v3/tenant_access_token/internal" -ContentType "application/json; charset=utf-8" -Body $body).tenant_access_token
if (-not $tok) { Write-Error "获取 tenant_access_token 失败（检查凭证文件 $CredPath）"; exit 1 }
$H = @{ Authorization = "Bearer $tok" }

function Invoke-Api([string]$Uri) {
    try { return Invoke-RestMethod -Uri $Uri -Headers $H }
    catch {
        $msg = $_.Exception.Message
        if ($msg -match "403|Forbidden") { Write-Error "403 权限不足：请在该文档「分享→邀请协作者」中添加应用「Claude文档读取」为可阅读。" }
        else { Write-Error "API 调用失败：$msg（$Uri）" }
        exit 1
    }
}

# ---------- 解析链接类型 ----------
$kind = "sheets"; $token = $Url; $sheetFromUrl = ""
if ($Url -match "feishu\.cn/(sheets|docx|wiki|docs)/([A-Za-z0-9]+)") {
    $kind = $Matches[1]; $token = $Matches[2]
    if ($Url -match "[?&]sheet=([A-Za-z0-9]+)") { $sheetFromUrl = $Matches[1] }
}
if ($kind -eq "wiki") {
    # 知识库节点 → 解析真实对象类型与 token
    $node = Invoke-Api "$Base/wiki/v2/spaces/get_node?token=$token"
    $kind = $node.data.node.obj_type; $token = $node.data.node.obj_token
    if ($kind -eq "sheet") { $kind = "sheets" }
}

# ---------- docx：输出纯文本 ----------
if ($kind -in @("docx", "docs", "doc")) {
    $doc = Invoke-Api "$Base/docx/v1/documents/$token/raw_content"
    Write-Output $doc.data.content
    exit 0
}

# ---------- sheets ----------
$meta = Invoke-Api "$Base/sheets/v3/spreadsheets/$token/sheets/query"
$sheets = $meta.data.sheets

if (-not $Sheet -and $sheetFromUrl) { $Sheet = $sheetFromUrl }
if (-not $Sheet) {
    Write-Output "页签清单（用 -Sheet 指定页签名或 sheetId 读取内容）："
    $sheets | ForEach-Object { "  {0}  id={1}  行={2} 列={3}" -f $_.title, $_.sheet_id, $_.grid_properties.row_count, $_.grid_properties.column_count }
    exit 0
}

$target = $sheets | Where-Object { $_.sheet_id -eq $Sheet -or $_.title -eq $Sheet } | Select-Object -First 1
if (-not $target) { Write-Error "未找到页签「$Sheet」。可用页签：$(($sheets | ForEach-Object { $_.title }) -join '、')"; exit 1 }

# 列号 → 字母（支持 AA+）
function ColLetter([int]$n) { $s = ""; while ($n -gt 0) { $n--; $s = [char](65 + $n % 26) + $s; $n = [int][math]::Floor($n / 26) }; return $s }

if (-not $Range) {
    $Range = "A1:$(ColLetter $target.grid_properties.column_count)$($target.grid_properties.row_count)"
}

# 大范围按 500 行分段拉取，规避单次单元格上限
$rows = @()
if ($Range -match "^([A-Z]+)(\d+):([A-Z]+)(\d+)$") {
    $c1 = $Matches[1]; $r1 = [int]$Matches[2]; $c2 = $Matches[3]; $r2 = [int]$Matches[4]
    for ($r = $r1; $r -le $r2; $r += 500) {
        $rEnd = [math]::Min($r + 499, $r2)
        $seg = Invoke-Api "$Base/sheets/v2/spreadsheets/$token/values/$($target.sheet_id)!$c1$r`:$c2$rEnd`?valueRenderOption=ToString"
        if ($seg.data.valueRange.values) { $rows += $seg.data.valueRange.values }
    }
}
else {
    $seg = Invoke-Api "$Base/sheets/v2/spreadsheets/$token/values/$($target.sheet_id)!$Range`?valueRenderOption=ToString"
    $rows = $seg.data.valueRange.values
}

if ($Format -eq "json") {
    $rows | ConvertTo-Json -Depth 5 -Compress
}
else {
    $i = 0
    foreach ($row in $rows) {
        $i++
        $line = ($row | ForEach-Object { if ($null -eq $_) { "" } else { ("$_" -replace "`r?`n", "⏎") } }) -join " | "
        if ($line.Trim(" |").Length -gt 0) { "{0,4}: {1}" -f $i, $line }
    }
}
