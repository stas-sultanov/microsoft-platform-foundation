metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/dataCollectionRules resource for Linux virtual machine OpenTelemetry metrics-based Insights.'

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
			@description('Azure Monitor workspace destinations.')
			monitoringAccounts: {
				Default: {
					@validate(
						value =>
							sys.like(
								value,
								'/subscriptions/*/resourceGroups/*/providers/Microsoft.Monitor/accounts/*'
							),
						'The value must be a Microsoft.Monitor/accounts resource ID.'
					)
					@description('The resource ID of the Microsoft.Monitor/accounts resource.')
					accountResourceId: string
				}
			}
		}
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.tags
}

/* RESOURCES */

resource Insights_dataCollectionRules_ 'Microsoft.Insights/dataCollectionRules@2024-03-11' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		dataFlows: [
			{
				destinations: [
					'Default'
				]
				streams: [
					'Microsoft-OtelPerfMetrics'
				]
			}
		]
		dataSources: {
			performanceCountersOTel: [
				{
					counterSpecifiers: [
						'system.cpu.time'
						'system.memory.usage'
						'system.disk.io'
						'system.disk.operations'
						'system.disk.operation_time'
						'system.filesystem.usage'
						'system.network.io'
						'system.network.dropped'
						'system.network.errors'
						'system.uptime'
					]
					name: 'vmOtelSystemMetrics'
					samplingFrequencyInSeconds: 60 // for this type 60 is the only option allowed
					streams: [
						'Microsoft-OtelPerfMetrics'
					]
				}
			]
		}
		description: 'Data collection rule for Linux virtual machine OpenTelemetry metrics-based Insights.'
		destinations: {
			monitoringAccounts: [
				{
					accountResourceId: settings.properties.destinations.monitoringAccounts.Default.accountResourceId
					name: 'Default'
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
