# Foundation Contract

All foundation modules MUST follow these architectural, security, and compatibility rules.

## Design Principles

- **Encode architectural intent.** Modules MUST encode architectural and security decisions beyond simply mirroring ARM/Bicep or AVM resource schemas. Native Azure resource API types MAY be reused where they represent the intended contract.
- **Exclude obsolete and unsafe options.** Modules MUST NOT expose deprecated APIs, legacy authentication, weak security modes, outdated SKUs, or unsupported configurations.
- **Use secure defaults.** Modules MUST configure identity, encryption, TLS, RBAC, and diagnostics correctly by default. Properties controlled by the foundation SHOULD NOT be configurable by consumers.
- **Enforce constraints and invariants.** Modules MUST add constraints and validation missing from native Bicep resource types, using strong types and template structure to prevent invalid configurations. For example, a SKU name typed as `string` MUST be restricted to an explicit set of supported values.
- **Avoid generic escape hatches.** Module interfaces MUST NOT expose arbitrary property bags, `additionalSettings`, or raw ARM passthrough that bypasses the contract.

## Security Baseline

- **Authentication.** Data-plane access MUST use Microsoft Entra ID-based authorization where the service supports it. In those services, legacy authorization models such as Key Vault access policies and key, shared-secret, or password authentication MUST NOT be used.
- **Transport.** TLS 1.3 MUST be enforced where supported; otherwise, the newest supported TLS version MUST be used.
- **Network access.** Public access, firewall rules, and trusted-service exceptions MUST be explicit in the module interface.
- **Encryption.** Platform-managed keys are the default. Customer-managed keys (CMK) MUST NOT be assumed to be supported unless explicitly implemented by the module.
- **Outputs.** Outputs MUST NOT include secrets, passwords, or authentication keys.

## Evolution and Compatibility

New revisions MAY introduce breaking changes when Azure capabilities, security guidance, or engineering practices improve. Backward compatibility MUST NOT preserve obsolete properties, legacy mechanisms, or outdated interfaces.

Projects requiring a stable dependency MAY pin a Git commit, tag, submodule revision, or immutable module artifact. Consumers are responsible for adapting their infrastructure code when adopting a newer foundation revision.
