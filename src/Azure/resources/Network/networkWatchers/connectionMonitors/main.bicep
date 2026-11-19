metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkWatchers/connectionMonitors resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The name of the parent Microsoft.Network/networkWatchers resource.')
param parentName resourceInput<'Microsoft.Network/networkWatchers@2026-03-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.tags
}

/* EXISTING RESOURCES */

resource Network_networkWatchers_ 'Microsoft.Network/networkWatchers@2026-03-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_networkWatchers_connectionMonitors_ 'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01' = {
	location: settings.location
	name: settings.name
	parent: Network_networkWatchers_
	properties: settings.properties
	tags: settings.tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // The repository selects this preview API for all diagnostic settings.
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkWatchers_connectionMonitors_
	}
]
