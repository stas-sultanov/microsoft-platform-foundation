metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = '''
TEMPORARY SOLUTION. Internal module of IPSecWithKey.bicep, not intended for direct use.
Provisions a Microsoft.Network/connections resource with a shared key provided as a secure parameter.
Exists only because Bicep allows getSecret() solely when assigning to a module parameter with @secure() decorator (BCP180).
The Microsoft.Network/connections resource type also defines a sharedKeyKeyVaultId property, but it is not available for either general availability or preview use.
Remove once getSecret() can be used directly in the resource body of IPSecWithKey.bicep, or once the sharedKeyKeyVaultId property becomes available.
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
