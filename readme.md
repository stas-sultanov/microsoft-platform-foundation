# Microsoft Platform Foundation

An opinionated foundation for building secure and reliable IT solutions on Microsoft Azure and Microsoft Entra ID.

Created by [Stas Sultanov](https://www.linkedin.com/in/stas-sultanov)

## About

Microsoft Platform Foundation is a Bicep module library that provides reusable, opinionated building blocks for Microsoft Azure and Microsoft Entra ID.

The foundation is intentionally **not** a complete abstraction of Azure Resource Manager and is not intended to expose every capability, compatibility option, or historical property available in Azure APIs. Instead, it defines a curated configuration surface representing the practices and capabilities considered appropriate for the majority of modern solutions.

The foundation therefore acts as a filter between the Azure API surface and consuming solutions:

```text
Azure API surface
        ↓
Microsoft Platform Foundation
        ↓
Supported, strongly typed configuration surface
        ↓
Consuming solution
```

This is deliberate. When Azure provides multiple ways to achieve the same result, including obsolete, legacy, or less desirable mechanisms, modules SHOULD expose the preferred mechanism rather than reproduce the complete Azure API surface.

### Design Principles

The foundation follows these principles:

- **Opinionated by design.** Modules encode architectural and security decisions instead of acting as thin wrappers around Azure resource APIs.
- **Modern authentication.** Microsoft Entra ID-based authorization is the default and required data-plane authentication model wherever the Azure service supports it.
- **Modern security baseline.** Legacy authentication mechanisms, obsolete configuration options, and weaker security modes SHOULD be hidden rather than exposed as consumer choices.
- **Modern transport security.** TLS 1.3 MUST be used where the Azure service supports it. Apart from improving the security baseline, TLS 1.3 reduces protocol handshake overhead compared with earlier TLS versions.
- **Curated configuration.** Configurable property types SHOULD expose properties that consumers are expected to control while intentionally hiding obsolete, legacy, unsupported, or foundation-controlled properties.
- **Strong typing.** Module interfaces SHOULD make invalid or undesirable configurations difficult or impossible to express.
- **Secure defaults are implementation decisions.** Consumers SHOULD configure business and workload requirements rather than repeatedly make low-level platform security decisions.
- **No Customer Managed Keys baseline.** Modules are designed for the common case where platform-managed encryption keys are sufficient. Customer Managed Keys (CMK) are intentionally outside the baseline unless explicitly implemented by a specialized module.

## Evolution and Compatibility

Microsoft Platform Foundation is an evolving engineering foundation, not a backwards-compatible package ecosystem.

Azure evolves, security guidance evolves, and engineering practices evolve. The foundation is expected to evolve with them. This can intentionally introduce breaking changes to module interfaces when a better implementation, safer Azure capability, or clearer abstraction becomes available.

Backward compatibility MUST NOT be preserved solely to keep obsolete properties, legacy mechanisms, or historical module interfaces working.

Consumers are expected to adapt their infrastructure code when adopting a newer revision of the foundation.

Projects that require a stable dependency MAY pin the foundation to a Git commit, tag, Git submodule revision, or an immutable module artifact. Updating that reference is an explicit adoption of the newer foundation contract and MAY require changes in the consuming project.

This model favors a small, current, maintainable configuration surface over accumulating deprecated compatibility layers.

## Table of Contents

- [About](#about)
  - [Design Principles](#design-principles)
- [Evolution and Compatibility](#evolution-and-compatibility)
- [Layout](#layout)
- [Conventions](#conventions)
  - [Module Types](#module-types)
  - [Path Conventions](#path-conventions)
  - [Security](#security)
  - [File Structure](#file-structure)
  - [Authoring Rules](#authoring-rules)
- [Compliance](#compliance)
- [Resources](#resources)

## Layout

Repository layout.

```bash
./
├─ Azure/
│  ├─ library/       # Shared types, functions, and constants
│  ├─ patterns/      # Composition modules that wire multiple resources
│  ├─ resources/     # Opinionated baseline modules for one primary resource
│  └─ specs/         # More constrained modules for a specific resource purpose
├─ Entra/
│  └─ applications/  # Microsoft Graph modules for Entra applications
├─ bicepconfig.json  # Bicep analyzer and linting configuration
├─ readme.md         # Repository guidance
└─ license.md        # License information
```

## Conventions

All modules in this repository MUST strictly follow the conventions described in this section.

### Module Types

| Area                 | Purpose | Rules |
|----------------------|---------|-------|
| `Azure/library`      | Shared types, functions, and constants | MUST NOT contain resources. |
| `Azure/patterns`     | Reusable compositions that deploy and wire multiple resource types | MUST own the relationship between the resources they compose. |
| `Azure/resources`    | Opinionated canonical deployment modules for one primary Azure resource type | MUST implement the foundation baseline and MAY deploy extension resources scoped to the primary resource. |
| `Azure/specs`        | Scenario-specific specializations of one primary Azure resource type | MUST remain resource-specific and MUST be more constrained or opinionated than `Azure/resources` modules. |
| `Entra/applications` | Entra application artifacts managed through Microsoft Graph | MUST be used for Microsoft Graph-driven Entra application artifacts. |

### Path Conventions

- `Azure/library/<Name>.bicep`
- `Azure/library/<Provider>/<resourceType>.bicep`
- `Azure/patterns/<Domain>/<Name>.bicep`
- `Azure/patterns/<Domain>/<SubDomain>/<Name>.bicep`
- `Azure/resources/<Provider>/<resourceType>/main.bicep`
- `Azure/resources/<Provider>/<resourceType>/<nestedResourceType>/main.bicep`
- `Azure/specs/<Provider>/<resourceType>/<Name>.bicep`
- `Azure/specs/<Provider>/<resourceType>/<nestedResourceType>/<Name>.bicep`
- `Entra/applications/<Name>.bicep`

`Provider` and `resourceType` names MUST match Azure resource type name.

### Security

- Microsoft Entra ID-based authorization MUST be used for data-plane access where the service supports it.
- Legacy authorization models, such as Key Vault access policies, MUST NOT be used where the service supports Microsoft Entra ID-based authorization.
- Keys, shared secrets, and passwords MUST NOT be used for data-plane access where the service supports Microsoft Entra ID-based authorization.
- Public access, firewall rules, and trusted-service exceptions MUST be explicit in the module interface.
- TLS 1.3 MUST be enforced where the service supports it. Where TLS 1.3 is unavailable, the newest supported TLS version MUST be used.
- Outputs MUST NOT include secrets, passwords, or authentication keys.
- Customer Managed Keys (CMK) are outside the default foundation security model and MUST NOT be assumed to be supported unless explicitly implemented by the module.

### File Structure

Bicep files MUST follow this section order. Sections MAY be omitted when they are not needed, but the relative order of present sections MUST be preserved.

1. Metadata
2. Scope
3. Imports
4. Types
5. Functions
6. Parameters
7. Variables
8. Existing resources
9. Resources
10. Extensions
11. Outputs

Metadata MUST include the author block and module description.

Section headers in Bicep files MUST use block comments, such as `/* PARAMETERS */`.

Within each section, all declarations MUST be sorted alphabetically.

### Authoring Rules

- All declarations MUST be strongly typed.
- Parameters and outputs MUST be explicit and predictable.
- Module interfaces MUST represent the foundation contract rather than mirror the complete Azure resource API.
- Obsolete, legacy, insecure, or foundation-controlled properties SHOULD NOT be exposed as configurable parameters.
- A breaking interface change MAY be introduced when it produces a better foundation contract. Backward compatibility MUST NOT justify retaining an obsolete interface.

#### Types
- Type names MUST describe intent, such as `PropertiesInput`, `ResourceInput`, `Resource`, `ExtensionsInput`, or a scenario-specific name.
- Configurable property types SHOULD contain only properties that consumers are expected to control.
- Resource API types MAY be used internally without requiring the corresponding Azure API surface to be exposed through the module interface.

#### Parameters
- Every parameter MUST have a `@description` decorator.
- Standard parameter names MUST be used where applicable: `extensions`, `identity`, `location`, `name`, `properties`, `sku`, and `tags`.
- `properties` MUST represent the strongly typed, curated set of configurable resource properties.
- `extensions` MUST represent extension resources grouped by provider or concern, such as `Authorization`, `Insights`, `Maintenance`, or other.
- Optional parameters and default values MUST be safe and predictable.

#### Resources
- Resource names MUST be deterministic and MUST follow `<Provider>_<resourceType>_` or `<Provider>_<resourceType>_<nestedResourceType>_`.

#### Outputs
- Every output MUST have a `@description` decorator.
- Output names SHOULD be short and stable, usually `id`, `name`, `identity`, or narrowly scoped property names.
- Outputs SHOULD return precise values instead of broad resource objects.

## Compliance

All modules MUST comply with the rules defined in [bicepconfig.json](bicepconfig.json).

All modules MUST pass all configured checks at all times.

Rule suppressions MUST be scoped to the smallest possible line and MUST include a clear reason in a comment.

## Resources

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager API Versions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
