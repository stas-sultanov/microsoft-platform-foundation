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
param parentName string

@description('Collection of the principals.')
param principals {
	Id: string
}[]

@description('The unique identifier for the associated Role Definition.')
param roleDefinitionId string

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-03-15' existing = {
	name: parentName
}

/* RESOURCES */

@batchSize(1)
resource CosmosAccount_sqlRoleAssignments_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-03-15' = [
	for item in principals: {
		name: guid(
			subscription().id,
			DocumentDB_databaseAccounts_.id,
			roleDefinitionId,
			item.Id
		)
		parent: DocumentDB_databaseAccounts_
		properties: {
			principalId: item.Id
			roleDefinitionId: roleDefinitionId
			scope: DocumentDB_databaseAccounts_.id
		}
	}
]
