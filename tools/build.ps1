# Rebuilds every sprites/<name>/src into <name>.aseprite (one tag per animation) plus a spritesheet+JSON, PNG frames and 8x GIF previews per tag.
# Usage: .\tools\build.ps1 [-Sprite <name>]
param([string]$Sprite = '*')
. "$PSScriptRoot\find-aseprite.ps1"
if (-not $aseprite) { throw 'Aseprite not found: set $env:ASEPRITE to the full path of aseprite.exe' }
# aseprite.exe is a GUI-subsystem app: `&` returns before it finishes, so wait explicitly.
function ase { Start-Process $aseprite -ArgumentList ($args | ForEach-Object { "`"$_`"" }) -Wait -NoNewWindow }
$root = Split-Path $PSScriptRoot
foreach ($dir in Get-ChildItem "$root\sprites" -Directory -Filter $Sprite) {
  $name = $dir.Name
  $file = "$($dir.FullName)\$name.aseprite"
  $out = "$($dir.FullName)\export"
  Remove-Item $file, $out -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force "$out\frames" | Out-Null
  ase -b --script-param "dir=$($dir.FullName)\src" --script-param "out=$file" --script "$PSScriptRoot\grid_to_aseprite.lua"
  if (-not (Test-Path $file)) { throw "build failed for $name (see Aseprite error above)" }
  ase -b $file --sheet-type rows --split-tags --sheet "$out\${name}_sheet.png" --data "$out\${name}_sheet.json" --format json-array --list-tags
  foreach ($anim in Get-ChildItem "$($dir.FullName)\src\*.txt" -Exclude palette.txt) {
    $tag = $anim.BaseName
    ase -b --tag $tag $file --save-as "$out\frames\${name}_${tag}_{tagframe1}.png"
    ase -b --tag $tag $file --scale 8 --save-as "$out\${name}_${tag}_x8.gif"
  }
  Write-Output "built $name"
}
