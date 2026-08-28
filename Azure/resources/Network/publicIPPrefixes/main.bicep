metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/publicIPPrefixes resource with extensions.'

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

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Network/publicIPPrefixes@2025-07-01'>.name

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Network/publicIPPrefixes@2025-07-01'>.properties

@description('The SKU.')
param sku resourceInput<'Microsoft.Network/publicIPPrefixes@2025-07-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Network/publicIPPrefixes@2025-07-01'>.tags

@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
param zones string[]

/* RESOURCES */

resource Network_publicIPPrefixes_ 'Microsoft.Network/publicIPPrefixes@2025-07-01' = {
	location: location
	name: name
	properties: properties
	sku: sku
	tags: tags
	zones: zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_publicIPPrefixes_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_publicIPPrefixes_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_publicIPPrefixes_
	}
]

/* OUTPUTS */

@description('The name.')
output name string = Network_publicIPPrefixes_.name
