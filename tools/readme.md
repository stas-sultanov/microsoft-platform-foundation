# Tools

PowerShell scripts for formatting, validating, and publishing the Bicep modules in `src`.

## Requirements

- PowerShell 7.0 or later.
- Azure CLI with the Bicep CLI version listed in [Bicep Version](../readme.md#bicep-version). The scripts call `az bicep`, not a standalone `bicep` executable.
- Examples assume the repository root as the working directory.

## Scripts

| Script                                       | Purpose                                    | Side effects                            |
| -------------------------------------------- | ------------------------------------------ | --------------------------------------- |
| [Format.ps1](Format.ps1)                     | Format Bicep files.                        | Rewrites files.                         |
| [Sync-ApiVersions.ps1](Sync-ApiVersions.ps1) | Verify or align resource API versions.     | Rewrites files with `-RunMode Replace`. |
| [Build.ps1](Build.ps1)                       | Compile Bicep files and run linter checks. | None.                                   |
| [Publish.ps1](Publish.ps1)                   | Publish modules to an OCI registry.        | Pushes artifacts to a registry.         |

Do not use [Common.psm1](Common.psm1) directly; it contains helpers shared by the scripts.

## Common Behavior

- `-SourceRoot` is optional and defaults to `src`.
- `-Files` is supported only by `Format.ps1` and `Build.ps1`. It accepts one or more `.bicep` paths relative to `-SourceRoot`, such as `'Azure/library/common.bicep'`. Absolute paths and paths outside `-SourceRoot` are rejected. If `-Files` is omitted, all `.bicep` files under `-SourceRoot` are processed.
- Processing continues after a file fails.
- Each step prints `[NNNN] SUCCESS <message>` or `[NNNN] FAIL <message>`. Bicep CLI output is printed only after `FAIL` lines.
- Exit code `0` means all steps succeeded; `1` means at least one step failed.

## Format.ps1

Formats files in place with `az bicep format` and the settings in [bicepconfig.json](../src/bicepconfig.json).

```powershell
./tools/Format.ps1 -Files 'Azure/resources/KeyVault/vaults/main.bicep'
```

## Sync-ApiVersions.ps1

Enforces one API version per API-version family, as defined in [Resources and API Versions](../doc/authoring-rules.md#resources-and-api-versions). Always scans all files under `-SourceRoot`.

```powershell
./tools/Sync-ApiVersions.ps1                   # Verify: report mismatches; exit 1 if any.
./tools/Sync-ApiVersions.ps1 -RunMode Replace  # Replace mismatched versions in place.
```

Rules:

- A reference is any text matching `<Namespace>/<type>[/<childType>...]@YYYY-MM-DD[-preview]`, including text in comments. Other version formats, such as `Microsoft.Graph/applications@beta`, are ignored.
- A family is the namespace and top-level type, such as `Microsoft.KeyVault/vaults` for `Microsoft.KeyVault/vaults/secrets@2026-05-15`.
- The expected version of a family is its newest preview version if it has any; otherwise, its newest stable version. Only versions already present under `-SourceRoot` are considered.
- To change a family's version, set one reference to the target version and run `-RunMode Replace`. This works only if the target becomes the expected version. Otherwise, such as when moving from preview to stable, update every reference in the family manually.

## Build.ps1

Compiles files with `az bicep build --stdout` to detect compiler errors and linter errors configured in [bicepconfig.json](../src/bicepconfig.json). Writes no files.

```powershell
./tools/Build.ps1 -Files 'Azure/library/common.bicep', 'Entra/applications/Password.bicep'
```

Build changed files, files changed by `Sync-ApiVersions.ps1`, and their affected consumers, as defined in [Verification](../doc/authoring-rules.md#verification). Omit `-Files` only for a full build.

## Publish.ps1

Publishes every `.bicep` file under `-SourceRoot` as a separate module with `az bicep publish --with-source`. Run only when a release is explicitly requested.

- `-Registry` (required): lowercase `host[:port][/path]`, such as `ghcr.io/owner/repo`.
- `-Version` (required): `MAJOR.MINOR.PATCH` with an optional prerelease suffix, such as `1.2.3-beta.1`. Build metadata is not allowed.
- Target: `br:<Registry>/<artifact>:<Version>`, where `<artifact>` is the lowercase path relative to `-SourceRoot`, without `.bicep` and without a trailing `main` segment. For example, `Azure/resources/KeyVault/vaults/main.bicep` becomes `azure/resources/keyvault/vaults`.
- If two files produce the same artifact, the script fails before publishing.
- Requires push access to the registry. Use `-WhatIf` to validate artifact names without publishing.

```powershell
./tools/Publish.ps1 -Registry 'ghcr.io/owner/repo' -Version '1.2.3' -WhatIf
```

## Change Workflow

After creating or changing Bicep files, run:

1. `./tools/Format.ps1 -Files <changed files>`
2. `./tools/Sync-ApiVersions.ps1 -RunMode Replace`
3. `./tools/Build.ps1 -Files <changed files, files changed in step 2, and affected consumers>`
