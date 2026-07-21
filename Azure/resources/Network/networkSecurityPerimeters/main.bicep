metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityPerimeters resource and optionally configures extensions and resource associations.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

type ResourceAssociationResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the NSP resource association.')
	properties: resourceInput<'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01'>.properties
}

type Resources = {
	@description('The array of resource associations.')
	resourceAssociations: ResourceAssociationResource[]
}

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

@description('The child resources settings.')
param resources Resources = {
	resourceAssociations: []
}

@description('The tags.')
param tags resourceInput<'Microsoft.Network/networkSecurityPerimeters@2025-07-01'>.tags

/* RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2025-07-01' = {
	location: location
	name: name
	properties: {}
	tags: tags
}

resource Network_networkSecurityPerimeters_resourceAssociations_ 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01' = [
	for resource in resources.resourceAssociations: {
		name: resource.name
		parent: Network_networkSecurityPerimeters_
		properties: resource.properties
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		Network_networkSecurityPerimeters_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: Network_networkSecurityPerimeters_
	}
]

resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Network_networkSecurityPerimeters_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_networkSecurityPerimeters_.id

@description('The name.')
output name string = Network_networkSecurityPerimeters_.name

@description('The ids of created resource associations.')
output resourceAssociationIds string[] = [
	for i in range(
		0,
		length(resources.resourceAssociations)
	): Network_networkSecurityPerimeters_resourceAssociations_[i].id
]
