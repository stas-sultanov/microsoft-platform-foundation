# Microsoft Platform Foundation

An opinionated foundation for building secure and reliable IT solutions on Microsoft Azure and Microsoft Entra ID.

Created by [Stas Sultanov](https://www.linkedin.com/in/stas-sultanov)

## Purpose

Microsoft Platform Foundation is a Bicep module library that provides reusable, opinionated building blocks for Microsoft Azure and Microsoft Entra ID.

It defines a small, current, strongly typed configuration surface for common platform capabilities so consuming solutions can configure workload intent without repeatedly making low-level Azure resource decisions.

## Scope

The foundation is intentionally **not** a complete abstraction of Azure Resource Manager and is not intended to expose every capability, compatibility option, or historical property available in Azure APIs.

Instead, it exposes the practices and capabilities considered appropriate for the majority of solutions that build on Azure and Microsoft Entra ID. When Azure provides multiple ways to achieve the same result, modules SHOULD expose the preferred foundation mechanism. Where no additional foundation opinion is required, modules MAY use native Azure resource API types directly.

## Foundation Contract

The sections below define the contract this foundation is designed to enforce.

### Design Principles

- **Opinionated by design.** Modules MUST encode architectural and security decisions instead of acting as thin wrappers around Azure resource APIs.
- **Modern authentication.** Microsoft Entra ID-based authorization MUST be used as the data-plane authentication model wherever the Azure service supports it.
- **Modern security baseline.** Legacy authentication mechanisms, obsolete configuration options, and weaker security modes MUST NOT be exposed to module consumers.
- **Modern transport security.** TLS 1.3 MUST be used wherever the Azure service supports it.
- **Pragmatic configuration.** Modules SHOULD curate properties when the foundation owns a decision and MAY reuse native Azure resource API types when the Azure resource shape is the intended configuration surface.
- **Strong typing.** Module interfaces MUST make invalid or undesirable configurations difficult or impossible to express.
- **Secure defaults are implementation decisions.** Consumers SHOULD configure business and workload requirements rather than repeatedly making low-level platform security decisions.
- **Platform-managed keys by default.** Modules are designed for the common case where platform-managed encryption keys are sufficient.

### Evolution and Compatibility

Microsoft Platform Foundation is an evolving engineering foundation, not a backward-compatible package ecosystem.

Azure evolves, security guidance evolves, and engineering practices evolve. The foundation is expected to evolve with them. This can intentionally introduce breaking changes to module interfaces when a better implementation, safer Azure capability, or clearer abstraction becomes available.

Backward compatibility MUST NOT be preserved solely to keep obsolete properties, legacy mechanisms, or historical module interfaces working.

Consumers are expected to adapt their infrastructure code when adopting a newer revision of the foundation.

Projects that require a stable dependency MAY pin the foundation to a Git commit, tag, Git submodule revision, or an immutable module artifact. Updating that reference is an explicit adoption of the newer foundation contract and MAY require changes in the consuming project.

This model favors a small, current, maintainable configuration surface over accumulating deprecated compatibility layers.

## Tooling

The `tools` folder contains repository-maintenance scripts:

- `Bicep-Build.ps1` compiles all Bicep files under `src`.
- `Bicep-Format.ps1` formats all Bicep files under `src`.
- `Sync-ApiVersions.ps1` infers and verifies or replaces Bicep resource API versions across `src`.

## Module Organization

### Module Types

| Area                     | Purpose                                                                      | Rules                                                                                                                                                                                                                                                    |
| ------------------------ | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/Azure/library`      | Shared types, functions, and constants                                       | MUST NOT contain resources.                                                                                                                                                                                                                              |
| `src/Azure/patterns`     | Reusable compositions that deploy and wire multiple resource types           | MUST own the relationship between the resources they compose.                                                                                                                                                                                            |
| `src/Azure/resources`    | Opinionated canonical deployment modules for one primary Azure resource type | MUST create the primary resource and MAY create its child resources and extension resources, such as diagnostics and authorization.                                                                                                                      |
| `src/Azure/specs`        | Scenario-specific specializations of one primary Azure resource type         | MUST create the primary resource specialization and MAY create its child resources and extension resources, such as diagnostics and authorization. MUST remain resource-specific and more constrained or opinionated than `src/Azure/resources` modules. |
| `src/Entra/applications` | Entra application artifacts managed through Microsoft Graph                  | MUST be used for Microsoft Graph-driven Entra application artifacts.                                                                                                                                                                                     |

### Path Conventions

- `src/Azure/library/<Name>.bicep`
- `src/Azure/library/<Provider>/<resourceType>.bicep`
- `src/Azure/patterns/<Domain>/<Name>.bicep`
- `src/Azure/patterns/<Domain>/<SubDomain>/<Name>.bicep`
- `src/Azure/resources/<Provider>/<resourceType>/main.bicep`
- `src/Azure/resources/<Provider>/<resourceType>/<childResourceType>/main.bicep`
- `src/Azure/resources/<Provider>/<resourceType>/<childResourceType>/<childResourceType>/main.bicep`
- `src/Azure/specs/<Provider>/<resourceType>/<Name>.bicep`
- `src/Azure/specs/<Provider>/<resourceType>/<childResourceType>/<Name>.bicep`
- `src/Azure/specs/<Provider>/<resourceType>/<childResourceType>/<childResourceType>/<Name>.bicep`
- `src/Entra/applications/<Name>.bicep`

Child resource type path segments MAY continue as deeply as the Azure resource type requires.

`Provider` and `resourceType` and `childResourceType` names MUST match the Azure resource type name.

## Module Authoring

All modules in this repository MUST follow the [Bicep Authoring Standard](docs/bicep-authoring-standard.md).

## References

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager API Versions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-resources)
