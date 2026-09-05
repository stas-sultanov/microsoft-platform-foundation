metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/virtualNetworkGateways resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as MaintenanceConfigurationAssignments from '../../../library/Maintenance/configurationAssignments.bicep'

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
	Maintenance: {
		configurationAssignments: MaintenanceConfigurationAssignments.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-07-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-07-01'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-07-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-07-01'>.tags
}

/* RESOURCES */

resource Network_virtualNetworkGateways_ 'Microsoft.Network/virtualNetworkGateways@2025-07-01' = {
	identity: settings.?identity ?? {
	type: 'None'
}
	location: settings.location
	name: settings.name
	properties: settings.properties
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_virtualNetworkGateways_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworkGateways_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworkGateways_
	}
]

resource Maintenance_configurationAssignments_ 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = [
	for item in extensions.Maintenance.configurationAssignments: {
		location: settings.location
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworkGateways_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_virtualNetworkGateways_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Network/virtualNetworkGateways@2025-07-01'>.identity? = Network_virtualNetworkGateways_.?identity

@description('The name.')
output name string = Network_virtualNetworkGateways_.name
