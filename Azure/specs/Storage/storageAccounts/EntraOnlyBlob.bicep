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

@sealed()
type StorageAccountPropertiesInput = {
	accessTier:
		| 'Hot'
		| 'Cool'
		| 'Cold'
		| 'Smart'?
	allowCrossTenantReplication: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.allowCrossTenantReplication?
	allowedCopyScope: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.allowedCopyScope?
	dnsEndpointType: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.dnsEndpointType?
	dualStackEndpointPreference: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.dualStackEndpointPreference?
	enableExtendedGroups: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.enableExtendedGroups?
	geoPriorityReplicationStatus: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.geoPriorityReplicationStatus?
	immutableStorageWithVersioning: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.immutableStorageWithVersioning?
	isHnsEnabled: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.isHnsEnabled?
	networkAcls: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.networkAcls?
	@description('The network access mode.')
	publicNetworkAccess: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.publicNetworkAccess?
	routingPreference: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.routingPreference?
}

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The child resources.')
@sealed()
param resources {
	blobServices: {
		Default: {
			extensions: {
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
	zones: settings.?zones ?? []
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
