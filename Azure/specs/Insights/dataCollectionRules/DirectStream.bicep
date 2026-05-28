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

@description('The extension settings.')
@sealed()
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('Data flow configuration.')
	dataFlow: {
		@description('The stream name used in destinations.')
		destinations: string[]
		@description('The KQL query used to transform stream data.')
		transformKql: string
	}
	@description('The data collection rule description.')
	description: string
	@description('Destination configuration.')
	destinations: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.properties.destinations
	@description('Custom stream declaration.')
	stream: {
		@description('Columns in the stream declaration.')
		columns: resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.properties.streamDeclarations.*.columns
		@description('The stream declaration name.')
		@maxLength(63)
		@minLength(3)
		name: string
	}
}

@description('The tags.')
param tags resourceInput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.tags = {}

/* RESOURCES */

resource Insights_dataCollectionRules_ 'Microsoft.Insights/dataCollectionRules@2024-03-11' = {
	kind: 'Direct'
	location: location
	name: name
	properties: {
		dataCollectionEndpointId: null // No data collection endpoint is used for direct ingestion.
		dataFlows: [
			{
				destinations: properties.dataFlow.destinations
				outputStream: properties.stream.name
				streams: [
					properties.stream.name
				]
				transformKql: properties.dataFlow.transformKql
			}
		]
		description: properties.description
		destinations: properties.destinations
		streamDeclarations: {
			'${properties.stream.name}': {
				columns: properties.stream.columns
			}
		}
	}
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Insights_dataCollectionRules_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Insights_dataCollectionRules_.id

@description('The name.')
output name string = Insights_dataCollectionRules_.name

@description('The properties.')
output properties {
	@description('The ingestion endpoints to send data to the rule.')
	endpoints: resourceOutput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.properties.endpoints
	@description('The immutable id of this data collection rule.')
	immutableId: resourceOutput<'Microsoft.Insights/dataCollectionRules@2024-03-11'>.properties.immutableId
} = {
	endpoints: Insights_dataCollectionRules_.properties.endpoints
	immutableId: Insights_dataCollectionRules_.properties.immutableId
}
