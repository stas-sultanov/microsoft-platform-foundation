metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/networkSecurityGroups resources.'

/* TYPES */

@description('A reference to a network security group.')
@export()
@sealed()
type Reference = {
	@description('The ID of the Microsoft.Network/networkSecurityGroups resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/networkSecurityGroups/*'
			),
		'The value must be a Microsoft.Network/networkSecurityGroups resource ID.'
	)
	id: string
}

@description('The configuration of a Microsoft.Network/networkSecurityGroups/securityRules resource.')
@export()
@sealed()
type SecurityRuleResource = {
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkSecurityGroups/securityRules@2026-03-01'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.Network/networkSecurityGroups/securityRules@2026-03-01'>.properties
}
