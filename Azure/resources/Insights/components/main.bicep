metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/components resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
}?

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('Specifies whether the network access type for accessing Application Insights ingestion is enabled.')
	publicNetworkAccessForIngestion: resourceInput<'Microsoft.Insights/components@2020-02-02'>.properties.publicNetworkAccessForIngestion
	@description('Specifies whether the network access type for accessing Application Insights query is enabled.')
	publicNetworkAccessForQuery: resourceInput<'Microsoft.Insights/components@2020-02-02'>.properties.publicNetworkAccessForQuery
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
		publicNetworkAccessForIngestion: properties.publicNetworkAccessForIngestion
		publicNetworkAccessForQuery: properties.?publicNetworkAccessForQuery
		WorkspaceResourceId: properties.workspaceResourceId
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Insights_components_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
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
