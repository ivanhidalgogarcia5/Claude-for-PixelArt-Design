# Installs what Claude Code needs to make pixel art in this repo:
#   1. The pixel-art skills (globally, for Claude Code).
#   2. Optionally (-Mcp) the Aseprite MCP bridge, so Claude can draw live in an open Aseprite.
# Usage: .\install.ps1 [-Mcp]
param([switch]$Mcp)
# No $ErrorActionPreference='Stop': PowerShell 5.1 turns npx's stderr warnings into errors; check exit codes instead.
function Check($what) { if ($LASTEXITCODE) { throw "$what failed (exit $LASTEXITCODE)" } }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Node.js 18+ is required (https://nodejs.org)' }

. "$PSScriptRoot\tools\find-aseprite.ps1"
if ($aseprite) { Write-Output "Aseprite: $aseprite" }
else { Write-Warning 'Aseprite not found. Install it (Steam, aseprite.org or built from source) or set $env:ASEPRITE to aseprite.exe' }

Write-Output 'Installing skills...'
npx -y skills add omer-metin/skills-for-antigravity --skill pixel-art-sprites -g -a claude-code -y; Check 'pixel-art-sprites install'
npx -y skills add PlayableIntelligence/game-creator --skill game-assets -g -a claude-code -y; Check 'game-assets install'

if ($Mcp) {
  if (-not (Get-Command py -ErrorAction SilentlyContinue)) { throw 'The Aseprite MCP needs Python 3.10+ (py launcher)' }
  $dir = "$env:USERPROFILE\aseprite-ai-mcp"
  if (-not (Test-Path $dir)) { git clone https://github.com/PabloAlcoleaSesse/aseprite-ai-mcp.git $dir; Check 'git clone' }
  # Its installer builds the Aseprite extension, starts the local service and registers it in ~/.claude.json.
  Push-Location $dir; try { py install.py; Check 'aseprite-ai-mcp install.py' } finally { Pop-Location }
}

Write-Output 'Done. Restart Claude Code so it picks up the skills (and the MCP).'
