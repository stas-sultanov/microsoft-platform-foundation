# Bicep Authoring Rules

All Bicep modules MUST follow the [Foundation Contract](foundation-contract.md) and these implementation rules.

## Declarations

- All declarations MUST be strongly typed.
- Parameters and outputs MUST be explicit and predictable.

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

Type names MUST describe the value they represent and follow these conventions:

- `Resource` MUST represent resource settings whose represented fields already have the intended Azure shape and can be used without translation or completion. Deployment context, such as `parent` or `scope`, MAY be supplied by the consuming module.
- Types representing child resource settings MUST put the child resource type name before `Resource`, such as `KeyValueResource`, `KeyResource`, or `NatRuleResource`.
- The `Input` suffix MUST be used only with `Resource` or `Properties`, optionally preceded by a resource or scenario name, such as `ResourceInput`, `LoadBalancingRuleResourceInput`, `PropertiesInput`, or `ConnectionPropertiesInput`. It MUST indicate consumer configuration that requires translation or completion before becoming the intended Azure resource settings or properties. Processing MAY occur in a helper function or directly in a resource declaration.
- Types whose represented fields already have the intended Azure shape MUST NOT gain the `Input` suffix merely because they are used as parameters or enforce stronger validation. Custom aliases for Azure-shaped properties MAY use `Properties` or `<Kind>Properties`; native resource-derived types SHOULD be preferred.
- Nested configuration, domain values, references, and union variants MUST use descriptive names without the `Input` suffix, such as `IpConfiguration`, `BgpSettings`, `IPSecPolicy`, `ResourceReference`, or `BgpWithFqdn`.

Configurable property types SHOULD contain only properties that consumers are expected to control when the module defines a curated property contract.

**One validation boundary per semantic invariant group.** Place `@validate()` on the narrowest supported parameter or property declaration that owns the related values, and combine related conditions into a single predicate. Bicep does not support `@validate()` directly on type declarations; when a reusable type needs validation, apply it at its usage sites.

Standard Bicep resource-derived types, such as `resourceInput` and `resourceOutput`, SHOULD be used wherever possible.

`settings.properties` MUST represent the Azure resource `properties` object. It MAY use `resourceInput<...>.properties` directly when the native Azure resource property shape is the intended contract, or a curated object type when the foundation intentionally exposes only selected properties.

Custom type properties MUST be documented with `@description` when the property purpose, constraints, or referenced Azure type are not already obvious from the native resource API type.

Boolean property descriptions MUST use the pattern `Specifies whether <subject> <condition>.` They MUST describe the boolean as a yes-or-no condition and MUST NOT use `whether or not`, `flag`, or imperative wording such as `Enable or disable`.

Azure resource ID property descriptions MUST use the pattern `The resource ID of the <provider/type> resource.` They MUST use the capitalization `ID` and identify the referenced Azure resource by its canonical Azure resource type. This rule applies only to Azure Resource Manager resource IDs, not Entra object IDs, subscription IDs, tenant IDs, application IDs, or other identifiers.

Azure resource ID parameters and properties MUST be validated with `@validate()` using the built-in `sys.like()` function against the canonical resource ID pattern, for example `'/subscriptions/*/resourceGroups/*/providers/Microsoft.OperationalInsights/workspaces/*'`. `sys.like()` is case-insensitive, which matches Azure resource ID semantics. The `*` wildcard also matches `/` and empty text, so this is a shape check that catches wrong resource types and malformed values early; it is not a strict parser. Optional values MUST pass when `null` (`value == null || sys.like(value!, ...)`). Reference objects validate their `id` (`sys.like(value.?id ?? '', ...)`), and arrays validate every element with `sys.filter()`. The error message SHOULD use the pattern `The value must be a <provider/type> resource ID.`, adapted for reference objects, arrays, or additional constraints.

## Parameters

Every parameter MUST have a `@description` decorator.

Top-level parameters MUST be sorted alphabetically by parameter name. Parent-name parameters MUST remain top-level and participate in this ordering alongside `extensions`, `resources`, and `settings`.

