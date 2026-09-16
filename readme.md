# Microsoft Platform Foundation

An opinionated foundation for building secure and reliable IT solutions on Microsoft Azure and Microsoft Entra ID.

Created by [Stas Sultanov](https://www.linkedin.com/in/stas-sultanov)

## Purpose

Microsoft Platform Foundation is a Bicep module library that provides reusable, opinionated building blocks for Microsoft Azure and Microsoft Entra ID.

It defines a small, current, strongly typed configuration surface for common platform capabilities so consuming solutions can configure workload intent without repeatedly making low-level Azure resource decisions.

## Documentation

- [Foundation Contract](doc/foundation-contract.md) defines the scope, design principles, and compatibility model.
- [Module Organization](doc/module-organization.md) describes repository areas and path conventions.
- [Bicep Authoring Standard](doc/bicep-authoring-standard.md) defines the required module authoring rules.

## Tooling

The `tools` folder contains repository-maintenance scripts:

- `Bicep-Build.ps1` compiles all Bicep files under `src`.
- `Bicep-Format.ps1` formats all Bicep files under `src`.
- `Sync-ApiVersions.ps1` infers and verifies or replaces Bicep resource API versions across `src`.

## References

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager API Versions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-resources)
