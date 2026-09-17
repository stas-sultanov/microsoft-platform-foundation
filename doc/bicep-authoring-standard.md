# Bicep Authoring Standard

All modules in this repository MUST strictly follow this authoring standard.

This standard moves from the general foundation contract to specific Bicep authoring rules. Apply earlier sections as the governing intent for later implementation details.

## Authoring Principles

- All declarations MUST be strongly typed.
- Parameters and outputs MUST be explicit and predictable.
- Module interfaces MUST represent the foundation contract and MAY reuse native Azure resource API types when that is the intended contract.
- Obsolete, legacy, insecure, or foundation-controlled properties SHOULD NOT be exposed as configurable parameters.
- A breaking interface change MAY be introduced when it produces a better foundation contract. Backward compatibility MUST NOT justify retaining an obsolete interface.

## Security Baseline

- Data-plane access MUST use Microsoft Entra ID-based authorization where the service supports it.
- Legacy authorization models, such as Key Vault access policies, MUST NOT be used where Microsoft Entra ID-based authorization is supported.
- Keys, shared secrets, and passwords MUST NOT be used for data-plane access where Microsoft Entra ID-based authorization is supported.
- Public access, firewall rules, and trusted-service exceptions MUST be explicit in the module interface.
- TLS 1.3 MUST be enforced where the service supports it. Where TLS 1.3 is unavailable, the newest supported TLS version MUST be used.
- Outputs MUST NOT include secrets, passwords, or authentication keys.
- Customer Managed Keys (CMK) MUST NOT be assumed to be supported unless explicitly implemented by the module.

## File Structure

Bicep files MUST follow this section order. Sections MAY be omitted when they are not needed, but the relative order of present sections MUST be preserved.

- Metadata
- Scope
- Bicep extensions
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

The Bicep extensions section MUST contain `extension` statements, such as `extension microsoftGraph`, and MUST use the `/* BICEP EXTENSIONS */` header to avoid ambiguity with the Extensions section, which contains Azure extension resources.

Section headers after metadata declarations MUST use block comments, such as `/* PARAMETERS */`.

Within each section, all declarations MUST be sorted alphabetically.

## Function Namespaces

Calls to standard Bicep functions MUST be explicitly qualified with their namespace, such as `sys.map`, `sys.items`, `sys.guid`, or `az.resourceId`.

Unqualified standard function calls, such as `map(...)`, `items(...)`, `guid(...)`, or `resourceId(...)`, MUST NOT be used.

## Custom Types and Properties

Type names MUST describe intent, such as `PropertiesInput`, `ResourceInput`, `Resource`, `ExtensionsInput`, or a scenario-specific name.

Configurable property types SHOULD contain only properties that consumers are expected to control when the module defines a curated property contract.

Resource API types MAY be used in module interfaces or internally.

Standard Bicep resource-derived types, such as `resourceInput` and `resourceOutput`, SHOULD be used wherever possible.

`settings.properties` MUST represent the Azure resource `properties` object. It MAY use `resourceInput<...>.properties` directly when the native Azure resource property shape is the intended contract, or a curated object type when the foundation intentionally exposes only selected properties.

Custom type properties MUST be documented with `@description` when the property purpose, constraints, or referenced Azure type are not already obvious from the native resource API type.

Boolean property descriptions MUST use the pattern `Specifies whether <subject> <condition>.` They MUST describe the boolean as a yes-or-no condition and MUST NOT use `whether or not`, `flag`, or imperative wording such as `Enable or disable`.

Azure resource ID property descriptions MUST use the pattern `The resource ID of the <provider/type> resource.` They MUST use the capitalization `ID` and identify the referenced Azure resource by its canonical Azure resource type. This rule applies only to Azure Resource Manager resource IDs, not Entra object IDs, subscription IDs, tenant IDs, application IDs, or other identifiers.

## Parameters

Every parameter MUST have a `@description` decorator.

Top-level parameters MUST be sorted alphabetically by parameter name. Parent-name parameters MUST remain top-level and participate in this ordering alongside `extensions`, `resources`, and `settings`.

Optional parameters and default values MUST be safe and predictable.

Non-resource parameters SHOULD be avoided in `src/Azure/resources` and `src/Azure/specs` modules. When required, they MAY use domain-specific names only when they do not directly represent a standard Azure resource field, child resource collection, extension resource collection, or parent name.

## Module Interface Shape

The standard parameter surface, meaning `extensions`, `resources`, and `settings`, applies only to resource modules and child resource modules, meaning modules that create a single primary Azure resource. It MUST NOT be applied to modules that only provision extension resources for an existing resource, or to modules that provision multiple independent resources. Such modules MAY use domain-specific parameter names that describe what they provision.

Top-level resource modules, meaning modules that create a level 1 Azure resource type, MUST use the standard parameter surface: `extensions`, `resources`, and `settings`. The `resources` parameter is optional and MUST be omitted when the module does not create child resources.

Child resource modules MUST use the same standard parameter surface and MUST also expose the immediate parent resource name as a top-level `parentName` parameter. If more than one parent name is required, each parent name MUST be a top-level parameter with a clear name, such as `parentNamespaceName` and `parentTopicName`.

`extensions` MUST group extension resources by provider or concern, such as `Authorization`, `Insights`, `Maintenance`, or other. This includes diagnostics, authorization, assignments, and other resources scoped to the primary resource but not part of its child resource type hierarchy.

`resources` MUST group child resources by child resource type.

`settings` MUST group the configuration of the primary resource created by the module. Standard resource fields such as `identity`, `location`, `name`, `properties`, `sku`, `tags`, and `zones` MUST be nested under `settings` when applicable.

## Resource Declarations

Resource names MUST be deterministic and MUST follow the Azure resource type path converted to underscores, such as:

- `<Provider>_<resourceType>_`
- `<Provider>_<resourceType>_<childResourceType>_`
- `<Provider>_<resourceType>_<childResourceType>_<childResourceType>_`

Child resource type segments MAY continue as deeply as the Azure resource type requires.

## API Versions

Every Azure resource type MUST use one API version consistently for its level 1 resource type.

`Sync-ApiVersions.ps1` derives that version from all Bicep files under `src`: the most recent preview version is preferred when one is present; otherwise, the most recent stable version is used.

This requirement applies consistently to every declaration, including resource modules, specifications, library and pattern modules, child resources, existing-resource references, and extension-resource references. A child resource or reference MUST use the same API version as its level 1 parent resource.

## Outputs

Every output MUST have a `@description` decorator.

Resource output names SHOULD follow standard Azure resource field names where applicable, such as `id`, `name`, `type`, `location`, `identity`, `sku`, `tags`, and `properties`.

Values from the Azure resource `properties` object SHOULD be grouped under a `properties` output object instead of being expanded into many custom top-level output names.

Outputs SHOULD return precise values instead of broad resource objects.

## Validation

All modules MUST comply with the rules defined in [bicepconfig.json](../src/bicepconfig.json).

All modules MUST pass all configured checks at all times.

Rule suppressions MUST be scoped to the smallest possible line and MUST include a clear reason in a comment.