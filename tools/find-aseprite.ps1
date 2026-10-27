# Sets $aseprite to the first Aseprite executable found ($env:ASEPRITE wins), or $null.
$aseprite = @(
  $env:ASEPRITE,
  'C:\aseprite\build\bin\aseprite.exe',
  "$env:ProgramFiles\Aseprite\Aseprite.exe",
  "${env:ProgramFiles(x86)}\Steam\steamapps\common\Aseprite\Aseprite.exe",
  "$env:ProgramFiles\Steam\steamapps\common\Aseprite\Aseprite.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
