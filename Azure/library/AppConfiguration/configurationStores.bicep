metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.AppConfiguration/configurationStores resources.'

/* TYPES */

@description('The configuration of a Microsoft.AppConfiguration/configurationStores/keyValues resource.')
@export()
@sealed()
type KeyValueChildResource = {
	@description('The name.')
	name: string
	@description('The properties.')
	properties: resourceInput<'Microsoft.AppConfiguration/configurationStores/keyValues@2025-08-01-preview'>.properties
}
