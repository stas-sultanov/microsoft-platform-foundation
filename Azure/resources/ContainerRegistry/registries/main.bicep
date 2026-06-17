metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ContainerRegistry/registries resource.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSetting from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting.Resource[]
	}
}

@description('The identity.')
param identity resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The properties.')
param properties resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties

@description('The SKU.')
param sku resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.tags

/* RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
	identity: identity
	location: location
	name: name
	properties: properties
	sku: sku
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		ContainerRegistry_registries_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: ContainerRegistry_registries_
	}
]

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

@description('The identity.')
output identity resourceOutput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.identity? = ContainerRegistry_registries_.?identity

@description('The name.')
output name string = ContainerRegistry_registries_.name
