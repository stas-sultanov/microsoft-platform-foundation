<#
.SYNOPSIS
	Publishes every Bicep file under a source root to an OCI registry.
.DESCRIPTION
	Publishes each Bicep file as a separate module artifact.
.PARAMETER registry
	Registry and repository prefix, for example 'ghcr.io/owner/repo'.
.PARAMETER version
	Semantic version used as the artifact tag, for example '1.2.3' or '1.2.3-beta.1'.
.PARAMETER sourceRoot
	Root folder containing Bicep sources. Defaults to the repository's src folder.
.NOTES
	Author: Stas Sultanov
#>

#Requires -Version 7.0

[CmdletBinding(SupportsShouldProcess = $true)]
param
(
	[Parameter(Mandatory = $true)]
	[ValidatePattern('^[a-z0-9.\-]+(:[0-9]+)?(/[a-z0-9._\-]+)*$', Options = [System.Text.RegularExpressions.RegexOptions]::None)]
	[String] $registry,

	[Parameter(Mandatory = $true)]
	[ValidatePattern('^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z\-]+(\.[0-9A-Za-z\-]+)*)?$', Options = [System.Text.RegularExpressions.RegexOptions]::None)]
	[String] $version,

	[ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
	[String] $sourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src')
)

begin
{
	$ErrorActionPreference = 'Stop';

	Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Common.psm1') -Force;
}

process
{
	trap
	{
		Write-Step $false $_.Exception.Message;
		exit 1;
	}

	$bicepFiles = Invoke-Step 'Find Bicep files' { Get-BicepFile -sourceRoot $sourceRoot } { param($result) "$($result.Count) file(s)" };

	$modules = Invoke-Step 'Resolve artifact repositories' {
		$items = @(
			foreach ($file in $bicepFiles)
			{
				$segments = [System.Collections.Generic.List[String]]($file.RelativePath -split '[\\/]');
				$segments[-1] = [System.IO.Path]::GetFileNameWithoutExtension($segments[-1]);

				if ($segments.Count -gt 1 -and $segments[-1] -ceq 'main')
				{
					$segments.RemoveAt($segments.Count - 1);
				}

				[PSCustomObject]@{
					File        = $file.FullName;
					DisplayPath = $file.DisplayPath;
					Repository  = "$registry/$(($segments -join '/').ToLowerInvariant())";
				};
			}
		);

		$duplicates = @($items | Group-Object -Property Repository | Where-Object -Property Count -GT 1);

		if ($duplicates.Count -gt 0)
		{
			$collisions = $duplicates | ForEach-Object { "Artifact '$($_.Name)' is produced by: $($_.Group.File -join ', ')" };

			throw "Artifact repository name collision detected.$([System.Environment]::NewLine)$($collisions -join [System.Environment]::NewLine)";
		}

		$items;
	} { param($result) "$($result.Count) module(s)" };

	$failureCount = Invoke-StepForEach $modules { param($module) "Publish $($module.DisplayPath) -> $($module.Repository):$version" } {
		param($module)

		$target = "br:$($module.Repository):$version";

		if (-not $PSCmdlet.ShouldProcess($module.File, "Publish to $target"))
		{
			return [PSCustomObject]@{ Skipped = $true };
		}

		Invoke-AzBicep 'publish' $module.File @('--target', $target, '--with-source');
	};

	exit ($failureCount -gt 0 ? 1 : 0);
}
