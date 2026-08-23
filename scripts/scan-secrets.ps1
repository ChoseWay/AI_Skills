<#
.SYNOPSIS
  提交前扫一遍仓库（工作区 + 可选全部 git 历史）里是否混入凭证 / 密钥 / 个人敏感信息。
  命中不代表一定是泄漏（例如文档里写「app_secret 字段」），但每条都要人工看一眼。
.EXAMPLE
  pwsh -File scripts/scan-secrets.ps1            # 扫工作区
  pwsh -File scripts/scan-secrets.ps1 -History   # 连同全部提交历史（含已删除内容）
#>
[CmdletBinding()]
param([switch]$History)
$repo = Split-Path $PSScriptRoot -Parent
# 只匹配「像真值」的模式，避免把文档里的字段名当命中
$patterns = @(
  'app_secret\s*[:=]\s*["'']?[A-Za-z0-9]{12,}',          # 飞书 app_secret 真值
  'app_id\s*[:=]\s*["'']?cli_[a-z0-9]{8,}',              # 飞书 app_id 真值
  '(password|passwd|pwd)\s*[:=]\s*["'']?[^\s"''<>{}]{4,}', # 密码赋值
  '(api[_-]?key|access[_-]?token|secret[_-]?key)\s*[:=]\s*["'']?[A-Za-z0-9_\-]{16,}',
  'sk-[A-Za-z0-9]{20,}', 'ghp_[A-Za-z0-9]{30,}', 'github_pat_[A-Za-z0-9_]{40,}', 'xox[bpa]-[A-Za-z0-9\-]{20,}', 'AKIA[0-9A-Z]{16}',
  'BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY',
  'eyJ[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{10,}',   # JWT
  '[A-Za-z0-9._%+-]+@(qq|gmail|163|126|outlook|hotmail)\.com'           # 个人邮箱（提交作者除外）
)
$rx = ($patterns -join '|')
$hits = @()
Get-ChildItem $repo -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' } | ForEach-Object {
  $f = $_.FullName
  Select-String -Path $f -Pattern $rx -AllMatches -ErrorAction SilentlyContinue | ForEach-Object { $hits += "[工作区] $($f.Substring($repo.Length+1)):$($_.LineNumber)  $($_.Line.Trim())" }
}
if ($History) {
  Push-Location $repo
  $diff = git log -p --all --no-color 2>$null
  for ($i = 0; $i -lt $diff.Count; $i++) { if ($diff[$i] -match $rx -and $diff[$i] -notmatch '^Author:') { $hits += "[历史] 第 $i 行：$($diff[$i].Trim())" } }
  Pop-Location
}
if ($hits) { Write-Host "疑似命中 $($hits.Count) 条，请逐条人工确认：" -ForegroundColor Yellow; $hits | ForEach-Object { Write-Host "  $_" }; exit 2 }
Write-Host "未发现疑似凭证 / 密钥 / 个人邮箱。" -ForegroundColor Green
