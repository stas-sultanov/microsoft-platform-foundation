metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DataFactory/factories/linkedservices resource.'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('The length of time (in seconds) to wait for a connection to the server before terminating the attempt and generating an error.')
	@minValue(5)
	@maxValue(60)
	connectionTimeout: int?
	@description('The id of the Data Factory resource.')
	dataFactoryId: string
	@description('The name of the linked service. It must be unique among the linked services in the factory.')
	name: resourceInput<'Microsoft.DataFactory/factories/linkedservices@2018-06-01'>.name
	@description('The id of the SQL Database resource.')
	sqlServerDatabaseId: string
	@description('The id of the SQL Server resource.')
	sqlServerId: string
}

/* EXISTING RESOURCES */

resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' existing = {
	name: split(
		settings.dataFactoryId,
		'/'
	)[8]
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
			connectionString: 'Integrated Security=False;Encrypt=True;Connection Timeout=${connectionTimeout};Data Source=${Sql_servers_.properties.fullyQualifiedDomainName};Initial Catalog=${Sql_servers_databases_.name}'
		}
	}
}
