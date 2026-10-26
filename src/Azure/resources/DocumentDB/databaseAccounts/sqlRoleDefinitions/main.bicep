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

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('A set of Scopes at or below which Role Assignments may be created using this Role Definition: "/", "/dbs/{databaseName}", or "/dbs/{databaseName}/colls/{containerName}".')
		@validate(
			value =>
				sys.length(value) > 0 && sys.empty(sys.filter(
					value,
					scope =>
						!(scope == '/' || sys.like(
							scope,
							'/dbs/*'
						) || sys.like(
							scope,
							'/dbs/*/colls/*'
						))
				)),
			'Each scope must be "/", "/dbs/{databaseName}", or "/dbs/{databaseName}/colls/{containerName}".'
		)
		assignableScopes: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-04-01-preview'>.properties.assignableScopes
		@description('The set of operations allowed through this Role Definition.')
		permissions: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-04-01-preview'>.properties.permissions
		@description('A user-friendly name for the Role Definition. Must be unique for the database account.')
		roleName: string
	}
}

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview' existing = {
	name: parentName
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlRoleDefinitions_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-04-01-preview' = {
	name: sys.guid(
		DocumentDB_databaseAccounts_.id,
		settings.properties.roleName
	)
	parent: DocumentDB_databaseAccounts_
	properties: {
		assignableScopes: sys.map(
			settings.properties.assignableScopes,
			scope =>
				scope == '/'
					? DocumentDB_databaseAccounts_.id
					: '${DocumentDB_databaseAccounts_.id}${scope}'
		)
		permissions: settings.properties.permissions
		roleName: settings.properties.roleName
		type: 'CustomRole'
	}
}
