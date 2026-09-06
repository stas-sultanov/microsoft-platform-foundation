metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/dataCollectionRules resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import {
	Resource as InsightsDiagnosticSetting
} from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The id of the destination Log Analytics workspace')
		workspaceId: string
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.tags
}

/* RESOURCES */

resource Insights_dataCollectionRules_ 'Microsoft.Insights/dataCollectionRules@2024-03-11' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	kind: 'Linux'
	location: settings.location
	name: settings.name
	properties: {
		dataFlows: [
			{
				destinations: [
					'VMInsightsPerf-Logs-Dest'
				]
				streams: [
					'Microsoft-InsightsMetrics'
				]
			}
		]
		dataSources: {
			performanceCounters: [
				{
					counterSpecifiers: [
						'\\VmInsights\\DetailedMetrics'
					]
					name: 'VMInsightsPerfCounters'
					// for this type 60 is the only option allowed
					samplingFrequencyInSeconds: 60
					streams: [
						'Microsoft-InsightsMetrics'
					]
				}
			]
		}
		description: 'Data collection rule for VM Insights.'
		destinations: {
			logAnalytics: [
				{
					name: 'VMInsightsPerf-Logs-Dest'
					workspaceResourceId: settings.properties.workspaceId
				}
			]
		}
	}
	tags: settings.tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Insights_dataCollectionRules_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Insights_dataCollectionRules_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.identity? = Insights_dataCollectionRules_.?identity

@description('The name.')
output name string = Insights_dataCollectionRules_.name
