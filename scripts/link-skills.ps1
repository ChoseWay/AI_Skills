<#
.SYNOPSIS
  把本仓库 claude/* 与 codex/* 下的技能以目录 junction 链接到 ~/.claude/skills 与 ~/.codex/skills。
.DESCRIPTION
  - 目标不存在 → 创建 junction。
  - 目标已是指向本仓库同一技能的链接 → 跳过。
  - 目标是指向别处的链接 → 重新指向本仓库（先删旧链接）。
  - 目标是普通目录（本机有未入库内容）→ 跳过并提示用 adopt-skill.ps1 收编。
  - -CrossLink：把 claude/ 下标记为通用的技能也链到 codex（或反之）。用法：-CrossLink @{ 'choseway-style' = 'codex' }（仅限在 pwsh 会话内用 & 调用；pwsh -File 传不了哈希表）
  - -ToCodex：把 claude/ 下的技能链到 codex，逗号分隔技能名，pwsh -File 也能用。用法：-ToCodex choseway-style,feishu-doc,project-guide
.EXAMPLE
  pwsh -File scripts/link-skills.ps1 -WhatIf
  pwsh -File scripts/link-skills.ps1
  pwsh -File scripts/link-skills.ps1 -ToCodex choseway-style,feishu-doc,project-guide
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$ClaudeSkillsDir = (Join-Path $env:USERPROFILE '.claude\skills'),
  [string]$CodexSkillsDir  = (Join-Path $env:USERPROFILE '.codex\skills'),
  [hashtable]$CrossLink = @{},
  [string[]]$ToCodex = @()
)
$ErrorActionPreference = 'Stop'
# -ToCodex 经 pwsh -File 传入时是一个带逗号的字符串，这里统一拆开并并入 CrossLink
$CrossLink = @{} + $CrossLink
foreach ($n in ($ToCodex -join ',').Split(',', [StringSplitOptions]::RemoveEmptyEntries)) { $CrossLink[$n.Trim()] = 'codex' }
$repo = Split-Path $PSScriptRoot -Parent

function Link-One([string]$src, [string]$dst) {
  if (-not (Test-Path (Join-Path $src 'SKILL.md'))) { Write-Warning "跳过（无 SKILL.md）：$src"; return }
  if (Test-Path $dst) {
    $item = Get-Item $dst -Force
    if ($item.LinkType) {
      $target = ($item.Target | Select-Object -First 1)
      if ($target -and ((Resolve-Path $target).Path -eq (Resolve-Path $src).Path)) { Write-Host "已链接  $dst" -ForegroundColor DarkGray; return }
      if ($PSCmdlet.ShouldProcess($dst, "重指向链接 → $src")) { $item.Delete(); New-Item -ItemType Junction -Path $dst -Target $src | Out-Null; Write-Host "重指向  $dst → $src" -ForegroundColor Yellow }
      return
    }
    Write-Warning "目标已是普通目录，未改动：$dst`n        如需纳入仓库请执行 adopt-skill.ps1 -Agent <claude|codex> -Name $(Split-Path $dst -Leaf)"
    return
  }
  if ($PSCmdlet.ShouldProcess($dst, "创建 junction → $src")) {
    New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    Write-Host "已创建  $dst → $src" -ForegroundColor Green
  }
}

foreach ($pair in @(@{ sub = 'claude'; dir = $ClaudeSkillsDir }, @{ sub = 'codex'; dir = $CodexSkillsDir })) {
  $root = Join-Path $repo $pair.sub
  if (-not (Test-Path $root)) { continue }
  Get-ChildItem $root -Directory | ForEach-Object { Link-One $_.FullName (Join-Path $pair.dir $_.Name) }
}
foreach ($name in $CrossLink.Keys) {
  $to = $CrossLink[$name]
  $src = @((Join-Path $repo "claude\$name"), (Join-Path $repo "codex\$name")) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $src) { Write-Warning "CrossLink 找不到技能：$name"; continue }
  $dst = if ($to -eq 'codex') { Join-Path $CodexSkillsDir $name } else { Join-Path $ClaudeSkillsDir $name }
  Link-One $src $dst
}
