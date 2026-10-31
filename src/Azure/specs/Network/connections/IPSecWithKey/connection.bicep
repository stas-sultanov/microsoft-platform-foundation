metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = '''
Provisions a Microsoft.Network/connections resource for an IPsec connection using a shared key passed securely from its parent module.
This temporary internal module is used by IPSecWithKey.bicep because Bicep allows getSecret() only when assigning to a module parameter with the @secure() decorator (BCP180).
The Microsoft.Network/connections resource type defines a sharedKeyKeyVaultId property, but it is not available in a generally available or preview API.
Remove this module once getSecret() can be used directly in the resource body of IPSecWithKey.bicep or the sharedKeyKeyVaultId property becomes available.
'''

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/connections@2026-01-01'>.name
	@description('The configurable properties, excluding the shared key.')
	properties: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/connections@2026-01-01'>.tags
}

@description('The shared key for the connection.')
@secure()
param sharedKey string

/* RESOURCES */

resource Network_connections_ 'Microsoft.Network/connections@2026-01-01' = {
	location: settings.location
	name: settings.name
	properties: {
		...settings.properties
		sharedKey: sharedKey
	}
	tags: settings.tags
}
