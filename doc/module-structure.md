# Module Organization

This repository organizes Bicep modules by intent: reusable library code, reusable multi-resource patterns, canonical resource modules, scenario-specific specifications, and Microsoft Graph-driven Entra application artifacts.

## Module Types

| Area                     | Purpose                                                                      | Rules                                                                                                                                                                                                                                                    |
| ------------------------ | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/Azure/library`      | Shared types, functions, and constants                                       | MUST NOT contain resources.                                                                                                                                                                                                                              |
| `src/Azure/patterns`     | Reusable compositions that deploy and wire multiple resource types           | MUST own the relationship between the resources they compose.                                                                                                                                                                                            |
| `src/Azure/resources`    | Opinionated canonical deployment modules for one primary Azure resource type | MUST create the primary resource and MAY create its child resources and extension resources, such as diagnostics and authorization.                                                                                                                      |
| `src/Azure/specs`        | Scenario-specific specializations of one primary Azure resource type         | MUST create the primary resource specialization and MAY create its child resources and extension resources, such as diagnostics and authorization. MUST remain resource-specific and more constrained or opinionated than `src/Azure/resources` modules. |
| `src/Entra/applications` | Entra application artifacts managed through Microsoft Graph                  | MUST be used for Microsoft Graph-driven Entra application artifacts.                                                                                                                                                                                     |

## Path Conventions

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