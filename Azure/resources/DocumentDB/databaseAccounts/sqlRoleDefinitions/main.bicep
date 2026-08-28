metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions resource.'

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName string

@description('Name of the resource.')
param name resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-03-15'>.name

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-03-15' existing = {
	name: parentName
}

/* RESOURCES */

resource CosmosAccount_sqlRoleDefinitions_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-03-15' = {
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
