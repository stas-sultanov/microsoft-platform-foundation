<#
.SYNOPSIS
	Verifies or replaces Azure resource API versions used across Bicep files.
.DESCRIPTION
	Scans every Bicep file under the source root, derives one API version per
	first-level resource type, and verifies or replaces all resource type
	literals against those derived versions. Preview versions are preferred when
	available; within the selected release type, the most recent date wins.
.PARAMETER sourceRoot
	Root folder containing Bicep sources. Defaults to the repository's src folder.
.PARAMETER runMode
	Verify reports API-version mismatches. Replace updates mismatched versions.
.NOTES
	Author: Stas Sultanov
#>

#Requires -Version 7.0

param
(
	[ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
	[String] $sourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'),

	[ValidateSet('Verify', 'Replace')]
	[String] $runMode = 'Verify'
)

begin
{
	$ErrorActionPreference = 'Stop';

	Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Common.psm1') -Force;

	# Group 'type' is the full type path; the first two segments identify the resource API.
	$typeVersionRegex = [Regex]'(?<type>[A-Za-z0-9]+\.[A-Za-z0-9]+(?:/[A-Za-z0-9]+)+)@(?<version>[0-9]{4}-[0-9]{2}-[0-9]{2}(?:-preview)?)';

	function Get-ApiVersionUsage
	(
		[Parameter(Mandatory = $true)] [System.IO.FileInfo[]] $bicepFiles,
		[Parameter(Mandatory = $true)] [Regex] $typeVersionRegex
	)
	{
		$usages = [System.Collections.Generic.List[PSCustomObject]]::new();
		$failures = [System.Collections.Generic.List[String]]::new();

		foreach ($file in $bicepFiles)
		{
			try
			{
				$content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8;

				foreach ($match in $typeVersionRegex.Matches($content))
				{
					$fullType = $match.Groups['type'].Value;
					$typeSegments = $fullType -split '/';
					$version = $match.Groups['version'].Value;

					$usages.Add([PSCustomObject]@{
							File          = $file.RelativePath;
							FullPath      = $file.FullName;
							Line          = ([Regex]::Matches($content.Substring(0, $match.Index), "`n").Count + 1);
							Type          = $fullType;
							Level1Type    = "$($typeSegments[0])/$($typeSegments[1])";
							Version       = $version;
							VersionDate   = [DateTime]::ParseExact($version.Substring(0, 10), 'yyyy-MM-dd', $null);
							IsPreview     = $version.EndsWith('-preview');
							VersionIndex  = $match.Groups['version'].Index;
							VersionLength = $match.Groups['version'].Length;
						});
				}
			}
			catch
			{
				$failures.Add("$($file.FullName): $($_.Exception.Message)");
			}
		}

		return [PSCustomObject]@{
			Usages   = $usages;
			Failures = $failures;
		};
	}

	function Get-PreferredVersion
	(
		[Parameter(Mandatory = $true)] [AllowEmptyCollection()] [Object[]] $usages
	)
	{
		$preferredVersions = [System.Collections.Generic.Dictionary[String, String]]::new([System.StringComparer]::OrdinalIgnoreCase);

		foreach ($typeGroup in ($usages | Group-Object -Property Level1Type))
		{
			$previewVersions = @($typeGroup.Group | Where-Object IsPreview);
			$candidates = if ($previewVersions.Count -gt 0) { $previewVersions } else { @($typeGroup.Group | Where-Object { -not $_.IsPreview }) };
			$preferred = $candidates | Sort-Object -Property VersionDate -Descending | Select-Object -First 1;
			$preferredVersions[$typeGroup.Name] = $preferred.Version;
		}

		return $preferredVersions;
	}
}

process
{
	trap
	{
		Write-Step $false $_.Exception.Message;
		exit 1;
	}

	$bicepFiles = Invoke-Step 'Find Bicep files' { Get-BicepFile -sourceRoot $sourceRoot } { param($result) "$($result.Count) file(s)" };

	$usages = Invoke-Step 'Scan resource API versions' {
		$scanResult = Get-ApiVersionUsage -bicepFiles $bicepFiles -typeVersionRegex $typeVersionRegex;

		if ($scanResult.Failures.Count -gt 0)
		{
			throw "Failed to process $($scanResult.Failures.Count) file(s)$([System.Environment]::NewLine)$($scanResult.Failures -join [System.Environment]::NewLine)";
		}

		$scanResult.Usages;
	} { param($result) "$($result.Count) usage(s)" };

	$preferredVersions = Get-PreferredVersion -usages $usages;
	$mismatches = [System.Collections.Generic.List[PSCustomObject]]::new();

	foreach ($usage in $usages)
	{
		$expectedVersion = $preferredVersions[$usage.Level1Type];

		if ($usage.Version -ne $expectedVersion)
		{
			$usage | Add-Member -NotePropertyName ExpectedVersion -NotePropertyValue $expectedVersion;
			$mismatches.Add($usage);
		}
	}

	if ($runMode -eq 'Verify')
	{
		if ($mismatches.Count -gt 0)
		{
			$details = $mismatches | ForEach-Object { "  $($_.File):$($_.Line) -> $($_.Type)@$($_.Version) (expected @$($_.ExpectedVersion))" };

			Write-Step $false "Verify resource API versions - $($mismatches.Count) API version error(s)" ($details -join [System.Environment]::NewLine);
			exit 1;
		}

		Write-Step $true 'Verify resource API versions';

		exit 0;
	}

	$fileGroups = @($mismatches | Group-Object -Property FullPath);

	$failureCount = Invoke-StepForEach $fileGroups { param($fileGroup) "Replace API versions in .$([System.IO.Path]::DirectorySeparatorChar)$($fileGroup.Group[0].File) - $($fileGroup.Count) replacement(s)" } {
		param($fileGroup)

		$content = Get-Content -LiteralPath $fileGroup.Name -Raw -Encoding UTF8;

		foreach ($mismatch in ($fileGroup.Group | Sort-Object -Property VersionIndex -Descending))
		{
			$content = $content.Remove($mismatch.VersionIndex, $mismatch.VersionLength).Insert($mismatch.VersionIndex, $mismatch.ExpectedVersion);
		}

		[System.IO.File]::WriteAllText($fileGroup.Name, $content, [System.Text.UTF8Encoding]::new($false));

		$details = $fileGroup.Group | ForEach-Object { "  line $($_.Line): $($_.Type)@$($_.Version) replaced with @$($_.ExpectedVersion)" };

		[PSCustomObject]@{ Details = $details -join [System.Environment]::NewLine };
	};

	if ($fileGroups.Count -eq 0)
	{
		Write-Step $true 'Replace API versions - nothing to replace';
	}

	exit ($failureCount -gt 0 ? 1 : 0);
}
