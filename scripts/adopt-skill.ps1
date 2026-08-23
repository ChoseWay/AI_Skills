<#
.SYNOPSIS
  把已存在于 ~/.claude/skills/<Name> 或 ~/.codex/skills/<Name> 的技能「收编」进本仓库（claude/ 或 codex/），原位换成 junction。
.EXAMPLE
  pwsh -File scripts/adopt-skill.ps1 -Agent claude -Name my-skill
  pwsh -File scripts/adopt-skill.ps1 -Agent codex  -Name hatch-pet -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory)][ValidateSet('claude', 'codex')][string]$Agent,
  [Parameter(Mandatory)][string]$Name
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$agentDir = if ($Agent -eq 'claude') { Join-Path $env:USERPROFILE '.claude\skills' } else { Join-Path $env:USERPROFILE '.codex\skills' }
$src = Join-Path $agentDir $Name
$dst = Join-Path $repo "$Agent\$Name"

if (-not (Test-Path $src)) { throw "不存在：$src" }
if ((Get-Item $src -Force).LinkType) { throw "$src 已经是链接，无需收编" }
if (-not (Test-Path (Join-Path $src 'SKILL.md'))) { throw "$src 下没有 SKILL.md，不是合法技能目录" }
if (Test-Path $dst) { throw "仓库里已有同名技能：$dst（先手动合并或删除）" }

# 提示可能的凭证
$hits = Get-ChildItem $src -Recurse -File | Select-String -Pattern 'app_secret|api[_-]?key|token\s*[:=]\s*["''][A-Za-z0-9]{16,}|sk-[A-Za-z0-9]{20,}|cli_[a-z0-9]{10,}' -ErrorAction SilentlyContinue
if ($hits) { Write-Warning "疑似凭证，入库前请人工确认：`n$($hits | ForEach-Object { "  $($_.Path):$($_.LineNumber)" } | Out-String)" }

if ($PSCmdlet.ShouldProcess($src, "搬入 $dst 并换成 junction")) {
  New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
  # 先复制再删，避免跨卷 Move 失败；排除 __pycache__
  robocopy $src $dst /E /XD __pycache__ /NFL /NDL /NJH /NJS | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "robocopy 失败，退出码 $LASTEXITCODE" }
  Remove-Item $src -Recurse -Force
  New-Item -ItemType Junction -Path $src -Target $dst | Out-Null
  Write-Host "已收编：$dst`n已链接：$src → $dst" -ForegroundColor Green
  # SKILL.md 去 BOM（Claude Code 解析 frontmatter 需要）
  $skill = Join-Path $dst 'SKILL.md'
  $bytes = [IO.File]::ReadAllBytes($skill)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    [IO.File]::WriteAllText($skill, [IO.File]::ReadAllText($skill, [Text.Encoding]::UTF8), (New-Object Text.UTF8Encoding($false)))
    Write-Host "已去除 SKILL.md 的 UTF-8 BOM" -ForegroundColor Yellow
  }
  Write-Host "别忘了在 CATALOG.md 登记并 git commit。"
}
