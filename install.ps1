$ErrorActionPreference = "Stop"

$candidates = @(
  (Join-Path $env:LOCALAPPDATA "Programs\Pragtical\user"),
  (Join-Path $env:APPDATA "pragtical"),
  (Join-Path $env:USERPROFILE ".config\pragtical")
)

$userDir = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $userDir) {
  $userDir = Join-Path $env:LOCALAPPDATA "Programs\Pragtical\user"
}

$pluginTarget = Join-Path $userDir "plugins\flying_island"
$iconsTarget  = Join-Path $pluginTarget "icons"
$colorsTarget = Join-Path $userDir "colors"

New-Item -ItemType Directory -Force -Path $iconsTarget, $colorsTarget | Out-Null
Copy-Item -Force "$PSScriptRoot\plugins\flying_island\init.lua" $pluginTarget
Copy-Item -Force "$PSScriptRoot\plugins\flying_island\theme.json" $pluginTarget
Copy-Item -Force "$PSScriptRoot\plugins\flying_island\icons\*.svg" $iconsTarget
Copy-Item -Force "$PSScriptRoot\colors\flying_island_dark.lua" $colorsTarget

Write-Host "Installed flying_island plugin to: $pluginTarget" -ForegroundColor Green
Write-Host "Installed flying_island_dark color theme to: $colorsTarget" -ForegroundColor Green
Write-Host "Please restart Pragtical to enjoy Flying Island Dark!"
