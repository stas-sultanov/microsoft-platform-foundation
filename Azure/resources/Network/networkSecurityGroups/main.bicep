metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityGroups resource with extensions.'

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

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkSecurityGroups@2025-07-01'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.Network/networkSecurityGroups@2025-07-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkSecurityGroups@2025-07-01'>.tags
}

/* RESOURCES */

resource Network_networkSecurityGroups_ 'Microsoft.Network/networkSecurityGroups@2025-07-01' = {
	location: settings.location
	name: settings.name
	properties: settings.properties
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_networkSecurityGroups_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityGroups_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityGroups_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_networkSecurityGroups_.id
