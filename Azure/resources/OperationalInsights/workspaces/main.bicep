metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.OperationalInsights/workspaces resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

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
param identity resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('The default data collection rule resource id.')
	defaultDataCollectionRuleResourceId: string?
	@description('The features of the workspace.')
	features: {
		@description('Whether to immediately purge data after 30 days. Requires: retentionInDays == 30.')
		immediatePurgeDataOn30Days: bool?
	}
	@description('The network access type for ingestion.')
	publicNetworkAccessForIngestion: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.properties.publicNetworkAccessForIngestion
	@description('The network access type for query.')
	publicNetworkAccessForQuery: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.properties.publicNetworkAccessForQuery
	@description('The workspace data retention in days.')
	@minValue(30)
	retentionInDays: int
	@description('The SKU of the workspace.')
	sku: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.properties.sku
	@description('The daily volume cap for ingestion.')
	workspaceCapping: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.properties.workspaceCapping?
}

@description('The tags.')
param tags resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.tags

/* RESOURCES */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		defaultDataCollectionRuleResourceId: properties.?defaultDataCollectionRuleResourceId
		features: {
			disableLocalAuth: true
			enableLogAccessUsingOnlyResourcePermissions: true
			immediatePurgeDataOn30Days: properties.?features.?immediatePurgeDataOn30Days
		}
		publicNetworkAccessForIngestion: properties.?publicNetworkAccessForIngestion
		publicNetworkAccessForQuery: properties.?publicNetworkAccessForQuery
		retentionInDays: properties.retentionInDays
		sku: properties.sku
		workspaceCapping: properties.?workspaceCapping
	}
	tags: tags
}

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		OperationalInsights_workspaces_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: OperationalInsights_workspaces_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: OperationalInsights_workspaces_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = OperationalInsights_workspaces_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.identity? = OperationalInsights_workspaces_.?identity

@description('The name.')
output name string = OperationalInsights_workspaces_.name
