# Authoring Rules

This document defines Bicep authoring requirements. The [Foundation Contract](foundation-contract.md) defines architectural and security requirements. [bicepconfig.json](../src/bicepconfig.json) defines automated compiler, linter, and formatter settings.

The key words MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY, and OPTIONAL are to be interpreted as described in RFC 2119 and RFC 8174. They are normative only when written in uppercase.

All Bicep modules MUST follow the Foundation Contract and these rules.

## File Structure

- Sections MUST appear in this order: Metadata, Scope, Bicep extensions, Imports, Types, Functions, Parameters, Variables, Existing resources, Resources, Extensions, Outputs.
- Files MAY omit sections that contain no declarations.
- Metadata MUST have no section header and MUST include the author block and module description.
- Spec descriptions MUST be multiline strings. Their first line MUST start with `Provisions <resource or resource set> for <scenario or purpose>.`
- Spec descriptions MUST include a `Decisions:` list after a blank line when the spec imposes a default, restriction, dependency, or consumer responsibility not represented by its parameters.
- Each decision MUST be a `- ` bullet describing spec-specific behavior, constraints, dependencies, or consumer responsibilities.
- Decision bullets MUST NOT list parameter values or repeat requirements from the Foundation Contract.
- Section headers after Metadata MUST use block comments, such as `/* PARAMETERS */`.
- Bicep `extension` statements MUST appear in the `BICEP EXTENSIONS` section.
- Azure extension resources MUST appear in the `EXTENSIONS` section.
- Declarations MUST be sorted alphabetically by declared name within each section.
- Built-in function calls MUST use their namespace, such as `sys.map` or `az.resourceId`.
- Imports MUST use `import * as <Namespace> from '<path>'`. Imported symbols MUST be accessed through that namespace.

## Types

### Names

- A type named `Resource` MUST represent Azure-shaped resource settings that require no translation or completion.
- Complete Azure-shaped child resource settings MUST use the `<ChildResourceType>Resource` name.
- Types named with the `Input` suffix MUST represent values that require translation or completion in a helper or resource declaration.
- The `Input` suffix MUST follow `Resource` or `Properties`, optionally preceded by a resource or scenario name.
- Types representing only Azure-shaped properties MAY use `Properties` or `<Kind>Properties`.
- Types for nested configuration, domain values, references, or union variants MUST NOT end in `Input`.

### Definitions

- Parameters and user-defined object properties MUST declare explicit types other than `any`.
- Consumers of `Resource` types MAY supply deployment context such as `parent` or `scope`.
- Native resource-derived types MUST NOT use `@sealed()`.
- Object types that declare only named properties MUST use `@sealed()` at every nesting level, including nested object types used as map values.
- Array items with object types MUST use a named type when Bicep does not support inline `@sealed()`.
- Object types that use `*:` to declare maps MUST remain open.

## Descriptions

- Boolean descriptions MUST start with `Specifies whether <subject> <condition>.`
- Boolean descriptions MUST NOT contain `whether or not`, `flag`, or imperative instructions.
- Descriptions for Azure resource ID properties MUST use `The ID of the <provider/type> resource.` with the canonical Azure resource type.
- Properties containing Entra object, subscription, tenant, or application IDs MUST NOT use the Azure resource ID description template.

## Constraints

- `@validate()` MUST target the parameter or property that owns the invariant.
- Conditions for one invariant MUST be combined in one predicate.
- A constraint intrinsic to a user-defined type property MUST decorate that property. A type declaration MUST NOT use `@validate()` for that constraint.

### Validation Messages

- Validation messages MUST use declarative English, start with an uppercase letter or a case-sensitive identifier, and end with a period.
- Each validation message MUST use the applicable template below. An unlisted constraint MUST use `<subject> must <constraint>.` or `<subject> must not <constraint>.`
- Validation messages MUST NOT use the imperative verbs `Supply` or `Provide`, or the phrases `requires`, `is required`, `cannot`, or `does not support`.
- Validation messages MUST use declared property names or terms defined by the module interface.
- String literal values in validation messages MUST be enclosed in double quotes.
- Equivalent constraints MUST use the same template, with changes only to subjects, values, conditions, and collection scope.

  | Constraint              | Template                                                          |
  | ----------------------- | ----------------------------------------------------------------- |
  | Exactly one specified   | `Exactly one of x or y must be specified.`                        |
  | At most one specified   | `At most one of x or y may be specified.`                         |
  | At least one specified  | `At least one of x or y must be specified.`                       |
  | At most one enabled     | `At most one of x or y may be true.` (use `enabled` for policies) |
  | Required dependency     | `x must be specified when y is true.`                             |
  | Conditional value       | `x must be <value> when <condition>.`                             |
  | Conditional prohibition | `x must not be specified when <condition>.`                       |
  | Allowed values          | `<subject> must be <value1> or <value2>.`                         |
  | Uniqueness              | `<subject> must be unique <scope>.`                               |
  | Format or range         | `<subject> must <format or range constraint>.`                    |

