# Microsoft Platform Foundation

[![CodeQL](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/github-code-scanning/codeql/badge.svg)][github_workflow_code_ql]
[![Check](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/check.yml/badge.svg)][github_workflow_check]
[![Release](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/release.yml/badge.svg)][github_workflow_release]

An opinionated Bicep module library for secure, reliable infrastructure on Microsoft Azure and Microsoft Entra ID.

Authored and maintained by [Stas Sultanov][linked_in_profile].

[Support the author](#support-the-author), if this library benefits your business.

## Bicep Version

The foundation depends directly on Bicep, is tied to its version, and is updated with every new Bicep release.

Bicep CLI version: [0.47.16](https://github.com/Azure/bicep/releases/tag/v0.47.16).

## Documentation

- [Foundation Contract](doc/foundation-contract.md): design principles, security, and compatibility.
- [Module Structure](doc/module-structure.md): module categories and paths.
- [Bicep Authoring Rules](doc/bicep-authoring-rules.md): Bicep implementation conventions.

## Tooling

- [Build](tools/Bicep-Build.ps1) — compile Bicep files under `src`.
- [Format](tools/Bicep-Format.ps1) — format Bicep files under `src`.
- [Sync API versions](tools/Sync-ApiVersions.ps1) — verify or align resource API versions across `src`.
- [Publish](tools/Bicep-Publish.ps1) — publish Bicep files under `src` to an OCI registry.

## Support the Author

Donations express appreciation for the author’s dedication and the substantial effort invested in creating this library.

The author resides in a country affected by ongoing military conflict since February 2022.<br/>
Due to the war, securing stable income is extremely difficult, and donations provide essential support.

If you’d like to make a donation, please use the button below:

[![](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)][paypal_donation]

Any support is much appreciated!

[github_workflow_check]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/check.yml
[github_workflow_code_ql]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/github-code-scanning/codeql
[github_workflow_release]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/release.yml
[linked_in_profile]: https://www.linkedin.com/in/stas-sultanov
[paypal_donation]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=K2DPD6J3DJ2FN