metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments resource.'

/* PARAMETERS */

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('Collection of the principals.')
param principals {
	Id: string
}[]

@description('The unique identifier for the associated Role Definition.')
param roleDefinitionId string

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2025-10-15' existing = {
	name: DocumentDB_databaseAccounts__name
}

/* RESOURCES */

@batchSize(1)
resource CosmosAccount_sqlRoleAssignments_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2025-10-15' = [
	for principal in principals: {
		name: guid(
			subscription().id,
			DocumentDB_databaseAccounts_.id,
			roleDefinitionId,
			principal.Id
		)
		parent: DocumentDB_databaseAccounts_
		properties: {
			principalId: principal.Id
			roleDefinitionId: roleDefinitionId
			scope: DocumentDB_databaseAccounts_.id
		}
	}
]
