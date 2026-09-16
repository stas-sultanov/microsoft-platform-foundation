# Foundation Contract

Microsoft Platform Foundation is designed to enforce a small, current, and opinionated contract for Azure and Microsoft Entra ID infrastructure modules.

## Scope

The foundation is intentionally **not** a complete abstraction of Azure Resource Manager and is not intended to expose every capability, compatibility option, or historical property available in Azure APIs.

Instead, it exposes the practices and capabilities considered appropriate for the majority of solutions that build on Azure and Microsoft Entra ID. When Azure provides multiple ways to achieve the same result, modules SHOULD expose the preferred foundation mechanism. Where no additional foundation opinion is required, modules MAY use native Azure resource API types directly.

## Design Principles

- **Opinionated by design.** Modules MUST encode architectural and security decisions instead of acting as thin wrappers around Azure resource APIs.
- **Modern authentication.** Microsoft Entra ID-based authorization MUST be used as the data-plane authentication model wherever the Azure service supports it.
- **Modern security baseline.** Legacy authentication mechanisms, obsolete configuration options, and weaker security modes MUST NOT be exposed to module consumers.
- **Modern transport security.** TLS 1.3 MUST be used wherever the Azure service supports it.
- **Pragmatic configuration.** Modules SHOULD curate properties when the foundation owns a decision and MAY reuse native Azure resource API types when the Azure resource shape is the intended configuration surface.
- **Strong typing.** Module interfaces MUST make invalid or undesirable configurations difficult or impossible to express.
- **Secure defaults are implementation decisions.** Consumers SHOULD configure business and workload requirements rather than repeatedly making low-level platform security decisions.
- **Platform-managed keys by default.** Modules are designed for the common case where platform-managed encryption keys are sufficient.

## Evolution and Compatibility

Microsoft Platform Foundation is an evolving engineering foundation, not a backward-compatible package ecosystem.

Azure evolves, security guidance evolves, and engineering practices evolve. The foundation is expected to evolve with them. This can intentionally introduce breaking changes to module interfaces when a better implementation, safer Azure capability, or clearer abstraction becomes available.

Backward compatibility MUST NOT be preserved solely to keep obsolete properties, legacy mechanisms, or historical module interfaces working.

Consumers are expected to adapt their infrastructure code when adopting a newer revision of the foundation.

Projects that require a stable dependency MAY pin the foundation to a Git commit, tag, Git submodule revision, or an immutable module artifact. Updating that reference is an explicit adoption of the newer foundation contract and MAY require changes in the consuming project.

This model favors a small, current, maintainable configuration surface over accumulating deprecated compatibility layers.