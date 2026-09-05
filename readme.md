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

## Module Organization

### Module Types

| Area                 | Purpose                                                                      | Rules                                                                                                     |
| -------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `Azure/library`      | Shared types, functions, and constants                                       | MUST NOT contain resources.                                                                               |
| `Azure/patterns`     | Reusable compositions that deploy and wire multiple resource types           | MUST own the relationship between the resources they compose.                                             |
| `Azure/resources`    | Opinionated canonical deployment modules for one primary Azure resource type | MUST create the primary resource and MAY create its child resources and extension resources, such as diagnostics and authorization. |
| `Azure/specs`        | Scenario-specific specializations of one primary Azure resource type         | MUST create the primary resource specialization and MAY create its child resources and extension resources, such as diagnostics and authorization. MUST remain resource-specific and more constrained or opinionated than `Azure/resources` modules. |
| `Entra/applications` | Entra application artifacts managed through Microsoft Graph                  | MUST be used for Microsoft Graph-driven Entra application artifacts.                                      |

### Path Conventions

- `Azure/library/<Name>.bicep`
- `Azure/library/<Provider>/<resourceType>.bicep`
- `Azure/patterns/<Domain>/<Name>.bicep`
- `Azure/patterns/<Domain>/<SubDomain>/<Name>.bicep`
- `Azure/resources/<Provider>/<resourceType>/main.bicep`
- `Azure/resources/<Provider>/<resourceType>/<childResourceType>/main.bicep`
- `Azure/resources/<Provider>/<resourceType>/<childResourceType>/<childResourceType>/main.bicep`
- `Azure/specs/<Provider>/<resourceType>/<Name>.bicep`
- `Azure/specs/<Provider>/<resourceType>/<childResourceType>/<Name>.bicep`
- `Azure/specs/<Provider>/<resourceType>/<childResourceType>/<childResourceType>/<Name>.bicep`
- `Entra/applications/<Name>.bicep`

Child resource type path segments MAY continue as deeply as the Azure resource type requires.

`Provider` and `resourceType` and `childResourceType` names MUST match the Azure resource type name.

## Module Authoring Standard

All modules in this repository MUST strictly follow the authoring standard described in this section.

### File Structure

Bicep files MUST follow this section order. Sections MAY be omitted when they are not needed, but the relative order of present sections MUST be preserved.

- Metadata
- Scope
- Imports
- Types
- Functions
- Parameters
- Variables
- Existing resources
- Resources
- Extensions
- Outputs

Metadata declarations MUST appear at the top of the file, MUST NOT use a section header, and MUST include the author block and module description.

Section headers after metadata declarations MUST use block comments, such as `/* PARAMETERS */`.

Within each section, all declarations MUST be sorted alphabetically.

### General Rules

- All declarations MUST be strongly typed.
- Parameters and outputs MUST be explicit and predictable.
- Module interfaces MUST represent the foundation contract and MAY reuse native Azure resource API types when that is the intended contract.
- Obsolete, legacy, insecure, or foundation-controlled properties SHOULD NOT be exposed as configurable parameters.
- A breaking interface change MAY be introduced when it produces a better foundation contract. Backward compatibility MUST NOT justify retaining an obsolete interface.

### Security Rules

- Data-plane access MUST use Microsoft Entra ID-based authorization where the service supports it.
- Legacy authorization models, such as Key Vault access policies, MUST NOT be used where Microsoft Entra ID-based authorization is supported.
- Keys, shared secrets, and passwords MUST NOT be used for data-plane access where Microsoft Entra ID-based authorization is supported.
- Public access, firewall rules, and trusted-service exceptions MUST be explicit in the module interface.
- TLS 1.3 MUST be enforced where the service supports it. Where TLS 1.3 is unavailable, the newest supported TLS version MUST be used.
- Outputs MUST NOT include secrets, passwords, or authentication keys.
- Customer Managed Keys (CMK) MUST NOT be assumed to be supported unless explicitly implemented by the module.

### Types

- Type names MUST describe intent, such as `PropertiesInput`, `ResourceInput`, `Resource`, `ExtensionsInput`, or a scenario-specific name.
- Configurable property types SHOULD contain only properties that consumers are expected to control when the module defines a curated property contract.
- Resource API types MAY be used in module interfaces or internally.

### Parameters

- Every parameter MUST have a `@description` decorator.
- Top-level resource modules, meaning modules that create a level 1 Azure resource type, MUST use the standard parameter surface: `extensions`, `resources`, and `settings`. The `resources` parameter is optional and MUST be omitted when the module does not create child resources.
- Child resource modules MUST use the same standard parameter surface and MUST also expose the immediate parent resource name as a top-level `parentName` parameter. If more than one parent name is required, each parent name MUST be a top-level parameter with a clear name, such as `parentNamespaceName` and `parentTopicName`.
- `extensions` MUST group extension resources by provider or concern, such as `Authorization`, `Insights`, `Maintenance`, or other. This includes diagnostics, authorization, assignments, and other resources scoped to the primary resource but not part of its child resource type hierarchy.
- `resources` MUST group child resources by child resource type.
- `settings` MUST group the configuration of the primary resource created by the module. Standard resource fields such as `identity`, `location`, `name`, `properties`, `sku`, `tags`, and `zones` MUST be nested under `settings` when applicable.
- Standard Bicep resource-derived types, such as `resourceInput` and `resourceOutput`, SHOULD be used wherever possible.
- `settings.properties` MUST represent the Azure resource `properties` object. It MAY use `resourceInput<...>.properties` directly when the native Azure resource property shape is the intended contract, or a curated object type when the foundation intentionally exposes only selected properties.
- Top-level parameters MUST be sorted alphabetically by parameter name. Parent-name parameters MUST remain top-level and participate in this ordering alongside `extensions`, `resources`, and `settings`.
- Non-resource parameters SHOULD be avoided in `Azure/resources` and `Azure/specs` modules. When required, they MAY use domain-specific names only when they do not directly represent a standard Azure resource field, child resource collection, extension resource collection, or parent name.
- Optional parameters and default values MUST be safe and predictable.

### Resources

- Resource names MUST be deterministic and MUST follow the Azure resource type path converted to underscores, such as:
- `<Provider>_<resourceType>_`
- `<Provider>_<resourceType>_<childResourceType>_`
- `<Provider>_<resourceType>_<childResourceType>_<childResourceType>_`

Child resource type segments MAY continue as deeply as the Azure resource type requires.

### Outputs

- Every output MUST have a `@description` decorator.
- Resource output names SHOULD follow standard Azure resource field names where applicable, such as `id`, `name`, `type`, `location`, `identity`, `sku`, `tags`, and `properties`.
- Values from the Azure resource `properties` object SHOULD be grouped under a `properties` output object instead of being expanded into many custom top-level output names.
- Outputs SHOULD return precise values instead of broad resource objects.

## Validation

All modules MUST comply with the rules defined in [bicepconfig.json](bicepconfig.json).

All modules MUST pass all configured checks at all times.

Rule suppressions MUST be scoped to the smallest possible line and MUST include a clear reason in a comment.

## References

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager API Versions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-extensions)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
