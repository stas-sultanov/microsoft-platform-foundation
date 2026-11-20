# Foundation Contract

This contract defines baseline requirements for every Foundation module that provisions one or more Azure or Entra resources.

The key words MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, MAY, and OPTIONAL are to be interpreted as described in RFC 2119 and RFC 8174. They are normative only when written in uppercase.

## General Requirements

- Modules MAY define additional module-specific requirements.
- Module-specific requirements MUST NOT weaken or contradict this contract.
- Modules MUST implement every applicable requirement in this contract and their documented module-specific requirements.

## Resource Settings and Validation

- Modules MUST NOT expose resource settings through open object types or properties typed as `any`.
- Modules MUST use the native `resourceInput` type when it represents a non-primitive type or already includes constraints from the resource schema, and its unmodified definition satisfies the module's required shape, allowed values, and constraints.
- Modules MUST use an explicit primitive or custom type, with applicable Bicep decorators, when no native `resourceInput` type exists or its unmodified definition does not satisfy the module's requirements.
- Modules MUST use Bicep types and decorators to express input constraints.
- Modules MUST use template validation for input constraints that Bicep types and decorators cannot express.
- Modules MUST reject inputs that violate this contract or their documented module-specific requirements.
- Modules MUST NOT expose properties or configurations that Microsoft documents as deprecated, retired, or unsupported.

## Resources and Extensions

- Modules MUST declare every resource they provision or configure.
- Modules in `resources` and `specs` whose primary resource type is a top-level Azure resource type MUST expose a required `extensions` parameter.
- For every resource a module provisions that supports diagnostic settings, except workspace-based `Microsoft.Insights/components`, the module MUST expose a diagnostic settings collection under that resource's own `extensions.Insights.diagnosticSettings` and MUST provision any settings provided in that collection for that resource. The collection MAY be empty.
- Modules that expose `extensions.Authorization.roleAssignments` MUST allow consumers to omit role assignments by omitting `extensions.Authorization` or the collection. The collection MAY be required when `Authorization` is supplied.
- Omitting `extensions.Authorization` or an optional `extensions.Authorization.roleAssignments` collection, or providing an empty `extensions.Authorization.roleAssignments` collection, MUST create no role assignments.

## Security Baseline

- Modules MUST use Entra ID exclusively for data-plane authorization where supported.
- For each resource that exposes a configurable minimum TLS version, modules MUST set it to the highest version supported by the selected service, SKU, and API version.
- When a security-relevant setting has a permissive service default, modules MUST either expose that setting as a required parameter or explicitly set it to a restrictive value.
- For each resource that supports `publicNetworkAccess`, modules MUST expose it as a required parameter.
- Firewall rules MUST be optional parameters.
- Modules MUST NOT enable firewall rules or trusted-service exceptions by default.
- Modules MUST use platform-managed keys by default for each resource that supports a configurable encryption key source.

## Outputs

- Where outputs are permitted by the [Authoring Rules](authoring-rules.md#outputs), modules MUST NOT output secrets, passwords, or authentication keys, except Entra application password credentials returned by Microsoft Graph during creation.
- Permitted secret outputs MUST be marked `@secure()`.

## Evolution and Compatibility

- The Foundation MUST NOT guarantee backward compatibility between versions.
- Consumers MUST treat every new Foundation version as potentially breaking.
