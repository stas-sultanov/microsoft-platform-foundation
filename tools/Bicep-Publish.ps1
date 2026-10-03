<#
.SYNOPSIS
	Publishes every Bicep file under a source root to an OCI registry.

.DESCRIPTION
	Each Bicep file is published as a separate module artifact. The artifact
	repository is derived from the file path relative to the source root,
	lowercased, without the '.bicep' extension, and with a trailing 'main'
	segment removed:

	  Azure/resources/Network/virtualNetworks/main.bicep -> <Registry>/azure/resources/network/virtualnetworks:<Version>
	  Azure/library/common.bicep                         -> <Registry>/azure/library/common:<Version>

	Existing tags are never overwritten. Use -WhatIf to preview targets.

.PARAMETER Registry
	Registry and repository prefix, for example 'ghcr.io/owner/repo'.

.PARAMETER Version
	Semantic version used as the artifact tag, for example '1.2.3' or '1.2.3-beta.1'.

.PARAMETER SourceRoot
	Root folder containing Bicep sources. Defaults to the repository's src folder.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[ValidatePattern('^[a-z0-9.\-]+(:[0-9]+)?(/[a-z0-9._\-]+)*$')]
	[string]$Registry,

	[Parameter(Mandatory)]
	[ValidatePattern('^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*)?$')]
	[string]$Version,

	[string]$SourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src')
)

$ErrorActionPreference = 'Stop'

$SourceRoot = (Resolve-Path -Path $SourceRoot -ErrorAction Stop).Path
$bicepFiles = Get-ChildItem -Path $SourceRoot -Recurse -Filter '*.bicep' -File |
Sort-Object -Property FullName

if (-not $bicepFiles) {
	throw "No Bicep templates found under '$SourceRoot'."
}

$modules = foreach ($file in $bicepFiles) {
	$relativePath = $file.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
	$segments = [System.Collections.Generic.List[string]]($relativePath -split '[\\/]')
	$segments[-1] = [System.IO.Path]::GetFileNameWithoutExtension($segments[-1])
	if ($segments.Count -gt 1 -and $segments[-1] -ceq 'main') {
		$segments.RemoveAt($segments.Count - 1)
	}

	[pscustomobject]@{
		File       = $file.FullName
		Repository = "$Registry/$(($segments -join '/').ToLowerInvariant())"
	}
}

$duplicates = $modules | Group-Object -Property Repository | Where-Object -Property Count -GT 1
if ($duplicates) {
	$duplicates | ForEach-Object { Write-Host "Artifact '$($_.Name)' is produced by: $($_.Group.File -join ', ')" }
	throw 'Artifact repository name collision detected.'
}

$failedFiles = [System.Collections.Generic.List[string]]::new()

foreach ($module in $modules) {
	$target = "br:$($module.Repository):$Version"

	if (-not $PSCmdlet.ShouldProcess($module.File, "Publish to $target")) {
		continue
	}

	Write-Host "Publishing $($module.File) -> $target"
	$previousErrorActionPreference = $ErrorActionPreference
	try {
		$ErrorActionPreference = 'Continue'
		$publishOutput = & az bicep publish --file $module.File --target $target --with-source 2>&1
		$publishExitCode = $LASTEXITCODE
	}
	finally {
		$ErrorActionPreference = $previousErrorActionPreference
	}

	if ($publishExitCode -ne 0) {
		$failedFiles.Add($module.File)
		Write-Host "Publish failed for $($module.File):"
		$publishOutput | ForEach-Object { Write-Host $_ }
	}
}

if ($failedFiles.Count -gt 0) {
	Write-Host "Bicep publish completed with error(s) in $($failedFiles.Count) file(s)."
	exit 1
}

exit 0
