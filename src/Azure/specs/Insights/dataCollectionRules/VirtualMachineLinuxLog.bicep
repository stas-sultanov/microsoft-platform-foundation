metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/dataCollectionRules resource for Linux virtual machine logs-based Insights.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
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
		@description('The specification of destinations.')
		destinations: {
			@description('Log Analytics destinations.')
			logAnalytics: {
				Default: {
					@validate(
						value =>
							sys.like(
								value,
								'/subscriptions/*/resourceGroups/*/providers/Microsoft.OperationalInsights/workspaces/*'
							),
						'The value must be a Microsoft.OperationalInsights/workspaces resource ID.'
					)
					@description('The ID of the Microsoft.OperationalInsights/workspaces resource.')
					workspaceResourceId: string
				}
			}
		}
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.tags
}

/* RESOURCES */

// The output tables may not be ready when this rule is deployed.
@retryOn(
	[
		'InvalidOutputTable'
	],
	10
)
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
					'Default'
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
					samplingFrequencyInSeconds: 60 // for this type 60 is the only option allowed
					streams: [
						'Microsoft-InsightsMetrics'
					]
				}
			]
		}
		description: 'Data collection rule for Linux virtual machine log-based Insights.'
		destinations: {
			logAnalytics: [
				{
					name: 'Default'
					workspaceResourceId: settings.properties.destinations.logAnalytics.Default.workspaceResourceId
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
