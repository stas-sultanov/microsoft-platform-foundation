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
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
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
	sku: {
		@description('The SKU name of the configuration store.')
		name:
			| 'Developer'
			| 'Free'
			| 'Premium'
			| 'Standard'
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview'>.tags
}

/* VARIABLES */

var isSoftDeleteAndPurgeProtectionSupported = settings.sku.name == 'Premium' || settings.sku.name == 'Standard'

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		dataPlaneProxy: {
			authenticationMode: 'Pass-through'
		}
		disableLocalAuth: true
		enablePurgeProtection: isSoftDeleteAndPurgeProtectionSupported
			? settings.properties.?enablePurgeProtection
			: null
		publicNetworkAccess: settings.properties.publicNetworkAccess
		softDeleteRetentionInDays: isSoftDeleteAndPurgeProtectionSupported
			? settings.properties.?softDeleteRetentionInDays
			: null
		telemetry: {
			resourceId: settings.properties.telemetryResourceId
		}
	}
	sku: settings.sku
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		AppConfiguration_configurationStores_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: AppConfiguration_configurationStores_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: AppConfiguration_configurationStores_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = AppConfiguration_configurationStores_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview'>.identity? = AppConfiguration_configurationStores_.?identity

@description('The name.')
output name string = AppConfiguration_configurationStores_.name
