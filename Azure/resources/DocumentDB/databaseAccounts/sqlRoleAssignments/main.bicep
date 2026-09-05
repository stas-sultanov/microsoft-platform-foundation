metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments resource.'

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-03-15'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('Collection of the principals.')
	principals: {
		Id: string
	}[]
	@description('The unique identifier for the associated Role Definition.')
	roleDefinitionId: string
}

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-03-15' existing = {
	name: parentName
}

/* RESOURCES */

@batchSize(1)
resource DocumentDB_databaseAccounts_sqlRoleAssignments_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-03-15' = [
	for item in settings.principals: {
		name: guid(
			subscription().id,
			DocumentDB_databaseAccounts_.id,
			settings.roleDefinitionId,
			item.Id
		)
		parent: DocumentDB_databaseAccounts_
		properties: {
			principalId: item.Id
			roleDefinitionId: settings.roleDefinitionId
			scope: DocumentDB_databaseAccounts_.id
		}
	}
]
