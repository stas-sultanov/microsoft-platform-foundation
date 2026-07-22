metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Cache/redisEnterprise resource with extensions.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

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
param identity resourceInput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('Dataset replication configuration for the Redis Enterprise cluster.')
	highAvailability: resourceInput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.properties.highAvailability
	@description('Cluster-level maintenance configuration.')
	maintenanceConfiguration: resourceInput<'Microsoft.Cache/redisEnterprise@2026-02-01-preview'>.properties.maintenanceConfiguration
	@description('The network access mode.')
	publicNetworkAccess: resourceInput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.properties.publicNetworkAccess
}

@description('The SKU.')
param sku resourceInput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.tags

@description('The zones.')
param zones resourceInput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.zones = []

/* RESOURCES */

#disable-diagnostics use-recent-api-versions // maintenance window configuration is available in preview only
resource Cache_redisEnterprise_ 'Microsoft.Cache/redisEnterprise@2026-02-01-preview' = {
	identity: identity
	location: location
	name: name
	properties: {
		...properties
		minimumTlsVersion: '1.2'
	}
	sku: sku
	tags: tags
	zones: zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Cache_redisEnterprise_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Cache_redisEnterprise_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Cache_redisEnterprise_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Cache_redisEnterprise_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Cache/redisEnterprise@2025-07-01'>.identity? = Cache_redisEnterprise_.?identity

@description('The name.')
output name string = Cache_redisEnterprise_.name
