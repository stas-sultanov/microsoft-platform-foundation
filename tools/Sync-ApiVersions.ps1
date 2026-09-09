<#
.SYNOPSIS
	Verifies or replaces Azure resource API versions in Bicep files using api-versions.json.

.DESCRIPTION
	Reads api-versions.json which maps a first level resource type (e.g. Microsoft.Storage/storageAccounts)
	to the single API version allowed to be used across the repository.
	Every Bicep file under the Azure folder is scanned for resource type literals, e.g.
	'Microsoft.Storage/storageAccounts/blobServices@2026-04-01'.
	Child resource types (segments after the first one) must use the same API version as their level 1 parent.

.PARAMETER SourceRoot
	Root folder containing Azure and Entra sources. Defaults to the repository's src folder.

.PARAMETER RunMode
	Verify reports API-version mismatches. Replace updates mismatched versions using api-versions.json and reports each replacement.

.OUTPUTS
	Verify returns exit code 1 when mismatches are found. Replace returns exit code 0 after applying replacements.
#>

param(
	# Allow the caller (e.g. a workflow step) to point at a different source location.
	[string]$SourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'),

	[ValidateSet('Verify', 'Replace')]
	[string]$RunMode = 'Verify'
)

# Do not let PowerShell auto-stop on non-terminating errors; we handle failures ourselves.
$ErrorActionPreference = 'Continue'

# Resolve the source root so relative input paths produce stable file names in output.
$SourceRoot = (Resolve-Path -Path $SourceRoot).Path

# Path to the dictionary file that defines the single allowed API version per resource type.
$dictionaryPath = Join-Path -Path $SourceRoot -ChildPath 'api-versions.json'

# Path to the folder that contains the Bicep files to validate.
$azureFolderPath = Join-Path -Path $SourceRoot -ChildPath 'Azure'

# Regex that extracts a resource type literal and its API version, e.g. Microsoft.Storage/storageAccounts/blobServices@2026-04-01.
# Group 'type' captures the full type path (namespace/type1/type2/...), group 'version' captures the API version.
$typeVersionRegex = [regex]'(?<type>[A-Za-z0-9]+\.[A-Za-z0-9]+(?:/[A-Za-z0-9]+)+)@(?<version>\d{4}-\d{2}-\d{2}(?:-preview)?)'

function Find-ApiVersionMismatches {
	param(
		[Parameter(Mandatory)]
		[string]$AzureFolderPath,

		[Parameter(Mandatory)]
		[System.Collections.Generic.Dictionary[string, string]]$ExpectedVersionByType,

		[Parameter(Mandatory)]
		[string]$SourceRoot,

		[Parameter(Mandatory)]
		[regex]$TypeVersionRegex
	)

	$mismatches = [System.Collections.Generic.List[pscustomobject]]::new()
	$processingFailures = [System.Collections.Generic.List[pscustomobject]]::new()
	$bicepFiles = Get-ChildItem -Path $AzureFolderPath -Recurse -Filter '*.bicep' -File | Sort-Object -Property FullName

	foreach ($file in $bicepFiles) {
		try {
			$content = Get-Content -Path $file.FullName -Raw

			foreach ($match in $TypeVersionRegex.Matches($content)) {
				$fullType = $match.Groups['type'].Value
				$usedVersion = $match.Groups['version'].Value
				$typeSegments = $fullType -split '/'
				$level1Type = "$($typeSegments[0])/$($typeSegments[1])"

				if (-not $ExpectedVersionByType.ContainsKey($level1Type)) {
					continue
				}

				$expectedVersion = $ExpectedVersionByType[$level1Type]

				if ($usedVersion -ne $expectedVersion) {
					$mismatches.Add([pscustomobject]@{
						File            = $file.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
						FullPath        = $file.FullName
						Line            = ([regex]::Matches($content.Substring(0, $match.Index), "`n").Count + 1)
						Type            = $fullType
						UsedVersion     = $usedVersion
						ExpectedVersion = $expectedVersion
						VersionIndex    = $match.Groups['version'].Index
						VersionLength   = $match.Groups['version'].Length
					})
				}
			}
		} catch {
			$processingFailures.Add([pscustomobject]@{
				File    = $file.FullName
				Message = $_.Exception.Message
			})
		}
	}

	return [pscustomobject]@{
		FilesChecked      = $bicepFiles.Count
		Mismatches        = $mismatches
		ProcessingFailures = $processingFailures
	}
}

try {
	# Fail fast, but gracefully, when the dictionary file is missing.
	if (-not (Test-Path -Path $dictionaryPath -PathType Leaf)) {
		Write-Warning "Dictionary file not found: $dictionaryPath"

		exit 0
	}

	# Fail fast, but gracefully, when the Azure folder is missing.
	if (-not (Test-Path -Path $azureFolderPath -PathType Container)) {
		Write-Warning "Azure folder not found: $azureFolderPath"

		exit 0
	}

	# Load the dictionary JSON content and convert it into a PowerShell object.
	$dictionaryJson = Get-Content -Path $dictionaryPath -Raw | ConvertFrom-Json

	# Build a case-insensitive lookup of resource type -> expected API version.
	$expectedVersionByType = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)

	foreach ($property in $dictionaryJson.PSObject.Properties) {
		$expectedVersionByType[$property.Name] = [string]$property.Value
	}

	$scanResult = Find-ApiVersionMismatches -AzureFolderPath $azureFolderPath -ExpectedVersionByType $expectedVersionByType -SourceRoot $SourceRoot -TypeVersionRegex $typeVersionRegex
} catch {
	Write-Warning "Unexpected error while checking API versions: $($_.Exception.Message)"

	exit 0
}

Write-Host "Checked $($scanResult.FilesChecked) Bicep file(s); found $($scanResult.Mismatches.Count) API version error(s)."

foreach ($failure in $scanResult.ProcessingFailures) {
	Write-Warning "Failed to process file '$($failure.File)': $($failure.Message)"
}

if ($RunMode -eq 'Verify') {
	foreach ($mismatch in $scanResult.Mismatches) {
		Write-Host "  $($mismatch.File):$($mismatch.Line) -> $($mismatch.Type)@$($mismatch.UsedVersion) (expected @$($mismatch.ExpectedVersion))"
	}

	if ($scanResult.Mismatches.Count -eq 0) {
		Write-Host 'All Bicep resource API versions match api-versions.json.'

		exit 0
	}

	exit 1
}

$replacements = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($fileGroup in ($scanResult.Mismatches | Group-Object -Property FullPath)) {
	try {
		$content = Get-Content -Path $fileGroup.Name -Raw

		foreach ($mismatch in ($fileGroup.Group | Sort-Object -Property VersionIndex -Descending)) {
			$content = $content.Remove($mismatch.VersionIndex, $mismatch.VersionLength).Insert($mismatch.VersionIndex, $mismatch.ExpectedVersion)
			$replacements.Add($mismatch)
		}

		[System.IO.File]::WriteAllText($fileGroup.Name, $content, [System.Text.UTF8Encoding]::new($false))
	} catch {
		Write-Warning "Failed to replace versions in '$($fileGroup.Name)': $($_.Exception.Message)"
	}
}

Write-Host "Replaced $($replacements.Count) API version(s):"

foreach ($replacement in $replacements) {
	Write-Host "  $($replacement.File):$($replacement.Line) -> $($replacement.Type)@$($replacement.UsedVersion) replaced with @$($replacement.ExpectedVersion)"
}

exit 0
