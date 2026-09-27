<#
.SYNOPSIS
  Installs the knowledge-base skill into a target repository.

.DESCRIPTION
  Copies skill/knowledge-base to <Target>/.claude/skills/knowledge-base. Claude Code, GitHub Copilot
  (VS Code agent mode, CLI and cloud agent) and Kimi CLI all read skills from that folder.

  Also copies the Copilot prompt file to <Target>/.github/prompts/knowledge-base.prompt.md, which
  adds /knowledge-base to Copilot Chat in VS Code.

  With -User, installs once for the current user instead of into a repository: the skill goes to
  $HOME/.claude/skills/knowledge-base (%USERPROFILE%\.claude\skills on Windows) and the Copilot
  prompt file is skipped, because it only works inside a repository.

.EXAMPLE
  ./scripts/install.ps1 -Target "C:\Projects\my-service"
  ./scripts/install.ps1 -Target ../my-service -Agents -Force
  ./scripts/install.ps1 -User
#>
param(
  [string]$Target,
  [switch]$User,        # install into the user's home folder instead of a repository
  [switch]$Agents,      # also copy to .agents/skills (generic Agent Skills folder)
  [switch]$NoCopilot,   # skip the .github/prompts wrapper
  [switch]$Force        # replace an existing installation
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$skillSrc = Join-Path $repoRoot 'skill/knowledge-base'
$promptSrc = Join-Path $repoRoot 'adapters/copilot/knowledge-base.prompt.md'

if ($User) {
  if ($Target) { throw "Use either -Target or -User, not both." }
  $Target = $HOME
  $NoCopilot = $true
} elseif (-not $Target) {
  throw "Specify -Target <repo folder>, or -User to install for your user account."
}
if (-not (Test-Path $Target -PathType Container)) { throw "Target folder not found: $Target" }
$Target = (Resolve-Path $Target).Path

function Copy-Skill([string]$destRoot) {
  $dest = Join-Path $destRoot 'knowledge-base'
  if (Test-Path $dest) {
    if (-not $Force) { throw "$dest already exists. Re-run with -Force to replace it." }
    Remove-Item -Recurse -Force $dest
  }
  New-Item -ItemType Directory -Force $destRoot | Out-Null
  Copy-Item -Recurse $skillSrc $dest
  Write-Host "Installed skill  -> $dest"
}

Copy-Skill (Join-Path $Target '.claude/skills')
if ($Agents) { Copy-Skill (Join-Path $Target '.agents/skills') }

if (-not $NoCopilot) {
  $promptDir = Join-Path $Target '.github/prompts'
  $promptDest = Join-Path $promptDir 'knowledge-base.prompt.md'
  if ((Test-Path $promptDest) -and -not $Force) { throw "$promptDest already exists. Re-run with -Force to replace it." }
  New-Item -ItemType Directory -Force $promptDir | Out-Null
  Copy-Item $promptSrc $promptDest -Force
  Write-Host "Installed prompt -> $promptDest"
}

$legacyCommand = Join-Path $Target '.claude/commands/knowledge-base.md'
if (Test-Path $legacyCommand) {
  Write-Warning "$legacyCommand also defines /knowledge-base in Claude Code. Remove it so the skill is used."
}

Write-Host ""
Write-Host "Done. Invoke with: Claude Code /knowledge-base | Copilot Chat (Agent mode) /knowledge-base | Kimi CLI /skill:knowledge-base"
