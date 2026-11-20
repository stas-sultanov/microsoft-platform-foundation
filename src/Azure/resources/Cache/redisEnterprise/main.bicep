metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Cache/redisEnterprise resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

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

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Dataset replication configuration for the Redis Enterprise cluster.')
		highAvailability: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.properties.highAvailability
		@description('Cluster-level maintenance configuration.')
		maintenanceConfiguration: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.properties.maintenanceConfiguration
		@description('The network access mode.')
		publicNetworkAccess: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.properties.publicNetworkAccess
	}
	@description('The Azure Managed Redis SKU.')
	@sealed()
	sku: {
		@description('The SKU name.')
		name:
			| 'Balanced_B0'
			| 'Balanced_B1'
			| 'Balanced_B3'
			| 'Balanced_B5'
			| 'Balanced_B10'
			| 'Balanced_B20'
			| 'Balanced_B50'
			| 'Balanced_B100'
			| 'Balanced_B150'
			| 'Balanced_B250'
			| 'Balanced_B350'
			| 'Balanced_B500'
			| 'Balanced_B700'
			| 'Balanced_B1000'
			| 'ComputeOptimized_X3'
			| 'ComputeOptimized_X5'
			| 'ComputeOptimized_X10'
			| 'ComputeOptimized_X20'
			| 'ComputeOptimized_X50'
			| 'ComputeOptimized_X100'
			| 'ComputeOptimized_X150'
			| 'ComputeOptimized_X250'
			| 'ComputeOptimized_X350'
			| 'ComputeOptimized_X500'
			| 'ComputeOptimized_X700'
			| 'FlashOptimized_A250'
			| 'FlashOptimized_A500'
			| 'FlashOptimized_A700'
			| 'FlashOptimized_A1000'
			| 'FlashOptimized_A1500'
			| 'FlashOptimized_A2000'
			| 'FlashOptimized_A4500'
			| 'MemoryOptimized_M10'
			| 'MemoryOptimized_M20'
			| 'MemoryOptimized_M50'
			| 'MemoryOptimized_M100'
			| 'MemoryOptimized_M150'
			| 'MemoryOptimized_M250'
			| 'MemoryOptimized_M350'
			| 'MemoryOptimized_M500'
			| 'MemoryOptimized_M700'
			| 'MemoryOptimized_M1000'
			| 'MemoryOptimized_M1500'
			| 'MemoryOptimized_M2000'
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.tags
	@description('The zones.')
	zones: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.zones?
}

/* RESOURCES */

resource Cache_redisEnterprise_ 'Microsoft.Cache/redisEnterprise@2026-09-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		...settings.properties
		minimumTlsVersion: '1.2'
	}
	sku: settings.sku
	tags: settings.tags
	zones: settings.?zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Cache_redisEnterprise_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Cache_redisEnterprise_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Cache_redisEnterprise_
	}
]
