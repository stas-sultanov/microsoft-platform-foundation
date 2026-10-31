metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/dataCollectionRules resource for Linux virtual machine Change Tracking and Inventory.'

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
		@sealed()
		destinations: {
			@description('Azure Monitor Logs destinations.')
			@sealed()
			logAnalytics: {
				@sealed()
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
	location: settings.location
	name: settings.name
	properties: {
		dataFlows: [
			{
				destinations: [
					'Default'
				]
				streams: [
					'Microsoft-ConfigurationChange'
					'Microsoft-ConfigurationChangeV2'
					'Microsoft-ConfigurationData'
				]
			}
		]
		dataSources: {
			extensions: [
				{
					extensionName: 'ChangeTracking-Linux'
					extensionSettings: {
						enableFiles: true
						enableInventory: true
						enableRegistry: false
						enableServices: true
						enableSoftware: true
						fileSettings: {
							fileCollectionFrequency: 900
							fileInfo: [
								{
									destinationPath: '/etc/.*.conf'
									enabled: true
									groupTag: 'Recommended'
									links: 'Follow'
									maxContentsReturnable: 5000000
									maxOutputSize: 500000
									name: 'ChangeTrackingLinuxPath_default'
									pathType: 'File'
									recurse: true
									type: 'File'
									useSudo: true
								}
							]
						}
						inventorySettings: {
							inventoryCollectionFrequency: 36000
						}
						servicesSettings: {
							serviceCollectionFrequency: 300
						}
						softwareSettings: {
							softwareCollectionFrequency: 300
						}
					}
					name: 'CTDataSource-Linux'
					streams: [
						'Microsoft-ConfigurationChange'
						'Microsoft-ConfigurationChangeV2'
						'Microsoft-ConfigurationData'
					]
				}
			]
		}
		description: 'Data collection rule for Linux virtual machine Change Tracking and Inventory.'
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
