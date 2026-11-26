$ErrorActionPreference = "Stop"

$candidates = @(
  (Join-Path $env:LOCALAPPDATA "Programs\Pragtical\user"),
  (Join-Path $env:APPDATA "pragtical"),
  (Join-Path $env:USERPROFILE ".config\pragtical")
)

$removed = $false
foreach ($userDir in $candidates) {
  if (Test-Path $userDir) {
    $pluginDir = Join-Path $userDir "plugins\flying_island"
    $colorFile = Join-Path $userDir "colors\flying_island_dark.lua"
    if (Test-Path $pluginDir) {
      Remove-Item -Recurse -Force $pluginDir
      Write-Host "Removed plugin: $pluginDir" -ForegroundColor Yellow
      $removed = $true
    }
    if (Test-Path $colorFile) {
      Remove-Item -Force $colorFile
      Write-Host "Removed color theme: $colorFile" -ForegroundColor Yellow
      $removed = $true
    }
  }
}

if ($removed) {
  Write-Host "Uninstalled flying_island. Restart Pragtical for changes to take effect." -ForegroundColor Green
} else {
  Write-Host "No flying_island installation found in standard Pragtical user directories."
}
