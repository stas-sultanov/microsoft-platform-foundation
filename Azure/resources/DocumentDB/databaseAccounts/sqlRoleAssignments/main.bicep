metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* TYPES */

@sealed()
type RoleAssignmentResourceInput = {
	@sealed()
	properties: {
		@description('The object ID for the identity within Entra.')
		principalId: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-03-15'>.properties.principalId
		@description('The name of the Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions resource.')
		roleDefinitionName: string
		@description('The data plane resource path for which access is being granted through this Role Assignment.')
		scope: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-03-15'>.properties.scope?
	}
}

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-03-15'>.name

@description('Collection of role assignments.')
param roleAssignments RoleAssignmentResourceInput[]

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-03-15' existing = {
	name: parentName
}

/* RESOURCES */

@batchSize(1)
resource DocumentDB_databaseAccounts_sqlRoleAssignments_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-03-15' = [
	for item in roleAssignments: {
		name: guid(
			DocumentDB_databaseAccounts_.id,
			item.properties.principalId,
			item.properties.roleDefinitionName
		)
		parent: DocumentDB_databaseAccounts_
		properties: {
			principalId: item.properties.principalId
			roleDefinitionId: resourceId(
				'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions',
				parentName,
				item.properties.roleDefinitionName
			)
			scope: item.properties.?scope ?? DocumentDB_databaseAccounts_.id
		}
	}
]
