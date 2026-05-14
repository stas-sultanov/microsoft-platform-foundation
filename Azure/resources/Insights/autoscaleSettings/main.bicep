metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Insights/autoscaleSettings resource.'

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

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Insights/autoscaleSettings@2022-10-01'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Insights/autoscaleSettings@2022-10-01'>.tags

resource Insights_autoscaleSettings_ 'Microsoft.Insights/autoscaleSettings@2022-10-01' = {
	location: location
	name: name
	properties: properties
	tags: tags
}

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Insights_autoscaleSettings_
	}
]
