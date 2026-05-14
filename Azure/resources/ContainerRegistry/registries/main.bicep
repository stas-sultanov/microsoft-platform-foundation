metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.ContainerRegistry/registries resource.'

/* IMPORTS */

import {
	Resource as InsightsDiagnosticSetting
} from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The properties.')
param properties resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties

@description('The tags.')
param sku resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.tags

/* RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
	location: location
	name: name
	properties: properties
	sku: sku
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: ContainerRegistry_registries_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = ContainerRegistry_registries_.id

@description('The name.')
output name string = ContainerRegistry_registries_.name
