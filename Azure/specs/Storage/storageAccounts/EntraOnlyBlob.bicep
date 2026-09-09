metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Storage/storageAccounts resource for blobs with Entra based access.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@description('The configurable properties for the storage account.')
@sealed()
type StorageAccountPropertiesInput = {
	@description('The access tier for the storage account.')
	accessTier: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.accessTier?
	@description('Allow or disallow cross Entra tenant object replication.')
	allowCrossTenantReplication: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.allowCrossTenantReplication?
	@description('Restrict copy to and from Storage Accounts within an Entra tenant or with Private Links to the same VNet.')
	allowedCopyScope: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.allowedCopyScope?
	@description('The type of endpoint.')
	dnsEndpointType: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.dnsEndpointType?
	@description('The Internet protocol.')
	dualStackEndpointPreference: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.dualStackEndpointPreference?
	@description('Enable or disable extended groups for the storage account.')
	enableExtendedGroups: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.enableExtendedGroups?
	@description('Status indicating whether Geo Priority Replication is enabled for the account.')
	geoPriorityReplicationStatus: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.geoPriorityReplicationStatus?
	@description('Enable or disable immutable storage with versioning for the storage account.')
	immutableStorageWithVersioning: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.immutableStorageWithVersioning?
	@description('Account HierarchicalNamespace enabled if sets to true.')
	isHnsEnabled: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.isHnsEnabled?
	@description('The network access control list for the storage account.')
	networkAcls: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.networkAcls?
	@description('The network access mode.')
	publicNetworkAccess: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.publicNetworkAccess?
	@description('Maintains information about the network routing choice opted by the user for data transfer.')
	routingPreference: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.routingPreference?
}

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The child resources.')
@sealed()
param resources {
	@sealed()
	blobServices: {
		@sealed()
		Default: {
			@sealed()
			extensions: {
				@sealed()
				Insights: {
					diagnosticSettings: InsightsDiagnosticSettings.Resource[]
				}
			}
		}
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	@maxLength(24)
	@minLength(3)
	name: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.name
	@description('The configurable properties.')
	properties: StorageAccountPropertiesInput
	@description('The SKU.')
	@sealed()
	sku: {
		name:
			| 'Standard_LRS'
			| 'Standard_GRS'
			| 'Standard_RAGRS'
			| 'Standard_ZRS'
			| 'Standard_GZRS'
			| 'Standard_RAGZRS'
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.tags
	@description('The pinned logical availability zones.')
	zones: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.zones?
}

/* RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2026-04-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	kind: 'StorageV2'
	location: settings.location
	name: settings.name
	properties: {
		...settings.properties
		allowBlobPublicAccess: false
		allowSharedKeyAccess: false
		defaultToOAuthAuthentication: true
		isLocalUserEnabled: false
		isNfsV3Enabled: false
		isSftpEnabled: false
		minimumTlsVersion: 'TLS1_2'
		supportsHttpsTrafficOnly: true
	}
	sku: settings.sku
	tags: settings.tags
	zones: settings.?zones
	resource blobServices_ 'blobServices' = {
		name: 'default'
	}
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Storage_storageAccounts_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Storage_storageAccounts_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings__Storage_storageAccounts_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Storage_storageAccounts_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings__Storage_storageAccounts__blobServices_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in resources.blobServices.Default.extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Storage_storageAccounts_::blobServices_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Storage_storageAccounts_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Storage/storageAccounts@2026-04-01'>.identity? = Storage_storageAccounts_.?identity

@description('The name.')
output name string = Storage_storageAccounts_.name
