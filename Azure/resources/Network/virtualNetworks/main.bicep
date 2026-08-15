metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Virtual Network and assigns Insights Diagnostic extensions.'

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
param properties resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.tags

/* RESOURCES */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2025-07-01' = {
	location: location
	name: name
	properties: properties
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworks_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_virtualNetworks_.id

@description('The name.')
output name string = Network_virtualNetworks_.name

@description('A list of subnets in a Virtual Network.')
output subnets resourceOutput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.subnets = Network_virtualNetworks_.properties.subnets
