metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Storage/storageAccounts type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('Name of the Microsoft.Storage/storageAccounts resource.')
	name: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.name
	@description('Collection of role assignments.')
	roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
}

/* EXISTING RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
	name: settings.name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Storage_storageAccounts_.id,
		settings.roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Storage_storageAccounts_
	}
]
