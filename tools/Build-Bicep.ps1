<#
.SYNOPSIS
	Builds every Bicep file under a source root.

.PARAMETER SourceRoot
	Root folder containing Bicep sources. Defaults to the repository's src folder.
#>

param(
	[string]$SourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src')
)

$ErrorActionPreference = 'Stop'

$SourceRoot = (Resolve-Path -Path $SourceRoot -ErrorAction Stop).Path
$bicepFiles = Get-ChildItem -Path $SourceRoot -Recurse -Filter '*.bicep' -File |
	Sort-Object -Property FullName

if (-not $bicepFiles) {
	throw "No Bicep templates found under '$SourceRoot'."
}

foreach ($file in $bicepFiles) {
	Write-Host "Building $($file.FullName)"
	az bicep build --file $file.FullName --stdout > $null

	if ($LASTEXITCODE -ne 0) {
		exit $LASTEXITCODE
	}
}