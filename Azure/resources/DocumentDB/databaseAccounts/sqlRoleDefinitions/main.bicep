metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	@sealed()
	name: {
		@description('The name of the Microsoft.DocumentDB/databaseAccounts resource.')
		databaseAccount: resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-03-15'>.name
	}
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('A set of fully qualified Scopes at or below which Role Assignments may be created using this Role Definition. This will allow application of this Role Definition on the entire database account or any underlying Database / Collection. Must have at least one element. Scopes higher than Database account are not enforceable as assignable Scopes. Note that resources referenced in assignable Scopes need not exist.')
		assignableScopes: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-03-15'>.properties.assignableScopes
		@description('The set of operations allowed through this Role Definition.')
		permissions: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-03-15'>.properties.permissions
		@description('A user-friendly name for the Role Definition. Must be unique for the database account.')
		roleName: string
	}
}

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-03-15' existing = {
	name: settings.name.databaseAccount
}

/* RESOURCES */

resource DocumentDB_databaseAccounts_sqlRoleDefinitions_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-03-15' = {
	name: guid(
		DocumentDB_databaseAccounts_.id,
		settings.properties.roleName
	)
	parent: DocumentDB_databaseAccounts_
	properties: {
		assignableScopes: settings.properties.assignableScopes
		permissions: settings.properties.permissions
		roleName: settings.properties.roleName
		type: 'CustomRole'
	}
}

/* OUTPUTS */

@description('The id.')
output id string = DocumentDB_databaseAccounts_sqlRoleDefinitions_.id

@description('The name.')
output name string = DocumentDB_databaseAccounts_sqlRoleDefinitions_.name
