metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://www.linkedin.com/in/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts resource with extensions.'

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
param identity resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('The policy for taking backups on an account.')
	backupPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.backupPolicy
	@description('Properties related to capacity enforcement on an account.')
	capacity: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.capacity?
	@description('The capacity mode for the Cosmos DB account.')
	capacityMode: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.capacityMode
	@description('The consistency policy for the Cosmos DB account.')
	consistencyPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.consistencyPolicy
	@description('List of IpRules.')
	ipRules: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.ipRules
	@description('Locations enabled for the Cosmos DB account.')
	locations: {
		@description('The primary region.')
		Primary: {
			@description('Flag to indicate whether or not this region is an AvailabilityZone region')
			isZoneRedundant: bool
		}
		*: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.locations[*]
	}
	@description('Whether requests from Public Network are allowed.')
	publicNetworkAccess: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.properties.publicNetworkAccess
}

@description('The tags.')
param tags resourceInput<'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview'>.tags

/* RESOURCES */

#disable-diagnostics use-recent-api-versions // have to use it because of properties.capacityMode
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview' = {
	identity: identity
	kind: 'GlobalDocumentDB'
	location: location
	name: name
	properties: {
		backupPolicy: properties.backupPolicy
		capacity: properties.capacityMode == 'Provisioned'
			? properties.?capacity
			: null
		capacityMode: properties.capacityMode
		consistencyPolicy: properties.consistencyPolicy
		createMode: 'Default'
		databaseAccountOfferType: 'Standard'
		disableLocalAuth: true
		ipRules: properties.ipRules
		locations: concat(
			[
				{
					failoverPriority: 0
					isZoneRedundant: properties.locations.Primary.isZoneRedundant
					locationName: location
				}
			],
			map(
				filter(
					items(properties.locations),
					item =>
						item.key != 'Primary'
				),
				item =>
					item.value
			)
		)
		minimalTlsVersion: 'Tls12'
		publicNetworkAccess: properties.publicNetworkAccess
	}
	tags: tags
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

/* OUTPUTS */

@description('The id.')
output id string = DocumentDB_databaseAccounts_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.DocumentDB/databaseAccounts@2025-10-15'>.identity? = DocumentDB_databaseAccounts_.?identity

@description('The name.')
output name string = DocumentDB_databaseAccounts_.name

@description('The properties.')
output properties {
	@description('The connection endpoint for the Cosmos DB database account.')
	documentEndpoint: string
	@description('The connection endpoint for the Cosmos DB SQL API.')
	sqlEndpoint: string
} = {
	documentEndpoint: DocumentDB_databaseAccounts_.properties.documentEndpoint
	sqlEndpoint: DocumentDB_databaseAccounts_.properties.documentEndpoint
}

@description('The restore id.')
output restoreId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.DocumentDB/locations/${DocumentDB_databaseAccounts_.location}/restorableDatabaseAccounts/${DocumentDB_databaseAccounts_.properties.instanceId}'
