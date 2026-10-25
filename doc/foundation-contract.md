# Foundation Contract

All foundation modules MUST follow these architectural, security, and compatibility rules.

## Design Principles

- Modules MUST encode architectural and security decisions beyond simply mirroring ARM/Bicep or AVM resource schemas.
- Modules MUST NOT expose SKUs or configurations that Microsoft documents as deprecated, retired, or unsupported.
- Modules MUST NOT expose security modes prohibited by this contract or Microsoft's service-specific security recommendations.
- Module interfaces MUST NOT expose additional Azure capabilities unless explicitly requested or required by this contract.
- Modules MUST add constraints and validation missing from native Bicep resource types, using strong types and template structure to prevent invalid configurations.
- SKU names MUST use explicit allowlists unless valid names depend on deployment context and cannot be represented reliably by a fixed list.
- Module interfaces MUST NOT expose arbitrary property bags, `additionalSettings`, or raw ARM passthrough that bypasses the contract.

## Security Baseline

- When supported by the selected service, SKU, and API version, Microsoft Entra ID data-plane authorization MUST be enabled and all non-Entra data-plane authorization methods MUST be disabled.
- Modules MUST enforce the highest minimum TLS version configurable for the selected service, SKU, and API version.
- Modules whose resources support `publicNetworkAccess` MUST expose it as a required consumer setting without a module-supplied default.
- Firewall rules and trusted-service exceptions SHOULD be optional consumer settings.
- Encryption MUST default to platform-managed keys.
- Where outputs are otherwise permitted by the [Bicep Authoring Rules](bicep-authoring-rules.md#outputs), they MUST NOT include secrets, passwords, or authentication keys, except generated Entra application password credentials returned by Microsoft Graph only at creation.
- Permitted secret outputs MUST be marked `@secure()`.

## Evolution and Compatibility

- New revisions MAY introduce breaking changes when Azure capabilities, security guidance, or engineering practices improve.
- Backward compatibility MUST NOT override this contract.
- Projects requiring a stable dependency MAY pin a Git commit, tag, submodule revision, or immutable module artifact.
- Consumers MUST adapt their infrastructure code when adopting a revision that changes the contracts they use.
