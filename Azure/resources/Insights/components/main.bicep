metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Insights/components resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extension settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('Specifies whether to purge data immediately after 30 days.')
	immediatePurgeDataOn30Days: bool
	@description('Specifies whether the network access type for accessing Application Insights ingestion is enabled.')
	publicNetworkAccessForIngestion: resourceInput<'Microsoft.Insights/components@2020-02-02'>.properties.publicNetworkAccessForIngestion
	@description('Specifies whether the network access type for accessing Application Insights query is enabled.')
	publicNetworkAccessForQuery: resourceInput<'Microsoft.Insights/components@2020-02-02'>.properties.publicNetworkAccessForQuery
	@description('The retention per2od in days.')
	@minValue(30)
	retentionInDays: int
	@description('The percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry.')
	@maxValue(100)
	@minValue(0)
	samplingPercentage: int
	@description('The id of the Microsoft.OperationalInsights/workspaces resource which the data will be ingested to.')
	workspaceResourceId: string
}

@description('The tags.')
param tags resourceInput<'Microsoft.Insights/components@2020-02-02'>.tags

/* RESOURCES */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' = {
	kind: 'web'
	location: location
	name: name
	properties: {
		Application_Type: 'web'
		DisableIpMasking: true
		DisableLocalAuth: true
		ImmediatePurgeDataOn30Days: properties.immediatePurgeDataOn30Days
		publicNetworkAccessForIngestion: properties.publicNetworkAccessForIngestion
		publicNetworkAccessForQuery: properties.?publicNetworkAccessForQuery
		RetentionInDays: properties.retentionInDays
		SamplingPercentage: properties.samplingPercentage
		WorkspaceResourceId: properties.workspaceResourceId
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		Insights_components_.id,
		extensions.Authorization.roleAssignments
	): {
		name: extension.name
		properties: extension.properties
		scope: Insights_components_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Insights_components_.id

@description('The name.')
output name string = Insights_components_.name

@description('The properties.')
output properties {
	@description('The application id.')
	appId: string
	@description('The instrumentation key.')
	instrumentationKey: string
} = {
	appId: Insights_components_.properties.AppId
	instrumentationKey: Insights_components_.properties.InstrumentationKey
}
