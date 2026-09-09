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
		@description('The database options. Note: Either throughput or autoscaleSettings is required, but not both.')
		@sealed()
		options: {
			@description('The autoscale settings.')
			@sealed()
			autoscaleSettings: {
				@maxValue(10000000)
				@minValue(4000)
				@description('The maximum throughput the database can autoscale to.')
				maxThroughput: int
			}?
			@description('Request Units per second.')
			@maxValue(10000000)
			@minValue(400)
			throughput: int?
		}
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
		options: {
			throughput: settings.properties.options.?throughput
			autoscaleSettings: settings.properties.options.?autoscaleSettings
		}
		resource: {
			id: settings.name
		}
	}
	tags: settings.tags
}

/* OUTPUTS */

@description('The id.')
output id string = DocumentDB_databaseAccounts_sqlDatabases_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2026-04-01-preview'>.identity? = DocumentDB_databaseAccounts_sqlDatabases_.?identity

@description('The name.')
output name string = DocumentDB_databaseAccounts_sqlDatabases_.name
