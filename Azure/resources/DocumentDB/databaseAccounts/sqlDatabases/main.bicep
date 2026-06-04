metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlDatabases resource.'

/* PARAMETERS */

@description('The identity.')
param identity resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-11-01-preview'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param parentName string

@description('The configurable properties.')
@sealed()
param properties {
	@description('The database options. Note: Either throughput or autoscaleSettings is required, but not both.')
	options: {
		@description('The autoscale settings.')
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
param tags resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-10-15'>.tags

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview' existing = {
	name: parentName
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // We need to use the preview API version to set the identity property.
resource DocumentDB_databaseAccounts_sqlDatabases_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-11-01-preview' = {
	identity: identity
	location: location
	name: name
	parent: DocumentDB_databaseAccounts_
	properties: {
		options: {
			throughput: properties.options.?throughput
			autoscaleSettings: properties.options.?autoscaleSettings
		}
		resource: {
			id: name
		}
	}
	tags: tags
}

/* OUTPUTS */

@description('The identity.')
output identity resourceOutput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-11-01-preview'>.identity? = DocumentDB_databaseAccounts_sqlDatabases_.?identity
