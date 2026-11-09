metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/networkSecurityGroups resources.'

/* TYPES */

@description('The configuration of a Microsoft.Network/networkSecurityGroups/securityRules resource.')
@export()
@sealed()
type SecurityRuleResource = {
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkSecurityGroups/securityRules@2026-03-01'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.Network/networkSecurityGroups/securityRules@2026-03-01'>.properties
}
