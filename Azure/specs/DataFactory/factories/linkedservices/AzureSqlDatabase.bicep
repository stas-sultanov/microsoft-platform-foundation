metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DataFactory/factories/linkedservices resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The name of the parent Microsoft.DataFactory/factories resource.')
param parentName resourceInput<'Microsoft.DataFactory/factories@2018-06-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('Name of the credential to use for authentication and authorization.')
	credentialName: string
	@description('The length of time (in seconds) to wait for a connection to the server before terminating the attempt and generating an error.')
	@minValue(5)
	@maxValue(60)
	connectTimeout: int?
	@description('The name of the linked service. It must be unique among the linked services in the factory.')
	name: resourceInput<'Microsoft.DataFactory/factories/linkedservices@2018-06-01'>.name
	@description('The id of the SQL Database resource.')
	sqlServerDatabaseId: string
	@description('The id of the SQL Server resource.')
	sqlServerId: string
}

/* EXISTING RESOURCES */

resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' existing = {
	name: parentName
}

resource Sql_servers_ 'Microsoft.Sql/servers@2025-01-01' existing = {
	name: split(
		settings.sqlServerId,
		'/'
	)[8]
}

resource Sql_servers_databases_ 'Microsoft.Sql/servers/databases@2025-01-01' existing = {
	name: split(
		settings.sqlServerDatabaseId,
		'/'
	)[10]
	parent: Sql_servers_
}

/* RESOURCES */

resource DataFactory_factories_linkedServices_ 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
	name: settings.name
	parent: DataFactory_factories_
	properties: {
		type: 'AzureSqlDatabase'
		typeProperties: {
			authenticationType: 'UserAssignedManagedIdentity'
			connectTimeout: settings.?connectTimeout ?? 30
			database: Sql_servers_databases_.name
			encrypt: 'mandatory'
			server: Sql_servers_.properties.fullyQualifiedDomainName
			trustServerCertificate: false
			credential: {
				referenceName: settings.credentialName
				type: 'CredentialReference'
			}
		}
	}
}
