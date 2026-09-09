metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.ContainerRegistry/registries type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('Name of the Microsoft.ContainerRegistry/registries resource.')
param name resourceInput<'Microsoft.ContainerRegistry/registries@2026-03-01-preview'>.name

@description('Collection of role assignments.')
param roleAssignments AuthorizationRoleAssignments.ResourceInput[]

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2026-03-01-preview' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		ContainerRegistry_registries_.id,
		roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: ContainerRegistry_registries_
	}
]
