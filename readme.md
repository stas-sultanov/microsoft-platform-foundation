# Microsoft Platform Foundation

[![Check](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/check.yml/badge.svg)][github_workflow_check]
[![CodeQL](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/github-code-scanning/codeql/badge.svg)][github_workflow_code_ql]
[![Copilot Review](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/agents/copilot-pull-request-reviewer/badge.svg)][github_workflow_copilot_review]
[![Release](https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/release.yml/badge.svg)][github_workflow_release]

An opinionated Bicep module library for Azure and Entra, built around security, explicit contracts, and deliberate constraints.

Authored and maintained by [Stas Sultanov][linked_in_profile].

[Support the author](#support-the-author), if this library benefits your business.

## Bicep Version

The foundation depends on the Bicep CLI version and is updated to newer versions as soon as practical.

Bicep CLI version: [0.48.1](https://github.com/Azure/bicep/releases/tag/v0.48.1).

## Documentation

- [Foundation Contract](doc/foundation-contract.md): design principles, security, and compatibility.
- [Module Structure](doc/module-structure.md): module categories and paths.
- [Authoring Rules](doc/authoring-rules.md): implementation conventions.
- [Tools](tools/readme.md): scripts for building, formatting, publishing, and synchronizing API versions.

## What Would It Cost to Build This?

This foundation has been developed and continuously refined by a single engineer over years.

The greatest challenge is not the implementation itself, but **the vision and original ideas** behind it.

Curious what it would take to build an equivalent foundation from scratch?

**[Prompt paid ChatGPT to independently estimate the development effort and cost][chatgpt_prompt_cost_estimate]**

## Support the Author

Donations express appreciation for the author’s dedication and the substantial effort invested in creating this library.

The author resides in a country affected by ongoing military conflict since February 2022.<br/>
Due to the war, securing stable income is extremely difficult, and donations provide essential support.

If you’d like to make a donation, please use the button below:

[![Donate via PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)][paypal_donation]

Any support is much appreciated!

[chatgpt_prompt_cost_estimate]: https://chatgpt.com/?q=Review+the+code+and+documentation+at+https:%2F%2Fgithub.com%2Fstas-sultanov%2Fmicrosoft-platform-foundation.%0A%0AIndependently+estimate+the+effort+and+cost+to+design+and+build+an+equivalent+foundation+from+scratch.+Treat+all+of+this+work+as+research+and+development+(R%26D):+this+is+a+unique+foundation+with+original+architecture+and+ideas,+not+a+routine+implementation+or+straightforward+assembly+of+existing+modules.+Account+for+the+research,+experimentation,+security,+engineering,+and+validation+involved.+Use+bottom-up+estimation+based+on+actual+module+complexity.%0A%0AReturn+only:%0A%0A1.+Effort:+Person-hours+by+workstream+and+seniority,+plus+total.%0A2.+Cost:+Low%2Fbase%2Fhigh+estimates+for+Europe+(EUR)+and+US+(USD),+using+current+cited+rates.%0A3.+Details:+A+clickable+follow-up:+%22Provide+me+with+more+details%22.%0A
[github_workflow_check]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/check.yml
[github_workflow_code_ql]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/github-code-scanning/codeql
[github_workflow_copilot_review]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/agents/copilot-pull-request-reviewer
[github_workflow_release]: https://github.com/stas-sultanov/microsoft-platform-foundation/actions/workflows/release.yml
[linked_in_profile]: https://www.linkedin.com/in/stas-sultanov
[paypal_donation]: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=K2DPD6J3DJ2FN
