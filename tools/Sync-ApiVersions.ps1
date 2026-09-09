<#
.SYNOPSIS
	Verifies or replaces Azure resource API versions used across Bicep files.

.DESCRIPTION
	Scans every Bicep file under the source root, derives one API version per
	first-level resource type, and verifies or replaces all resource type
	literals against those derived versions. Preview versions are preferred when
	available; within the selected release type, the most recent date wins.

.PARAMETER SourceRoot
	Root folder containing Bicep sources. Defaults to the repository's src folder.

.PARAMETER RunMode
	Verify reports API-version mismatches. Replace updates mismatched versions.
#>

param(
	[string]$SourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'),

	[ValidateSet('Verify', 'Replace')]
	[string]$RunMode = 'Verify'
)

$ErrorActionPreference = 'Continue'

$SourceRoot = (Resolve-Path -Path $SourceRoot -ErrorAction Stop).Path
$bicepFiles = Get-ChildItem -Path $SourceRoot -Recurse -Filter '*.bicep' -File |
Sort-Object -Property FullName

if (-not $bicepFiles) {
	throw "No Bicep templates found under '$SourceRoot'."
}

# Group 1 is the full type path; the first two segments identify the resource API.
$typeVersionRegex = [regex]'(?<type>[A-Za-z0-9]+\.[A-Za-z0-9]+(?:/[A-Za-z0-9]+)+)@(?<version>\d{4}-\d{2}-\d{2}(?:-preview)?)'

function Get-ApiVersionUsage {
	param(
		[Parameter(Mandatory)]
		[System.IO.FileInfo[]]$BicepFiles,

		[Parameter(Mandatory)]
		[string]$SourceRoot,

		[Parameter(Mandatory)]
		[regex]$TypeVersionRegex
	)

	$usages = [System.Collections.Generic.List[pscustomobject]]::new()
	$processingFailures = [System.Collections.Generic.List[pscustomobject]]::new()

	foreach ($file in $BicepFiles) {
		try {
			$content = Get-Content -Path $file.FullName -Raw

			foreach ($match in $TypeVersionRegex.Matches($content)) {
				$fullType = $match.Groups['type'].Value
				$typeSegments = $fullType -split '/'
				$version = $match.Groups['version'].Value

				$usages.Add([pscustomobject]@{
						File          = $file.FullName.Substring($SourceRoot.Length).TrimStart('\', '/')
						FullPath      = $file.FullName
						Line          = ([regex]::Matches($content.Substring(0, $match.Index), "`n").Count + 1)
						Type          = $fullType
						Level1Type    = "$($typeSegments[0])/$($typeSegments[1])"
						Version       = $version
						VersionDate   = [datetime]::ParseExact($version.Substring(0, 10), 'yyyy-MM-dd', $null)
						IsPreview     = $version.EndsWith('-preview')
						VersionIndex  = $match.Groups['version'].Index
						VersionLength = $match.Groups['version'].Length
					})
			}
		}
		catch {
			$processingFailures.Add([pscustomobject]@{
					File    = $file.FullName
					Message = $_.Exception.Message
				})
		}
	}

	return [pscustomobject]@{
		FilesChecked       = $BicepFiles.Count
		Usages             = $usages
		ProcessingFailures = $processingFailures
	}
}

function Get-PreferredVersions {
	param(
		[Parameter(Mandatory)]
		[object[]]$Usages
	)

	$preferredVersions = [System.Collections.Generic.Dictionary[string, string]]::new([System.StringComparer]::OrdinalIgnoreCase)

	foreach ($typeGroup in ($Usages | Group-Object -Property Level1Type)) {
		$previewVersions = @($typeGroup.Group | Where-Object IsPreview)
		$candidates = if ($previewVersions.Count -gt 0) { $previewVersions } else { @($typeGroup.Group | Where-Object { -not $_.IsPreview }) }
		$preferred = $candidates | Sort-Object -Property VersionDate -Descending | Select-Object -First 1
		$preferredVersions[$typeGroup.Name] = $preferred.Version
	}

	return $preferredVersions
}

$scanResult = Get-ApiVersionUsage -BicepFiles $bicepFiles -SourceRoot $SourceRoot -TypeVersionRegex $typeVersionRegex
$preferredVersions = Get-PreferredVersions -Usages $scanResult.Usages
$mismatches = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($usage in $scanResult.Usages) {
	$expectedVersion = $preferredVersions[$usage.Level1Type]

	if ($usage.Version -ne $expectedVersion) {
		$usage | Add-Member -NotePropertyName ExpectedVersion -NotePropertyValue $expectedVersion
		$mismatches.Add($usage)
	}
}

Write-Host "Checked $($scanResult.FilesChecked) Bicep file(s); found $($mismatches.Count) API version error(s)."

foreach ($failure in $scanResult.ProcessingFailures) {
	Write-Warning "Failed to process file '$($failure.File)': $($failure.Message)"
}

if ($RunMode -eq 'Verify') {
	foreach ($mismatch in $mismatches) {
		Write-Host "  $($mismatch.File):$($mismatch.Line) -> $($mismatch.Type)@$($mismatch.Version) (expected @$($mismatch.ExpectedVersion))"
	}

	if ($mismatches.Count -eq 0) {
		Write-Host 'All Bicep resource API versions match the versions inferred from the repository.'
		exit 0
	}

	exit 1
}

$replacements = [System.Collections.Generic.List[pscustomobject]]::new()

foreach ($fileGroup in ($mismatches | Group-Object -Property FullPath)) {
	try {
		$content = Get-Content -Path $fileGroup.Name -Raw

		foreach ($mismatch in ($fileGroup.Group | Sort-Object -Property VersionIndex -Descending)) {
			$content = $content.Remove($mismatch.VersionIndex, $mismatch.VersionLength).Insert($mismatch.VersionIndex, $mismatch.ExpectedVersion)
			$replacements.Add($mismatch)
		}

		[System.IO.File]::WriteAllText($fileGroup.Name, $content, [System.Text.UTF8Encoding]::new($false))
	}
 catch {
		Write-Warning "Failed to replace versions in '$($fileGroup.Name)': $($_.Exception.Message)"
	}
}

Write-Host "Replaced $($replacements.Count) API version(s):"

foreach ($replacement in $replacements) {
	Write-Host "  $($replacement.File):$($replacement.Line) -> $($replacement.Type)@$($replacement.Version) replaced with @$($replacement.ExpectedVersion)"
}

exit 0
