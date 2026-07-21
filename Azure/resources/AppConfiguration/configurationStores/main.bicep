metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.AppConfiguration/configurationStores resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The identity.')
param identity resourceInput<'Microsoft.AppConfiguration/configurationStores@2024-06-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
@maxLength(50)
@minLength(5)
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('Specifies whether to enable purge protection on the configuration store. Requires: sku.name == \'Premium\' or sku.name == \'Standard\'.')
	enablePurgeProtection: bool?
	@description('The network access mode.')
	publicNetworkAccess: resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview'>.properties.publicNetworkAccess
	@description('The amount of time in days that the configuration store will be retained when it is soft deleted. Requires: sku.name == \'Premium\' or sku.name == \'Standard\'.')
	@maxValue(7)
	@minValue(1)
	softDeleteRetentionInDays: int?
	@description('The id of the Microsoft.Insights/components resource.')
	telemetryResourceId: string
}

@description('The SKU.')
@sealed()
param sku {
	@description('The SKU name of the configuration store.')
	name:
		| 'Developer'
		| 'Free'
		| 'Premium'
		| 'Standard'
}

@description('The tags.')
param tags resourceInput<'Microsoft.AppConfiguration/configurationStores@2024-06-01'>.tags

/* VARIABLES */

var isSoftDeleteAndPurgeProtectionSupported = sku.name == 'Premium' || sku.name == 'Standard'

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview' = {
	identity: identity
	location: location
	name: name
	properties: {
		dataPlaneProxy: {
			authenticationMode: 'Pass-through'
		}
		disableLocalAuth: true
		enablePurgeProtection: isSoftDeleteAndPurgeProtectionSupported
			? properties.?enablePurgeProtection
			: null
		publicNetworkAccess: properties.publicNetworkAccess
		softDeleteRetentionInDays: isSoftDeleteAndPurgeProtectionSupported
			? properties.?softDeleteRetentionInDays
			: null
		telemetry: {
			resourceId: properties.telemetryResourceId
		}
	}
	sku: {
		name: sku.name
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		AppConfiguration_configurationStores_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: AppConfiguration_configurationStores_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: AppConfiguration_configurationStores_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = AppConfiguration_configurationStores_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.AppConfiguration/configurationStores@2024-06-01'>.identity? = AppConfiguration_configurationStores_.?identity

@description('The name.')
output name string = AppConfiguration_configurationStores_.name
