# Bicep Authoring Rules

All Bicep modules MUST follow the [Foundation Contract](foundation-contract.md) and these rules.

The Foundation Contract owns architectural and security policy; this file owns Bicep implementation conventions; [bicepconfig.json](../src/bicepconfig.json) owns automated compiler, linter, and formatter settings.

## Structure

- Declarations MUST be strongly typed.
- Sections MUST follow this order: Metadata, Scope, Bicep extensions, Imports, Types, Functions, Parameters, Variables, Existing resources, Resources, Extensions, Outputs.
- Unused sections MAY be omitted.
- Metadata MUST NOT have a section header.
- Metadata MUST include the author block and module description.
- Subsequent section headers MUST use block comments, such as `/* PARAMETERS */`.
- `extension` statements MUST appear under `/* BICEP EXTENSIONS */`.
- Azure extension resources MUST appear under `/* EXTENSIONS */`.
- Declarations within each section MUST be sorted alphabetically by declared name.
- Standard function calls MUST be namespace-qualified, such as `sys.map` or `az.resourceId`.
- Imports MUST use `import * as <Namespace> from '<path>'`.
- Imported symbols MUST be accessed through their import namespace, such as `Common.ResourceReference` or `AuthorizationRoleAssignments.CreateArray`.

## Types

- Type names MUST describe their values.
- `Resource` MUST represent Azure-shaped resource settings requiring no translation or completion.
- Consumers of `Resource` types MAY supply deployment context such as `parent` or `scope`.
- Types representing complete Azure-shaped child resource settings MUST use `<ChildResourceType>Resource`, such as `KeyValueResource`.
- `Input` MUST suffix only `Resource` or `Properties`, optionally prefixed by a resource/scenario name.
- `Input` MUST indicate required translation or completion in a helper or resource declaration.
- Types representing only Azure-shaped properties MAY use `Properties` or `<Kind>Properties`, such as `KeyValueProperties`.
- Nested configuration, domain values, references, and union variants MUST NOT use the `Input` suffix.
- Native resource-derived types, such as `resourceInput` and `resourceOutput`, SHOULD be preferred.
- Explicit object types declaring only named properties MUST use `@sealed()` at every nesting level, including empty objects, array items, union variants, dictionary values, and permitted outputs.
- Array items MUST use named sealed types where inline decoration is unsupported.
- Dictionary types using `*:` MUST remain open; their explicitly declared object value types MUST follow the same sealing rules.
- Resource-derived types MUST remain unchanged by sealing.

## Descriptions and Constraints

- Boolean descriptions MUST use `Specifies whether <subject> <condition>.`.
- Boolean descriptions MUST NOT use `whether or not`, `flag`, or imperative wording.
- ARM resource ID property descriptions MUST use `The ID of the <provider/type> resource.` with canonical resource types; non-resource identifiers such as Entra object, subscription, tenant, and application IDs are excluded.
- `@validate()` MUST target the narrowest supported parameter/property owning each semantic invariant group.
- Conditions within the same semantic invariant group MUST be combined in one predicate.
- Validation required by reusable types MUST be applied at usage sites; type declarations do not support `@validate()`.
- ARM resource ID parameters/properties MUST use `@validate()` with case-insensitive `sys.like()` and a canonical pattern, such as `/subscriptions/*/resourceGroups/*/providers/Microsoft.OperationalInsights/workspaces/*` (shape check only: `*` also matches `/` and empty text).
- Optional ARM resource IDs MUST accept null: `value == null || sys.like(value!, pattern)`.
- ARM resource reference objects MUST validate `id`: `sys.like(value.?id ?? '', pattern)`.
- ARM resource ID arrays MUST validate every element using `sys.filter()`.
- ID validation errors SHOULD follow `The value must be a <provider/type> resource ID.`, adapted for collections or additional constraints.

## Module Interface

