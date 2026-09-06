metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Storage/storageAccounts/blobServices/containers type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('Collection of role assignments.')
param roleAssignments AuthorizationRoleAssignments.ResourceInput[]

@description('Name of the Microsoft.Storage/storageAccounts resource.')
param storageAccountName string

@description('Name of the Microsoft.Storage/storageAccounts/blobServices/containers resource.')
param storageContainerName string

/* EXISTING RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
	name: storageAccountName
	resource blobServices_ 'blobServices' existing = {
		name: 'default'
		resource containers_ 'containers' existing = {
			name: storageContainerName
		}
	}
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Storage_storageAccounts_::blobServices_::containers_.id,
		roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Storage_storageAccounts_::blobServices_::containers_
	}
]
