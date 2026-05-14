metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.ContainerRegistry/registries type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.ContainerRegistry/registries resource.')
param name string

/* EXISTING RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			ContainerRegistry_registries_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: ContainerRegistry_registries_
	}
]
