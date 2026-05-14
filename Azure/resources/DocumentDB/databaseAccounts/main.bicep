metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

param capacityMode string = 'Static'

@description('The enum to indicate the mode of account creation.')
@allowed([
	'Default'
	'Restore'
])

param createMode string = 'Default'

@description('The extension settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}
}

@description('The geo-location.')
param location string

@description('The ID of the OperationalInsights/workspaces resource.')
param logAnalyticsWorkspaceResourceId string

@description('The name.')
param name string

@description('Specifies whether to allow public endpoint connectivity to the database account.')
@allowed([
	'Disabled'
	'Enabled'
])

param publicNetworkAccess string = 'Disabled'

@description('The ID of the restorable database account from which the restore has to be initiated.')
param restoreSourceId string = ''

@description('The point in time to restore. Used only when create mode is Restore.')
param restoreTimestamp string = utcNow('u')

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
		restoreSource: restoreSourceId
		restoreTimestampInUtc: restoreTimestamp
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
		createMode: createMode
		databaseAccountOfferType: 'Standard'
		ipRules: ipRules[publicNetworkAccess]
		locations: [
			{
				locationName: location
			}
		]
		publicNetworkAccess: publicNetworkAccess
		restoreParameters: restoreParameters[createMode]
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
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: split(logAnalyticsWorkspaceResourceId, '/')[8]
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				categoryGroup: 'allLogs'
				enabled: true
			}
		]
		metrics: [
			{
				enabled: true
				timeGrain: 'PT1M'
			}
		]
		workspaceId: logAnalyticsWorkspaceResourceId
	}
	scope: DocumentDB_databaseAccounts_
}

#disable-next-line use-recent-api-versions
resource Security_advancedThreatProtectionSettings_ 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
	name: 'current'
	properties: {
		isEnabled: true
	}
	scope: DocumentDB_databaseAccounts_
}

/* OUTPUTS */

@description('The ID.')
output id string = DocumentDB_databaseAccounts_.id

@description('The name.')
output name string = DocumentDB_databaseAccounts_.name

@description('The restore ID.')
output restoreId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.DocumentDB/locations/${DocumentDB_databaseAccounts_.location}/restorableDatabaseAccounts/${DocumentDB_databaseAccounts_.properties.instanceId}'
