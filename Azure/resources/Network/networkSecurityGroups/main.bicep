metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Network Security Group and assigns Insights Diagnostic extensions.'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Network/networkSecurityGroups@2025-05-01'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Network/networkSecurityGroups@2025-05-01'>.tags

/* RESOURCES */

resource Network_networkSecurityGroups_ 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
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
		scope: Network_networkSecurityGroups_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_networkSecurityGroups_.id
