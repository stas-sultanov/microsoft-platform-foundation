metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts resource with extensions.'

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
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties {
	@description('The account creation mode.')
	createMode: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-10-15'>.properties.createMode

	@description('Whether requests from Public Network are allowed.')
	publicNetworkAccess: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-10-15'>.properties.publicNetworkAccess

	@description('The id of the restorable database account from which the restore has to be initiated.')
	restoreSourceId: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-10-15'>.properties.restoreParameters.restoreSource

	@description('The point in time to restore. Used only when create mode is Restore.')
	restoreTimestamp: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-10-15'>.properties.restoreParameters.restoreTimestampInUtc
}

param capacityMode string = 'Static'

@description('The tags.')
param tags resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-10-15'>.tags

/* VARIABLES */

var capabilities = {
	Static: []
	Autoscale: []
	Serverless: [
		{
			name: 'EnableServerless'
		}
	]
}

var ipRules = {
	Disabled: [
		{
			ipAddressOrRange: '0.0.0.0'
		}
		{
			ipAddressOrRange: '40.76.54.131'
		}
		{
			ipAddressOrRange: '52.169.50.45'
		}
		{
			ipAddressOrRange: '52.176.6.30'
		}
		{
			ipAddressOrRange: '52.187.184.26'
		}
		{
			ipAddressOrRange: '104.42.195.92'
		}
	]
	Enabled: []
}

var restoreParameters = {
	Default: {}
	Restore: {
		restoreMode: 'PointInTime'
		restoreSource: properties.restoreSourceId
		restoreTimestampInUtc: properties.restoreTimestamp
	}
}

/* RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2025-10-15' = {
	kind: 'GlobalDocumentDB'
	location: location
	name: name
	properties: {
		backupPolicy: {
			type: 'Continuous'
		}
		capabilities: capabilities[capacityMode]
		createMode: properties.createMode
		databaseAccountOfferType: 'Standard'
		ipRules: ipRules[properties.publicNetworkAccess]
		locations: [
			{
				locationName: location
			}
		]
		publicNetworkAccess: properties.publicNetworkAccess
		restoreParameters: restoreParameters[properties.createMode]
	}
	tags: union(
		tags ?? {},
		{
			capacityMode: capacityMode
		}
	)
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		DocumentDB_databaseAccounts_.id,
		extensions.Authorization.roleAssignments
	): {
		name: extension.name
		properties: extension.properties
		scope: DocumentDB_databaseAccounts_
	}
]

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: DocumentDB_databaseAccounts_
	}
]

#disable-next-line use-recent-api-versions
resource Security_advancedThreatProtectionSettings_ 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
	name: 'current'
	properties: {
		isEnabled: true
	}
	scope: DocumentDB_databaseAccounts_
}

/* OUTPUTS */

@description('The id.')
output id string = DocumentDB_databaseAccounts_.id

@description('The name.')
output name string = DocumentDB_databaseAccounts_.name

@description('The restore id.')
output restoreId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.DocumentDB/locations/${DocumentDB_databaseAccounts_.location}/restorableDatabaseAccounts/${DocumentDB_databaseAccounts_.properties.instanceId}'
