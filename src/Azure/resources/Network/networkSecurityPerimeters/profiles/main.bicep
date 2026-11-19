metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityPerimeters/profiles resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../../library/Insights/diagnosticSettings.bicep'

import * as NetworkNetworkSecurityPerimeters from '../../../../library/Network/networkSecurityPerimeters.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The name of the parent Microsoft.Network/networkSecurityPerimeters resource.')
param parentName resourceInput<'Microsoft.Network/networkSecurityPerimeters@2026-03-01'>.name

@description('The child resources.')
@sealed()
param resources {
	accessRules: NetworkNetworkSecurityPerimeters.AccessRuleResource[]
}?

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	@maxLength(80)
	name: resourceInput<'Microsoft.Network/networkSecurityPerimeters/profiles@2026-03-01'>.name
}

/* EXISTING RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2026-03-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_networkSecurityPerimeters_profiles_ 'Microsoft.Network/networkSecurityPerimeters/profiles@2026-03-01' = {
	name: settings.name
	parent: Network_networkSecurityPerimeters_
	properties: {}
}

resource Network_networkSecurityPerimeters_profiles_accessRules_ 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2026-03-01' = [
	for item in resources.?accessRules ?? []: {
		name: item.name
		parent: Network_networkSecurityPerimeters_profiles_
		properties: item.properties
	}
]

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // The repository selects this preview API for all diagnostic settings.
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityPerimeters_profiles_
	}
]
