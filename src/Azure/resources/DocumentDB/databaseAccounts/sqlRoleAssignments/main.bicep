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

@description('RoleAssignment resource input configuration.')
@sealed()
type ResourceInput = {
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The object ID for the identity within Entra.')
		principalId: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-04-01-preview'>.properties.principalId
		@description('The name of the Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions resource.')
		roleDefinitionName: string
		@description('The scope string for which access is being granted through this Role Assignment. If omitted, the database account resource id is used.')
		scope: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-04-01-preview'>.properties.scope?
	}
}

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name

@description('Collection of role assignments.')
param roleAssignments ResourceInput[]

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview' existing = {
	name: parentName
}

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlRoleDefinitions_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-04-01-preview' existing = [
	for item in roleAssignments: {
		name: item.properties.roleDefinitionName
		parent: DocumentDB_databaseAccounts_
	}
]

/* RESOURCES */

@batchSize(1)
#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlRoleAssignments_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-04-01-preview' = [
	for (item, index) in roleAssignments: {
		name: sys.guid(
			item.properties.?scope ?? DocumentDB_databaseAccounts_.id,
			item.properties.principalId,
			item.properties.roleDefinitionName
		)
		parent: DocumentDB_databaseAccounts_
		properties: {
			principalId: item.properties.principalId
			roleDefinitionId: DocumentDB_databaseAccounts_sqlRoleDefinitions_[index].id
			scope: item.properties.?scope ?? DocumentDB_databaseAccounts_.id
		}
	}
]
