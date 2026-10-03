# Microsoft Platform Foundation

An opinionated Bicep module library for secure, reliable infrastructure on Microsoft Azure and Microsoft Entra ID.

## Bicep Version

The foundation depends directly on Bicep, is tied to its version, and is updated with every new Bicep release.

Bicep CLI version: [0.47.16](https://github.com/Azure/bicep/releases/tag/v0.47.16).

## Documentation

- [Foundation Contract](doc/foundation-contract.md): design principles, security, and compatibility.
- [Module Structure](doc/module-structure.md): module categories and paths.
- [Bicep Authoring Rules](doc/bicep-authoring-rules.md): Bicep implementation conventions.

## Tooling

- [Build](tools/Bicep-Build.ps1) — compile Bicep files under `src`.
- [Format](tools/Bicep-Format.ps1) — format Bicep files under `src`.
- [Sync API versions](tools/Sync-ApiVersions.ps1) — verify or align resource API versions across `src`.

Created by [Stas Sultanov](https://www.linkedin.com/in/stas-sultanov).
