# Microsoft Platform Foundation

Foundation for building secure and reliable IT solutions on top of Microsoft Azure and Microsoft Entra ID.

Created by [Stas Sultanov](https://www.linkedin.com/in/stas-sultanov)

## About

Microsoft Platform Foundation is a Bicep module library for assembling Azure infrastructure templates faster and with stronger defaults.

It provides reusable building blocks for Azure resources, opinionated specifications for specific purposes, and larger deployment patterns. The modules are designed to reduce duplication, maintain strongly typed interfaces, enforce Entra ID authentication and RBAC authorization, and make infrastructure templates easier to review, compose, and evolve.

## Layout

This section describes where content lives in the repository.

```bash
./
├─ Azure/
│  ├─ library/       # Shared types, functions, and constants
│  ├─ patterns/      # Multi-resource composition modules
│  ├─ resources/     # Reusable single-primary-resource modules with extensions
│  └─ specs/         # Single-primary-resource modules with settings for specific purposes
├─ Entra/
│  └─ applications/  # Microsoft Graph modules for Entra applications
├─ bicepconfig.json  # Bicep analyzer and linting configuration
├─ readme.md         # Repository guidance
└─ license.md        # License information
```

## Taxonomy

The module location MUST match the module intent.

| Area                 | Purpose | Rules 
|----------------------|---------|-------
| `Azure/library`      | Shared types, functions, and constants | MUST NOT contain resources.
| `Azure/patterns`     | Reusable compositions that deploy and wire multiple resource types | MUST own the relationship between the resources they compose.
| `Azure/resources`    | Reusable modules for one primary Azure resource type | MAY deploy extension resources scoped to the primary resource.
| `Azure/specs`        | Reusable modules for one primary Azure resource type with settings for a specific purpose | MUST remain resource-specific and MUST be more opinionated than `Azure/resources` modules.
| `Entra/applications` | Entra application artifacts managed through Microsoft Graph |

## Conventions

This section defines conventions that MUST be strictly followed by all modules within this repository.

### General Guidance

- Modules MUST be focused on one clear responsibility.
- Module interfaces MUST be strongly typed.
- Parameters and outputs MUST be explicit and predictable.
- Existing exported types and functions from `Azure/library` SHOULD be reused when they fit the module intent.
- Entra ID authentication and Azure RBAC authorization MUST be used where Azure supports them.
- Key-based access patterns MUST NOT be used.
- Secrets, connection strings, passwords, and authentication keys MUST NOT be returned in outputs.
- Generated and environment-specific files MUST NOT be committed.
- Repository conventions and implementation MUST stay aligned. When they conflict, the implementation or this file MUST be updated.

### Path Conventions

- `Azure/library/<Provider>/<name>.bicep`
- `Azure/patterns/<Domain>/<Name>.bicep`
- `Azure/patterns/<Domain>/<SubDomain>/<Name>.bicep`
- `Azure/resources/<Provider>/<resourceType>/main.bicep`
- `Azure/resources/<Provider>/<resourceType>/<nestedResourceType>/main.bicep`
- `Azure/specs/<Provider>/<resourceType>/<Name>.bicep`
- `Azure/specs/<Provider>/<resourceType>/<nestedResourceType>/<Name>.bicep`
- `Entra/applications/<Name>.bicep`

Provider and resource type names MUST match Azure resource type casing where practical. Case-only path differences MUST be avoided because they are fragile across operating systems.

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

Metadata MUST include the author block and module description. Metadata SHOULD be short and stable.

Section headers in Bicep files MUST use block comments, such as `/* PARAMETERS */`.

### Sorting

Declarations MUST be sorted alphabetically.

Alphabetical ordering applies to:

- imports;
- object properties;
- outputs;
- parameters;
- resource and module declarations;
- type properties;
- variables.

### Naming

Names MUST be predictable so modules are easy to scan and compare.

- Standard parameter names MUST be used where applicable: `name`, `location`, `identity`, `properties`, `sku`, `tags`, and `extensions`.
- `properties` MUST represent strongly typed configurable resource properties.
- `extensions` MUST represent extension resources grouped by provider or concern, such as `Authorization`, `Insights`, or `Maintenance`.
- Resource symbols MUST be deterministic and MUST follow `<Provider>_<resourceType>_` or `<Provider>_<resourceType>_<nestedResourceType>_`.
- Type names MUST describe intent, such as `PropertiesInput`, `ResourceInput`, `Resource`, `ExtensionsInput`, or a scenario-specific name.
- Output names SHOULD be short and stable, usually `id`, `name`, `identity`, or narrowly scoped property names.

### Parameters and Outputs

- Every parameter MUST have a `@description` decorator.
- Every output MUST have a `@description` decorator.
- Outputs SHOULD return precise values instead of broad resource objects.
- Optional parameters and default values MUST be safe and predictable.
- `utcNow()` defaults MUST NOT be used in reusable modules unless non-repeatable deployments are intentional and documented.

### Extension Resources

Resource modules MAY deploy extension resources when those extensions are scoped to the primary resource deployed by the module.

Common extension groups:

- `Authorization`: role assignments scoped to the primary resource.
- `Insights`: diagnostic settings or data collection rule associations.
- `Maintenance`: maintenance configuration assignments.

Authorization extensions MUST represent inbound permissions on the primary resource. Cross-resource, cross-scope, staged, or circular dependency scenarios SHOULD be implemented in `Azure/specs/Authorization` or `Azure/patterns`.

Diagnostic settings MAY be provisioned through `Insights` extensions when a resource supports streaming logs or metrics to Log Analytics or another supported destination.

### Security Defaults

- Entra ID authentication MUST be used where Azure supports it.
- RBAC authorization MUST be used where Azure supports it.
- Keys, shared secrets, and connection strings MUST NOT be used for resource access.
- Public access, firewall rules, and trusted-service exceptions MUST be explicit in the module interface.
- Latest version of TLS must be used.
- Outputs MAY include stable identifiers needed by consumers, but MUST NOT include secrets.

### Bicep Configuration

[bicepconfig.json](bicepconfig.json) is the source of truth for Bicep analyzer configuration.

Modules MUST pass the configured checks when Bicep tooling is available. Rule suppressions MUST be scoped to the smallest possible line and MUST include a clear reason in a comment.

## Resources

- [Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Resource Manager API Versions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers)
- [Bicep Best Practices](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)

## License

See [license.md](license.md) for license information.
