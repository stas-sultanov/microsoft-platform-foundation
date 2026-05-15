metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.OperationalInsights/workspaces resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extension settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}
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
	@description('The workspace data retention in days.')
	@minValue(30)
	retentionInDays: int
	@description('The SKU of the workspace.')
	sku: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.properties.sku
}

@description('The tags.')
param tags resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.tags

/* RESOURCES */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		features: {
			disableLocalAuth: true
		}
		retentionInDays: properties.retentionInDays
		sku: properties.sku
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		OperationalInsights_workspaces_.id,
		extensions.Authorization.roleAssignments
	): {
		name: extension.name
		properties: extension.properties
		scope: OperationalInsights_workspaces_
	}
]

#disable-next-line use-recent-api-versions
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
