metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
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
	identity: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The policy for taking backups on an account.')
		backupPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.backupPolicy
		@description('Properties related to capacity enforcement on an account.')
		capacity: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.capacity?
		@description('The capacity mode for the Cosmos DB account.')
		capacityMode: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.capacityMode
		@description('The consistency policy for the Cosmos DB account.')
		consistencyPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.consistencyPolicy
		@description('List of IpRules.')
		ipRules: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.ipRules
		@description('Locations enabled for the Cosmos DB account.')
		locations: {
			@description('The primary region.')
			Primary: {
				@description('Flag to indicate whether or not this region is an AvailabilityZone region')
				isZoneRedundant: bool
			}
			*: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.locations[*]
		}
		@description('The network access mode.')
		publicNetworkAccess: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.publicNetworkAccess
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.tags
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // capacityMode is available only in the preview API.
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	kind: 'GlobalDocumentDB'
	location: settings.location
	name: settings.name
	properties: {
		backupPolicy: settings.properties.backupPolicy
		capacity: settings.properties.capacityMode == 'Provisioned'
			? settings.properties.?capacity
			: null
		capacityMode: settings.properties.capacityMode
		consistencyPolicy: settings.properties.consistencyPolicy
		createMode: 'Default'
		databaseAccountOfferType: 'Standard'
		disableLocalAuth: true
		ipRules: settings.properties.ipRules
		locations: concat(
			[
				{
					failoverPriority: 0
					isZoneRedundant: settings.properties.locations.Primary.isZoneRedundant
					locationName: settings.location
				}
			],
			map(
				filter(
					items(settings.properties.locations),
					item =>
						item.key != 'Primary'
				),
				item =>
					item.value
			)
		)
		minimalTlsVersion: 'Tls12'
		publicNetworkAccess: settings.properties.publicNetworkAccess
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		DocumentDB_databaseAccounts_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: DocumentDB_databaseAccounts_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: DocumentDB_databaseAccounts_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = DocumentDB_databaseAccounts_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.identity? = DocumentDB_databaseAccounts_.?identity

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
output restoreId string = '/subscriptions/${subscription().subscriptionId}/extensions/Microsoft.DocumentDB/locations/${DocumentDB_databaseAccounts_.location}/restorableDatabaseAccounts/${DocumentDB_databaseAccounts_.properties.instanceId}'