Optional parameters and default values MUST be safe and predictable.

Non-resource parameters SHOULD be avoided in `src/Azure/resources` and `src/Azure/specs` modules. When required, they MAY use domain-specific names only when they do not directly represent a standard Azure resource field, child resource collection, extension resource collection, or parent name.

## Module Interface Shape

The standard parameter surface, meaning `extensions`, `resources`, and `settings`, applies only to resource modules and child resource modules, meaning modules that create a single primary Azure resource. It MUST NOT be applied to modules that only provision extension resources for an existing resource, or to modules that provision multiple independent resources. Such modules MAY use domain-specific parameter names that describe what they provision.

Top-level resource modules, meaning modules that create a level 1 Azure resource type, MUST use the standard parameter surface: `extensions`, `resources`, and `settings`. The `resources` parameter is optional and MUST be omitted when the module does not create child resources.

Child resource modules MUST use `settings`; `extensions` is optional and MAY be omitted when the module does not provision extension resources. The `resources` parameter is optional and MUST be omitted when the module does not create child resources. Child resource modules MUST also expose the immediate parent resource name as a top-level `parentName` parameter. If more than one parent name is required, each parent name MUST be a top-level parameter with a clear name, such as `parentNamespaceName` and `parentTopicName`.

`extensions` MUST group extension resources by provider or concern, such as `Authorization`, `Insights`, `Maintenance`, or other. This includes diagnostics, authorization, assignments, and other resources scoped to the primary resource but not part of its child resource type hierarchy.

`resources` MUST group child resources by child resource type.

`settings` MUST group the configuration of the primary resource created by the module. Standard resource fields such as `identity`, `location`, `name`, `properties`, `sku`, `tags`, and `zones` MUST be nested under `settings` when applicable.

## Resource Declarations

Resource names MUST be deterministic and MUST follow the Azure resource type path converted to underscores, such as:

- `<Provider>_<resourceType>_`
- `<Provider>_<resourceType>_<childResourceType>_`
- `<Provider>_<resourceType>_<childResourceType>_<childResourceType>_`

Child resource type segments MAY continue as deeply as the Azure resource type requires.

Nested child resource declarations MAY use only the child resource type segment followed by an underscore, such as `blobServices_` or `containers_`, because the containing declaration supplies the provider and parent path. This also applies to nested `existing` resources. Top-level child resource declarations MUST use the full type-path naming convention above.

## API Versions

Every Azure resource type MUST use one API version consistently for its level 1 resource type.

`Sync-ApiVersions.ps1` derives that version from all Bicep files under `src`: the most recent preview version is preferred when one is present; otherwise, the most recent stable version is used.

This requirement applies consistently to every declaration, including resource modules, specifications, library and pattern modules, child resources, existing-resource references, and extension-resource references. A child resource or reference MUST use the same API version as its level 1 parent resource.

## Outputs

Modules under `src/Azure/resources` and `src/Azure/specs` MUST NOT declare outputs.

When consuming these modules, authors MUST declare the required resources as `existing` in the consuming Bicep file, using the deployed names and scopes. Each `existing` resource MUST include an explicit `dependsOn` entry for the module that deploys it. Consumers MUST read all required resource fields and properties through these references, not module outputs.

Required properties vary by consumer and cannot be predicted by the module author. Existing-resource references let consumers select exactly what they need without expanding the module interface; the explicit dependency ensures runtime property reads wait for the module deployment.

For module categories that permit outputs, the following rules apply.

Every output MUST have a `@description` decorator.

Resource output names SHOULD follow standard Azure resource field names where applicable, such as `id`, `name`, `type`, `location`, `identity`, `sku`, `tags`, and `properties`.

Values from the Azure resource `properties` object SHOULD be grouped under a `properties` output object instead of being expanded into many custom top-level output names.

Outputs SHOULD return precise values instead of broad resource objects.

## Validation

All modules MUST comply with the rules defined in [bicepconfig.json](../src/bicepconfig.json).

All modules MUST pass all configured checks at all times.

Rule suppressions MUST be scoped to the smallest possible line and MUST include a clear reason in a comment.
