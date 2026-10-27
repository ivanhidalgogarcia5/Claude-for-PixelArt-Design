# Checks everything the pixel-art workflow needs, one line per item. Exit code = number of required items missing.
# Usage: .\tools\doctor.ps1
$root = Split-Path $PSScriptRoot
$missing = 0
function Report($ok, $what, $fix) {
  if ($ok) { "OK        $what" } else { "MISSING   $what -> $fix"; $script:missing++ }
}

Report (Get-Command node -ErrorAction SilentlyContinue) 'Node.js' 'install Node.js 18+ from https://nodejs.org'
. "$PSScriptRoot\find-aseprite.ps1"
Report $aseprite "Aseprite $aseprite" 'install Aseprite (Steam, aseprite.org or from source) or set $env:ASEPRITE to aseprite.exe'
foreach ($s in 'pixel-art-sprites', 'game-assets') {
  Report (Test-Path "$env:USERPROFILE\.claude\skills\$s\SKILL.md") "skill $s" 'run .\install.ps1'
}

# A real build of the example sprite, into a temp file so the repo stays untouched.
if ($aseprite) {
  $tmp = Join-Path $env:TEMP 'pixeldesign-check.aseprite'
  Remove-Item $tmp -ErrorAction SilentlyContinue
  Start-Process $aseprite -Wait -NoNewWindow -ArgumentList '-b', '--script-param', "`"dir=$root\sprites\slime\src`"", '--script-param', "`"out=$tmp`"", '--script', "`"$PSScriptRoot\grid_to_aseprite.lua`""
  Report (Test-Path $tmp) 'test build of sprites/slime' 'see the Aseprite error above'
  Remove-Item $tmp -ErrorAction SilentlyContinue
}

# Optional: live drawing in an open Aseprite.
$config = "$env:USERPROFILE\.claude.json"
if ((Test-Path $config) -and (Select-String -Path $config -Pattern '"aseprite"\s*:' -Quiet)) { 'OK        Aseprite MCP configured (optional)' }
else { 'OPTIONAL  Aseprite MCP not configured -> .\install.ps1 -Mcp' }

exit $missing
