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

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	@sealed()
	name: {
		@description('The name of the Microsoft.ContainerRegistry/registries resource.')
		registry: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.name
		@description('The name of the Microsoft.ContainerRegistry/registries/replications resource.')
		replication: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.name
	}
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.tags
}

/* EXISTING RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
	name: settings.name.registry
}

/* RESOURCES */

resource ContainerRegistry_registries_replications_ 'Microsoft.ContainerRegistry/registries/replications@2025-11-01' = {
	location: settings.location
	name: settings.name.replication
	parent: ContainerRegistry_registries_
	properties: settings.properties
	tags: settings.tags
}

/* OUTPUTS */

@description('The id.')
output id string = ContainerRegistry_registries_replications_.id
