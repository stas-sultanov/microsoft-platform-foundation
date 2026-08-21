metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/publicIPAddresses resource with extensions.'

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
param name string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Network/publicIPAddresses@2025-07-01'>.properties = {
	publicIPAllocationMethod: 'Static'
}

@description('The SKU.')
param sku resourceInput<'Microsoft.Network/publicIPAddresses@2025-07-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Network/publicIPAddresses@2025-07-01'>.tags

@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
param zones string[]

/* RESOURCES */

resource Network_publicIPAddresses_ 'Microsoft.Network/publicIPAddresses@2025-07-01' = {
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
		Network_publicIPAddresses_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_publicIPAddresses_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_publicIPAddresses_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_publicIPAddresses_.id

@description('The name.')
output name string = Network_publicIPAddresses_.name

@description('The properties.')
output properties {
	@description('The IP address associated with the public IP address resource.')
	ipAddress: string
} = {
	ipAddress: Network_publicIPAddresses_.properties.ipAddress
}
