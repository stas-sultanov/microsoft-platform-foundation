metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlDatabases resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as DocumentDBDatabaseAccounts from '../../../../library/DocumentDB/databaseAccounts.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2026-04-01-preview'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2026-04-01-preview'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The throughput settings.')
		@validate(
			value =>
				value.?throughput == null || value.?autoscaleSettings == null,
			'throughput and autoscaleSettings cannot both be specified.'
		)
		options: DocumentDBDatabaseAccounts.ThroughputOptions?
	}
	@description('Tags to put on the resource.')
	tags: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2026-04-01-preview'>.tags
}

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview' existing = {
	name: parentName
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlDatabases_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2026-04-01-preview' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	parent: DocumentDB_databaseAccounts_
	properties: {
		options: settings.properties.?options
		resource: {
			id: settings.name
		}
	}
	tags: settings.tags
}
