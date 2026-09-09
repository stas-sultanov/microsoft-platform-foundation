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
param parentName resourceInput<'Microsoft.ContainerRegistry/registries@2026-03-01-preview'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2026-03-01-preview'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2026-03-01-preview'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.ContainerRegistry/registries/replications@2026-03-01-preview'>.tags
}

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2026-03-01-preview' existing = {
	name: parentName
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource ContainerRegistry_registries_replications_ 'Microsoft.ContainerRegistry/registries/replications@2026-03-01-preview' = {
	location: settings.location
	name: settings.name
	parent: ContainerRegistry_registries_
	properties: settings.properties
	tags: settings.tags
}

/* OUTPUTS */

@description('The id.')
output id string = ContainerRegistry_registries_replications_.id
