<#
.SYNOPSIS
  在本机 agent 全局规则文件与仓库 global/ 快照之间同步。
  -Pull : 本机 → 仓库（~/.claude/CLAUDE.md → global/claude/CLAUDE.md；~/.codex/AGENTS.md → global/codex/AGENTS.md），随后 git 提交即可
  -Push : 仓库 → 本机（换机器 / 重装恢复；已存在且内容不同时先备份为 *.bak-yyyyMMddHHmmss）
  不带参数 = 只显示差异状态。
.EXAMPLE
  pwsh -File scripts/sync-global-rules.ps1            # 查看状态
  pwsh -File scripts/sync-global-rules.ps1 -Pull      # 本机改了规则 → 存进仓库
  pwsh -File scripts/sync-global-rules.ps1 -Push      # 新机器恢复
#>
[CmdletBinding(SupportsShouldProcess)]
param([switch]$Pull, [switch]$Push)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$pairs = @(
  @{ local = (Join-Path $env:USERPROFILE '.claude\CLAUDE.md'); repo = (Join-Path $repo 'global\claude\CLAUDE.md') },
  @{ local = (Join-Path $env:USERPROFILE '.codex\AGENTS.md');  repo = (Join-Path $repo 'global\codex\AGENTS.md') }
)
function Same($a, $b) { (Test-Path $a) -and (Test-Path $b) -and ((Get-FileHash $a).Hash -eq (Get-FileHash $b).Hash) }
function Copy-Keep($src, $dst) {
  New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
  if ((Test-Path $dst) -and -not (Same $src $dst)) { $bak = "$dst.bak-$(Get-Date -Format yyyyMMddHHmmss)"; Copy-Item $dst $bak; Write-Host "已备份旧文件 → $bak" -ForegroundColor DarkYellow }
  Copy-Item $src $dst -Force   # 字节级复制，保持原编码 / BOM
}
foreach ($p in $pairs) {
  $state = if (-not (Test-Path $p.local)) { '本机缺失' } elseif (-not (Test-Path $p.repo)) { '仓库缺失' } elseif (Same $p.local $p.repo) { '一致' } else { '不同' }
  Write-Host ("[{0}] {1}  <->  {2}" -f $state, $p.local, $p.repo)
  if ($Pull -and (Test-Path $p.local) -and $state -ne '一致' -and $PSCmdlet.ShouldProcess($p.repo, "本机 → 仓库")) { Copy-Keep $p.local $p.repo; Write-Host "  已拉入仓库" -ForegroundColor Green }
  if ($Push -and (Test-Path $p.repo)  -and $state -ne '一致' -and $PSCmdlet.ShouldProcess($p.local, "仓库 → 本机")) { Copy-Keep $p.repo $p.local; Write-Host "  已写回本机" -ForegroundColor Green }
}
if ($Pull) { Write-Host "提示：现在 git add global && git commit。" }
