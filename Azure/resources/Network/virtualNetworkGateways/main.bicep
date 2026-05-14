metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Network/virtualNetworkGateways resource and optionally configures extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import {
	Resource as InsightsDiagnosticSetting
} from '../../../library/Insights/diagnosticSettings.bicep'

import {
	Resource as MaintenanceConfigurationAssignment
} from '../../../library/Maintenance/configurationAssignments.bicep'

/* PARAMETERS */

@description('The extension settings.')
@sealed()
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting[]
	}
	Maintenance: {
		configurationAssignments: MaintenanceConfigurationAssignment[]
	}
}

@description('The identity.')
param identity resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-01-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The properties.')
param properties resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-01-01'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-01-01'>.tags

/* RESOURCES */

resource Network_virtualNetworkGateways_ 'Microsoft.Network/virtualNetworkGateways@2025-05-01' = {
	identity: identity
	location: location
	name: name
	properties: properties
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Network_virtualNetworkGateways_
	}
]

resource Maintenance_configurationAssignments_ 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = [
	for extension in extensions.Maintenance.configurationAssignments: {
		location: location
		name: extension.name
		properties: extension.properties
		scope: Network_virtualNetworkGateways_
	}
]

/* OUTPUTS */

@description('The ID.')
output id string = Network_virtualNetworkGateways_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Network/virtualNetworkGateways@2025-01-01'>.identity? = Network_virtualNetworkGateways_.?identity

@description('The name.')
output name string = Network_virtualNetworkGateways_.name
