<#
.SYNOPSIS
	Common functions shared by the scripts in the tools folder.
.NOTES
	Author: Stas Sultanov
#>

#Requires -Version 7.0

$script:stepIndex = 0;

<#
.SYNOPSIS
	Prints one completed step as '[index] status message', followed by optional details.

.DESCRIPTION
	The step index is incremented automatically. The index and the status have fixed width.
	SUCCESS is printed in green, FAIL in red.
#>
function Write-Step
(
	[Parameter(Mandatory = $true)] [Boolean] $success,
	[Parameter(Mandatory = $true)] [String] $message,
	[Parameter(Mandatory = $false)] [String] $details
)
{
	$script:stepIndex++;

	$status = $success ? 'SUCCESS' : 'FAIL';
	$statusColor = $success ? 'Green' : 'Red';

	Write-Host ([String]::Format('[{0:D4}] ', $script:stepIndex)) -NoNewline;
	Write-Host ([String]::Format('{0,-7}', $status)) -ForegroundColor $statusColor -NoNewline;
	Write-Host " $message";

	if (-not [String]::IsNullOrWhiteSpace($details))
	{
		Write-Host $details;
	}
}

<#
.SYNOPSIS
	Runs 'az bicep <command> --file <file>' and returns its exit code and combined output.
#>
function Invoke-AzBicep
(
	[Parameter(Mandatory = $true)] [ValidateSet('build', 'format', 'publish')] [String] $command,
	[Parameter(Mandatory = $true)] [String] $file,
	[Parameter(Mandatory = $false)] [String[]] $arguments = @()
)
{
	# Native stderr must not become a terminating error before the exit code is checked.
	$ErrorActionPreference = 'Continue';

	$output = & az bicep $command --file $file @arguments 2>&1;
	$exitCode = $LASTEXITCODE;

	return [PSCustomObject]@{
		ExitCode = $exitCode;
		Output   = (($output | ForEach-Object { $_.ToString() }) -join [System.Environment]::NewLine);
	};
}

<#
.SYNOPSIS
	Runs an action as a single logged step and returns the action output as an array.

.DESCRIPTION
	On success prints SUCCESS, optionally appending the text returned by the summary script block.
	On failure throws an error whose message is prefixed with the step message; the caller logs it as FAIL.
#>
function Invoke-Step
(
	[Parameter(Mandatory = $true)] [String] $message,
	[Parameter(Mandatory = $true)] [ScriptBlock] $action,
	[Parameter(Mandatory = $false)] [ScriptBlock] $summary
)
{
	$ErrorActionPreference = 'Stop';

	try
	{
		$result = & $action;

		$text = $message;

		if ($null -ne $summary)
		{
			$text = "$message - $(& $summary $result)";
		}
	}
	catch
	{
		throw "$message - $($_.Exception.Message)";
	}

	Write-Step $true $text;

	# The comma keeps a collection from being unrolled by the pipeline; no output becomes an empty array.
	if ($null -eq $result)
	{
		return , @();
	}

	return , $result;
}

<#
.SYNOPSIS
	Runs an action for each item as an individual logged step and returns the number of failed items.

.DESCRIPTION
	The label script block receives the item and returns the step message.
	The action script block receives the item. Its output is searched for the last object that has:
	  - Skipped set to true, which logs no step;
	  - ExitCode, which fails the item when not zero, with Output printed as details;
	  - Details, which is printed under a successful step.
	Any other output is ignored. A thrown exception fails the item. Processing continues after a failure.
#>
function Invoke-StepForEach
(
	[Parameter(Mandatory = $true)] [AllowEmptyCollection()] [Object[]] $items,
	[Parameter(Mandatory = $true)] [ScriptBlock] $label,
	[Parameter(Mandatory = $true)] [ScriptBlock] $action
)
{
	$ErrorActionPreference = 'Stop';

	$failureCount = 0;

	foreach ($item in $items)
	{
		$message = [String](& $label $item);

		try
		{
			$output = @(& $action $item);
		}
		catch
		{
			$failureCount++;

			Write-Step $false "$message - $($_.Exception.Message)";

			continue;
		}

		$result = $output | Where-Object {
			$null -ne $_ -and ($null -ne $_.PSObject.Properties['Skipped'] -or $null -ne $_.PSObject.Properties['ExitCode'] -or $null -ne $_.PSObject.Properties['Details'])
		} | Select-Object -Last 1;

		if ($null -ne $result.PSObject.Properties['Skipped'] -and $result.Skipped)
		{
			continue;
		}

		if ($null -ne $result.PSObject.Properties['ExitCode'] -and $result.ExitCode -ne 0)
		{
			$failureCount++;

			Write-Step $false "$message - exit code $($result.ExitCode)" $result.Output;

			continue;
		}

		Write-Step $true $message $result.Details;
	}

	return $failureCount;
}

<#
.SYNOPSIS
	Finds Bicep files under a source root, or validates and returns only the selected files.

.DESCRIPTION
	Returns FileInfo objects sorted by full path, extended with:
	  - RelativePath: path relative to the source root;
	  - DisplayPath: RelativePath prefixed with '.' and the directory separator.
#>
function Get-BicepFile
(
	[Parameter(Mandatory = $true)] [String] $sourceRoot,
	[Parameter(Mandatory = $false)] [String[]] $files = @()
)
{
	$ErrorActionPreference = 'Stop';

	$sourceRootPath = (Resolve-Path -LiteralPath $sourceRoot).Path;

	$separator = [System.IO.Path]::DirectorySeparatorChar;

	$rootPrefix = $sourceRootPath.TrimEnd('\', '/') + $separator;

	if ($files.Count -gt 0)
	{
		$bicepFiles = @(
			foreach ($relativePath in $files)
			{
				$file = Get-Item -LiteralPath (Join-Path -Path $sourceRootPath -ChildPath $relativePath) -ErrorAction Stop;

				if (-not $file.FullName.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase))
				{
					throw "File must be under sourceRoot: '$relativePath'.";
				}

				if ($file.PSIsContainer -or $file.Extension -ne '.bicep')
				{
					throw "File must be a Bicep template: '$relativePath'.";
				}

				$file;
			}
		) | Sort-Object -Property FullName -Unique;
	}
	else
	{
		$bicepFiles = @(Get-ChildItem -LiteralPath $sourceRootPath -Recurse -Filter '*.bicep' -File | Sort-Object -Property FullName);
	}

	if ($bicepFiles.Count -eq 0)
	{
		throw "No Bicep templates found under '$sourceRootPath'.";
	}

	return @(
		foreach ($file in $bicepFiles)
		{
			$relativePath = $file.FullName.Substring($rootPrefix.Length);

			$file |
				Add-Member -NotePropertyName RelativePath -NotePropertyValue $relativePath -PassThru -Force |
				Add-Member -NotePropertyName DisplayPath -NotePropertyValue ".$separator$relativePath" -PassThru -Force;
		}
	);
}

Export-ModuleMember -Function Write-Step, Invoke-AzBicep, Invoke-Step, Invoke-StepForEach, Get-BicepFile;