- Lists of three or more alternatives MUST use `x, y, or z`.
- Messages for combined predicates MUST describe every condition.
- Validation messages MUST preserve the predicate's meaning, including exactly one versus at most one, specified versus nonempty, and specified versus true or enabled.
- Validation messages MUST state additional requirements such as nonempty, pinned, or complete.

## Module Interface

- For modules under `src/Azure/resources` and `src/Azure/specs`, the resource type in the module path MUST be the primary resource type.
- Modules with exactly one primary resource MUST use the standard interface below.
- Modules without exactly one primary resource MAY use domain-specific parameters.
- Single-primary-resource modules MUST expose `settings`.
- Modules whose primary resource is a child resource type MUST expose `extensions` if and only if they provision extension resources.
- Single-primary-resource modules MUST expose `resources` if and only if they provision child resources.
- Modules whose primary resource is a child resource type MUST expose the names of all required ancestors as top-level parameters. A single ancestor name MUST use `parentName`. Multiple ancestor names MUST use `parent<ResourceType>Name`, such as `parentNamespaceName` and `parentTopicName`.
- The `extensions` object MUST group scoped non-child resources by provider or concern, such as `Authorization`, `Insights`, or `Maintenance`.
- The `resources` parameter MUST be an inline object with one array property for each child resource type. Each property MUST use the child resource type segment as its name and the corresponding `<ChildResourceType>Resource` type as its item type.
- The `resources` parameter MUST use `@secure()` when any child resource value is sensitive.
- When the primary resource supports them, `settings` MUST expose `identity`, `location`, `name`, `properties`, `sku`, `tags`, and `zones` under those Azure field names.
- When the primary resource has an Azure `properties` object, `settings.properties` MUST represent it using its resource-derived type or an explicitly declared subset.
- Single-primary-resource modules under `src/Azure/resources` and `src/Azure/specs` MAY expose domain-specific parameters only when they do not replace standard resource fields, child or extension collections, or required parent names.
- Parameter default values MUST satisfy the Foundation Contract and the parameter's declared constraints.

## Resources and API Versions

- Resource declarations at the file's top level MUST use symbolic names in the form `<Provider>_<resourceType>_<childResourceType>...<InstanceSuffix>`, including every applicable child type segment.
- `<Provider>` MUST be the Azure provider namespace without `Microsoft.`, such as `Network` for `Microsoft.Network`.
- Resource type segments in symbolic names MUST preserve the casing in the Azure resource type, such as `virtualNetworks` and `subnets`.
- `<InstanceSuffix>` MUST be `_` or `__<Name>`. `<Name>` MUST be deterministic and identify the resource instance.
- Nested child resource declarations, including `existing` declarations, MAY use `<childResourceType><InstanceSuffix>`, such as `containers_` or `containers__Default`. Other declarations MUST use the full type-path naming form.
- A resource type and all its descendants under the same provider MUST use one API version across declarations and references.
- API versions MUST match the versions selected by [Sync-ApiVersions.ps1](../tools/Sync-ApiVersions.ps1): the newest preview in `src` when one exists, otherwise the newest stable version.

## Outputs

- Modules under `src/Azure/resources` and `src/Azure/specs` MUST NOT declare outputs.
- Consumers MUST access resources deployed by these modules through `existing` declarations using the deployed names and scopes.
- Each `existing` declaration that references a resource deployed by a module MUST depend on that module through `dependsOn`.
- Where outputs are permitted, modules MUST NOT output complete Azure resource objects.
- Output names MUST match the Azure resource field names they represent.
- Azure resource `properties` outputs MUST be grouped under `properties`.

## Verification

- Modules MUST pass all checks configured in [bicepconfig.json](../src/bicepconfig.json).
- A targeted build MUST include changed files and every Bicep file that directly or transitively imports a changed exported type, function, or variable, or references a changed module interface.
- Targeted builds MUST use [Build.ps1](../tools/Build.ps1) with `-Files` as a PowerShell string array of paths relative to `SourceRoot`, whose default value is `src`.
- Full builds MUST omit `-Files`.
- Rule suppressions MUST cover only the Bicep lines that trigger the rule.
- Each suppression comment MUST name the suppressed rule and state why the suppression is necessary.
- Linter suppressions MUST NOT authorize capabilities prohibited by the Foundation Contract.
- A `use-recent-api-versions` suppression MAY be used when the selected API version is preview and the linter reports that version.
