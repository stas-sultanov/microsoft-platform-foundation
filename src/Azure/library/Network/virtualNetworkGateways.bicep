metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/virtualNetworkGateways resources.'

/* TYPES */

@description('The configuration of a Microsoft.Network/virtualNetworkGateways/natRules resource.')
@export()
@sealed()
type NatRuleChildResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the virtual network gateway NAT rule.')
	properties: resourceInput<'Microsoft.Network/virtualNetworkGateways/natRules@2025-09-01'>.properties
}
