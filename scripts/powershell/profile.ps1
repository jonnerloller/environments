# Shared PowerShell profile entrypoint for the environments repo.

$env:ENVIRONMENTS_REPO = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$environmentProfileScripts = Join-Path $PSScriptRoot 'profile.d'

if (Test-Path -LiteralPath $environmentProfileScripts -PathType Container) {
  $environmentProfileScriptFiles = Get-ChildItem -LiteralPath $environmentProfileScripts -Filter '*.ps1' -File |
    Sort-Object -Property Name

  foreach ($environmentProfileScriptFile in $environmentProfileScriptFiles) {
    . $environmentProfileScriptFile.FullName
  }
}

Remove-Variable environmentProfileScripts, environmentProfileScriptFiles, environmentProfileScriptFile -ErrorAction SilentlyContinue
