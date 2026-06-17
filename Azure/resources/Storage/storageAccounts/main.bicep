metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Storage/storageAccounts resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@sealed()
type StorageAccountPropertiesInput = {
	accessTier: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.accessTier?
	allowCrossTenantReplication: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.allowCrossTenantReplication?
	allowedCopyScope: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.allowedCopyScope?
	azureFilesIdentityBasedAuthentication: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.azureFilesIdentityBasedAuthentication?
	customDomain: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.customDomain?
	dnsEndpointType: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.dnsEndpointType?
	dualStackEndpointPreference: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.dualStackEndpointPreference?
	enableExtendedGroups: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.enableExtendedGroups?
	encryption: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.encryption?
	geoPriorityReplicationStatus: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.geoPriorityReplicationStatus?
	immutableStorageWithVersioning: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.immutableStorageWithVersioning?
	isHnsEnabled: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.isHnsEnabled?
	largeFileSharesState: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.largeFileSharesState?
	networkAcls: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.networkAcls?
	publicNetworkAccess: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.publicNetworkAccess?
	routingPreference: resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.properties.routingPreference?
}

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The identity.')
param identity resourceInput<'Microsoft.Storage/storageAccounts@2025-06-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
@maxLength(24)
@minLength(3)
param name string

@description('The resource kind.')
param kind resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.kind

@description('The configurable properties.')
param properties StorageAccountPropertiesInput

@description('The SKU.')
param sku resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.tags

@description('The pinned logical availability zones.')
param zones resourceInput<'Microsoft.Storage/storageAccounts@2026-04-01'>.zones

/* RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2026-04-01' = {
	identity: identity
	kind: kind
	location: location
	name: name
	properties: union(
		properties,
		{
			allowBlobPublicAccess: false
			allowSharedKeyAccess: false
			defaultToOAuthAuthentication: true
			isLocalUserEnabled: false
			isNfsV3Enabled: false
			isSftpEnabled: false
			minimumTlsVersion: 'TLS1_2'
			supportsHttpsTrafficOnly: true
		}
	)
	sku: sku
	tags: tags
	zones: zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		Storage_storageAccounts_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: Storage_storageAccounts_
	}
]

resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Storage_storageAccounts_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Storage_storageAccounts_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Storage/storageAccounts@2026-04-01'>.identity? = Storage_storageAccounts_.?identity

@description('The name.')
output name string = Storage_storageAccounts_.name
