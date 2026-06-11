metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Public IP Prefix and assigns Insights Diagnostic extensions.'

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
param properties resourceInput<'Microsoft.Network/publicIPPrefixes@2024-07-01'>.properties

@description('The SKU.')
param sku resourceInput<'Microsoft.Network/publicIPPrefixes@2024-07-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Network/publicIPPrefixes@2024-07-01'>.tags

@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
param zones string[]

/* RESOURCES */

resource Network_publicIPPrefixes_ 'Microsoft.Network/publicIPPrefixes@2025-05-01' = {
	location: location
	name: name
	properties: properties
	sku: sku
	tags: tags
	zones: zones
}

/* EXTENSIONS */

resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Network_publicIPPrefixes_
	}
]

/* OUTPUTS */

@description('The name.')
output name string = Network_publicIPPrefixes_.name
