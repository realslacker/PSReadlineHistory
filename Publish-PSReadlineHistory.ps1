$ThisScript = Split-Path -Path $MyInvocation.MyCommand.Definition -Leaf
$ThisFolder = [System.IO.DirectoryInfo]$PSScriptRoot
$TempFolder = Join-Path $env:TEMP $ThisFolder.Name

Update-ModuleManifest -Path ".\$($ThisFolder.Name).psd1" -ModuleVersion (Get-Date -Format yyyy.MM.dd.HHmm)

Get-ChildItem -Recurse | Where-Object { $_.Name -ne $ThisScript } | Copy-Item -Destination { $_.FullName -replace [regex]::Escape($ThisFolder.FullName), $TempFolder }

Publish-Module -Repository PSGallery -NuGetApiKey $PSGalleryApiKey -Path $TempFolder

Remove-Item -Path $TempFolder -Force -Recurse -Confirm:$false