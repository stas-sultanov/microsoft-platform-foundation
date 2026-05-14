metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Storage/storageAccounts/blobServices/containers type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.Storage/storageAccounts resource.')
param storageAccountName string

@description('Name of the Microsoft.Storage/storageAccounts/blobServices/containers resource.')
param storageContainerName string

/* EXISTING RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2025-08-01' existing = {
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
	for properties in assignmentsProperties: {
		name: sys.guid(
			Storage_storageAccounts_::blobServices_::containers_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: Storage_storageAccounts_::blobServices_::containers_
	}
]
