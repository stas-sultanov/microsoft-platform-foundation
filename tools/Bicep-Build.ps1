<#
.SYNOPSIS
	Builds all Bicep files under a source root, or only selected files.
.PARAMETER sourceRoot
	Root folder containing Bicep sources. Defaults to the repository's src folder.
.PARAMETER files
	Optional list of Bicep file paths relative to sourceRoot. When omitted, builds every Bicep file.
.EXAMPLE
	.\tools\Bicep-Build.ps1 -files 'Azure\library\common.bicep', 'Entra\applications\Password.bicep'
.NOTES
	Author: Stas Sultanov
#>

#Requires -Version 7.0

param
(
	[ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
	[String] $sourceRoot = (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'),

	[ValidateCount(1, [Int32]::MaxValue)]
	[ValidateScript({ -not [String]::IsNullOrWhiteSpace($_) -and -not [System.IO.Path]::IsPathRooted($_) })]
	[String[]] $files = @()
)

begin {
	$ErrorActionPreference = 'Stop';

	Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'Common.psm1') -Force;
}

process {
	trap {
		Write-Step $false $_.Exception.Message;
		exit 1;
	}

	$bicepFiles = Invoke-Step 'Find Bicep files' { Get-BicepFile -sourceRoot $sourceRoot -files $files } { param($result) "$($result.Count) file(s)" };

	$failureCount = Invoke-StepForEach $bicepFiles { param($file) "Build $($file.DisplayPath)" } {
		param($file)

		Invoke-AzBicep 'build' $file.FullName @('--stdout');
	};

	exit ($failureCount -gt 0 ? 1 : 0);
}
