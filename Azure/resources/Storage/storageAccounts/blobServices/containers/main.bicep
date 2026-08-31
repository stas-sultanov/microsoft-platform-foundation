metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Storage/storageAccounts/blobServices/containers resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
}?

@description('The name.')
@maxLength(63)
@minLength(3)
param name resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.name

@description('The name of the parent Microsoft.Storage/storageAccounts resource.')
param parentAccountName resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.name

@description('The configurable properties.')
@sealed()
param properties {
	defaultEncryptionScope: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.properties.defaultEncryptionScope?
	denyEncryptionScopeOverride: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.properties.denyEncryptionScopeOverride?
	enableNfsV3AllSquash: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.properties.enableNfsV3AllSquash?
	enableNfsV3RootSquash: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.properties.enableNfsV3RootSquash?
	immutableStorageWithVersioning: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.properties.immutableStorageWithVersioning?
	metadata: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'>.properties.metadata?
}

@description('The child resources.')
@sealed()
param resources {
	immutabilityPolicies: {
		Default: {
			properties: resourceInput<'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2026-04-01'>.properties
		}
	}
}?

/* EXISTING RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
	name: parentAccountName
}

resource Storage_storageAccounts_blobServices_ 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' existing = {
	name: 'default'
	parent: Storage_storageAccounts_
}

/* RESOURCES */

resource Storage_storageAccounts_blobServices_containers_ 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
	name: name
	parent: Storage_storageAccounts_blobServices_
	properties: properties
}

resource Storage_storageAccounts_blobServices_containers_immutabilityPolicies__Default 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2026-04-01' = if (resources.?immutabilityPolicies.Default != null) {
	name: 'default'
	parent: Storage_storageAccounts_blobServices_containers_
	properties: resources!.immutabilityPolicies!.Default!.properties
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Storage_storageAccounts_blobServices_containers_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Storage_storageAccounts_blobServices_containers_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Storage_storageAccounts_blobServices_containers_.id

@description('The name.')
output name string = Storage_storageAccounts_blobServices_containers_.name
