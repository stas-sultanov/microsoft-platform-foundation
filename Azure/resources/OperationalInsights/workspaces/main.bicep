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
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
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
	tags: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.tags
}

/* RESOURCES */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		...settings.properties
		features: {
			disableLocalAuth: true
			enableLogAccessUsingOnlyResourcePermissions: true
			immediatePurgeDataOn30Days: settings.properties.features.?immediatePurgeDataOn30Days
		}
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		OperationalInsights_workspaces_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: OperationalInsights_workspaces_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
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
