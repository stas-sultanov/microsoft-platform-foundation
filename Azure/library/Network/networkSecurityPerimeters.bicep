metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/networkSecurityPerimeters resources.'

@description('The configuration of a Microsoft.Network/networkSecurityPerimeters/resourceAssociations resource.')
@export()
@sealed()
type ResourceAssociationChildResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the NSP resource association.')
	properties: resourceInput<'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01'>.properties
}
