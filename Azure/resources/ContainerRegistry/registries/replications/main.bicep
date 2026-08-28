metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ContainerRegistry/registries/replications resource.'

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.name

@description('The name of the parent Microsoft.ContainerRegistry/registries resource.')
param parentName string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.ContainerRegistry/registries/replications@2025-11-01'>.tags

/* EXISTING RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
	name: parentName
}

/* RESOURCES */

resource ContainerRegistry_registries_replications_ 'Microsoft.ContainerRegistry/registries/replications@2025-11-01' = {
	location: location
	name: name
	parent: ContainerRegistry_registries_
	properties: properties
	tags: tags
}

/* OUTPUTS */

@description('The id.')
output id string = ContainerRegistry_registries_replications_.id
