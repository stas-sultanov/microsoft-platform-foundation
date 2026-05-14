metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions resource.'

/* PARAMETERS */

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('Name of the resource.')
param name string

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2025-10-15' existing = {
	name: DocumentDB_databaseAccounts__name
}

/* RESOURCES */

resource CosmosAccount_SqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2025-10-15' = {
	name: guid(
		subscription().id,
		DocumentDB_databaseAccounts_.id,
		name
	)
	parent: DocumentDB_databaseAccounts_
	properties: {
		assignableScopes: [
			DocumentDB_databaseAccounts_.id
		]
		permissions: [
			{
				dataActions: [
					'Microsoft.DocumentDB/databaseAccounts/readMetadata'
					'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
					'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
				]
				notDataActions: []
			}
		]
		roleName: name
		type: 'CustomRole'
	}
}
