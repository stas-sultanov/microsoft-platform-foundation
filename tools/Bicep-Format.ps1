<#
.SYNOPSIS
	Formats every Bicep file under a source root.

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

$failedFiles = [System.Collections.Generic.List[string]]::new()

foreach ($file in $bicepFiles) {
	Write-Host "Formatting $($file.FullName)"
	$previousErrorActionPreference = $ErrorActionPreference
	try {
		$ErrorActionPreference = 'Continue'
		$formatOutput = & az bicep format --file $file.FullName 2>&1
		$formatExitCode = $LASTEXITCODE
	} finally {
		$ErrorActionPreference = $previousErrorActionPreference
	}

	if ($formatExitCode -ne 0) {
		$failedFiles.Add($file.FullName)
		Write-Host "Format failed for $($file.FullName):"
		$formatOutput | ForEach-Object { Write-Host $_ }
	}
}

if ($failedFiles.Count -gt 0) {
	Write-Host "Bicep format completed with $($failedFiles.Count) error(s)."
	exit 1
}

exit 0