- The following standard-interface rules apply only to modules creating one primary resource, excluding extension-only and multi-independent-resource modules.
- Extension-only and multi-independent-resource modules MAY use domain-specific parameters.
- Single-primary-resource modules MUST expose `settings`.
- Level-1 resource modules MUST expose `extensions`.
- Child resource modules MUST expose `extensions` if and only if they provision extension resources.
- Single-primary-resource modules MUST expose `resources` if and only if they create child resources.
- Child resource modules MUST expose immediate parent names as top-level parameters: `parentName`, or explicit names such as `parentNamespaceName` and `parentTopicName` when multiple are required.
- `extensions` MUST group scoped non-child resources by provider/concern, such as `Authorization`, `Insights`, or `Maintenance`.
- `resources` MUST be an object that groups child resource collections by child resource type, including when the module creates only one child resource type.
- Each property in `resources` MUST use the child resource type segment as its name and contain an array of the corresponding `<ChildResourceType>Resource` type.
- `resources` objects MUST be inline parameter object types so sensitive collections can be marked `@secure()` when needed; `@secure()` MUST be applied to the entire `resources` parameter when any child resource value is sensitive.
- `settings` MUST contain primary-resource configuration, including applicable `identity`, `location`, `name`, `properties`, `sku`, `tags`, and `zones`.
- `settings.properties` MUST represent Azure resource `properties`, using either its native resource-derived type or an intentionally curated subset.

## Parameter Defaults and Exceptions

- Default values MUST satisfy the Foundation Contract and the parameter's declared constraints.
- Single-primary-resource modules under `src/Azure/resources` and `src/Azure/specs` SHOULD avoid parameters outside the standard interface and required parent names.
- Additional domain-specific parameters in those modules MUST NOT replace standard resource fields, child/extension collections, or parent names.

## Resources and API Versions

- Resource symbolic names MUST be deterministic.
- Top-level resource symbolic names MUST follow `<Provider>_<resourceType>_<childResourceType>_`, including all applicable child segments.
- `<Provider>` MUST be the Azure provider namespace without `Microsoft.`, such as `Network` for `Microsoft.Network`.
- Resource type segments in symbolic names MUST preserve their API spelling, such as `virtualNetworks` and `subnets`.
- A declaration MAY append `__<Qualifier>` after the type-path name to distinguish declarations of the same type or to name a fixed singleton, such as `Sql_servers_databases__Master`; the qualifier MUST be deterministic and describe the instance.
- Nested child declarations, including nested `existing` resources, MAY use only the child segment plus `_`, such as `containers_`.
- Nested child declarations not using the short form MUST use the full type-path naming convention.
- An API-version family consists of one provider's top-level resource type and its descendants, such as `Microsoft.Network/virtualNetworks` and `Microsoft.Network/virtualNetworks/subnets`.
- Each API-version family MUST use one API version across all declarations and references, including children, existing resources, extensions, libraries, patterns, and specs.
- [Sync-ApiVersions.ps1](../tools/Sync-ApiVersions.ps1) selects that version from `src`: newest preview if present; otherwise newest stable.
- Preview preference MAY justify a `use-recent-api-versions` suppression under the Verification rules.

## Outputs

- Modules under `src/Azure/resources` and `src/Azure/specs` MUST NOT declare outputs.
- Consumers MUST access these modules' deployed resources through `existing` declarations with deployed names/scopes, not module outputs.
- Each `existing` declaration referencing a resource deployed by a module MUST explicitly depend on that module through `dependsOn`.
- Where outputs are permitted, names SHOULD follow standard resource fields.
- Where outputs are permitted, Azure `properties` values SHOULD be grouped under `properties`.
- Where outputs are permitted, they SHOULD return precise values rather than broad resource objects.

## Verification

- Modules MUST pass all configured [bicepconfig.json](../src/bicepconfig.json) checks.
- Affected consumers are Bicep files that directly or transitively import a changed exported type/function/variable or reference a changed module interface.
- Compile changed/new files and affected consumers with [Bicep-Build.ps1](../tools/Bicep-Build.ps1) `-Files` (PowerShell string array, paths relative to `SourceRoot`, which defaults to `src`).
- Omit `-Files` only for a full build.
- Rule suppressions MUST target the smallest possible line.
- Rule suppressions MUST include a clear reason in a comment.
- Linter suppressions MUST NOT authorize capabilities prohibited by the Foundation Contract.
