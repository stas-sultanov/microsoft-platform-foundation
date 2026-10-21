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

/* TYPES */

@description('A geo-replication location.')
@sealed()
type Location = {
	@description('Specifies whether this region is an Availability Zone region.')
	isZoneRedundant: bool
	@description('The region name.')
	locationName: string
}

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
@validate(
	value =>
		sys.length(sys.filter(
			sys.take(
				value.properties.locations,
				1
			),
			item =>
				item.locationName == value.location
		)) == 1,
	'The first location must match settings.location.'
)
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name
	@description('The configurable properties.')
	@sealed()
	@validate(
		value =>
			value.capacityMode == 'Provisioned' || value.?capacity == null,
		'capacity can only be specified when capacityMode is Provisioned.'
	)
	properties: {
		@description('The policy for taking backups on an account.')
		backupPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.backupPolicy
		@description('Properties related to capacity enforcement on an account. Requires capacityMode to be Provisioned.')
		capacity: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.capacity?
		@description('The capacity mode.')
		capacityMode:
			| 'Provisioned'
			| 'Serverless'
		@description('The consistency policy.')
		consistencyPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.consistencyPolicy
		@description('List of IpRules.')
		ipRules: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.properties.ipRules
		@description('The geo replication locations.')
		@minLength(1)
		@validate(
			value =>
				sys.length(sys.union(
					[],
					sys.map(
						value,
						item =>
							item.locationName
					)
				)) == sys.length(value),
			'locations must be unique.'
		)
		locations: Location[]
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
		capacity: settings.properties.?capacity
		capacityMode: settings.properties.capacityMode
		consistencyPolicy: settings.properties.consistencyPolicy
		createMode: 'Default'
		databaseAccountOfferType: 'Standard'
		disableLocalAuth: true
		ipRules: settings.properties.ipRules
		locations: sys.map(
			settings.properties.locations,
			(
				item,
				index
			) => {
				failoverPriority: index
				isZoneRedundant: item.isZoneRedundant
				locationName: item.locationName
			}
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
