metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.AppConfiguration/configurationStores resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extension settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}
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
	@description('Specifies whether to enable purge protection on the configuration store.')
	enablePurgeProtection: bool?
	@description('Specifies whether to allow public endpoint connectivity to the configuration store.')
	publicNetworkAccessEnabled: bool
	@description('The amount of time in days that the configuration store will be retained when it is soft deleted.')
	@maxValue(7)
	@minValue(1)
	softDeleteRetentionInDays: int?
	@description('The ID of the Microsoft.Insights/components resource.')
	telemetryResourceId: string
}

@description('The SKU.')
param sku resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-06-01-preview'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-06-01-preview'>.tags

/* RESOURCES */

// to use telemetry, preview version of resource is required
#disable-next-line use-recent-api-versions
resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2025-06-01-preview' = {
	identity: identity
	location: location
	name: name
	properties: {
		dataPlaneProxy: {
			authenticationMode: 'Pass-through'
		}
		disableLocalAuth: true
		enablePurgeProtection: properties.?enablePurgeProtection
		publicNetworkAccess: properties.publicNetworkAccessEnabled
			? 'Enabled'
			: 'Disabled'
		softDeleteRetentionInDays: properties.?softDeleteRetentionInDays
		telemetry: {
			resourceId: properties.telemetryResourceId
		}
	}
	sku: sku
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: AppConfiguration_configurationStores_
	}
]

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		AppConfiguration_configurationStores_.id,
		extensions.Authorization.roleAssignments
	): {
		name: extension.name
		properties: extension.properties
		scope: AppConfiguration_configurationStores_
	}
]

/* OUTPUTS */

@description('The ID.')
output id string = AppConfiguration_configurationStores_.id

@description('The name.')
output name string = AppConfiguration_configurationStores_.name
