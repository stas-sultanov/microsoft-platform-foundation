metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ContainerRegistry/registries/replications resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The name of the parent Microsoft.ContainerRegistry/registries resource.')
param parentName resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.tags
}

/* EXISTING RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
	name: parentName
}

/* RESOURCES */

resource ContainerRegistry_registries_replications_ 'Microsoft.ContainerRegistry/registries/replications@2025-11-01' = {
	location: settings.location
	name: settings.name
	parent: ContainerRegistry_registries_
	properties: settings.properties
	tags: settings.tags
}

/* OUTPUTS */

@description('The id.')
output id string = ContainerRegistry_registries_replications_.id
