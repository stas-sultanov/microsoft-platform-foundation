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
	@description('The SKU.')
	sku: resourceInput<'Microsoft.Cache/redisEnterprise@2026-09-01'>.sku
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
