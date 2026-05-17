# Microsoft Platform Foundation

A foundation for building secure and reliable IT solutions on Microsoft Azure and Microsoft Entra ID.

Created by [Stas Sultanov](https://www.linkedin.com/in/stas-sultanov)

## About

A Bicep module library that provides reusable building blocks, purpose-specific specs, and composition patterns for building secure and reliable solutions on Microsoft Azure and Microsoft Entra ID.

## Table of Contents

- [Layout](#layout)
- [Conventions](#conventions)
  - [Module Types](#module-types)
  - [Path Conventions](#path-conventions)
  - [Security](#security)
  - [File Structure](#file-structure)
  - [Authoring Rules](#authoring-rules)
  - [Bicep Configuration](#bicep-configuration)
- [Resources](#resources)
- [License](#license)

## Layout

Repository layout.

```bash
./
├─ Azure/
│  ├─ library/       # Shared types, functions, and constants
│  ├─ patterns/      # Composition modules that wire multiple resources
│  ├─ resources/     # Modules for one primary resource with extensions
│  └─ specs/         # Modules for one primary resource with a specific purpose
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
| `Azure/resources`    | Reusable modules for one primary Azure resource type | MAY deploy extension resources scoped to the primary resource. |
| `Azure/specs`        | Reusable modules for one primary Azure resource type with settings for a specific purpose | MUST remain resource-specific and MUST be more opinionated than `Azure/resources` modules. |
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
- The latest available version of TLS MUST be enforced when the service supports that configuration.
- Outputs MUST NOT include secrets, passwords, or authentication keys.

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

#### Types
- Type names MUST describe intent, such as `PropertiesInput`, `ResourceInput`, `Resource`, `ExtensionsInput`, or a scenario-specific name.

#### Parameters
- Every parameter MUST have a `@description` decorator.
- Standard parameter names MUST be used where applicable: `extensions`, `identity`, `location`, `name`, `properties`, `sku`, and `tags`.
- `properties` MUST represent strongly typed configurable resource properties.
- `extensions` MUST represent extension resources grouped by provider or concern, such as `Authorization`, `Insights`, or `Maintenance`.
- Optional parameters and default values MUST be safe and predictable.

#### Resources
- Resource names MUST be deterministic and MUST follow `<Provider>_<resourceType>_` or `<Provider>_<resourceType>_<nestedResourceType>_`.

#### Outputs
- Every output MUST have a `@description` decorator.
- Output names SHOULD be short and stable, usually `id`, `name`, `identity`, or narrowly scoped property names.
- Outputs SHOULD return precise values instead of broad resource objects.

### Bicep Configuration

[bicepconfig.json](bicepconfig.json) is the source of truth for Bicep analyzer configuration.

Modules MUST pass the configured checks when Bicep tooling is available.

Rule suppressions MUST be scoped to the smallest possible line and MUST include a clear reason in a comment.

## Resources

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager API Versions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)

## License

See [license.md](license.md) for license information.
