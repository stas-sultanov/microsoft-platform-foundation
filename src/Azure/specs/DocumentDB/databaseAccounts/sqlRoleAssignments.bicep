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
type RoleAssignmentResourceInput = {
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The principal id.')
		principalId: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-04-01-preview'>.properties.principalId
		@description('The name of the Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions resource.')
		roleDefinitionName: string
		@description('The Cosmos DB data-plane scope: "/" for the account, "/dbs/{databaseName}" for a database, or "/dbs/{databaseName}/colls/{containerName}" for a container.')
		@validate(
			value =>
				value == '/' || sys.length(sys.filter(
					sys.split(
						value,
						'/'
					),
					segment =>
						sys.empty(segment)
				)) == 1 && (sys.length(sys.split(
					value,
					'/'
				)) == 3 && sys.like(
					value,
					'/dbs/*'
				) || sys.length(sys.split(
					value,
					'/'
				)) == 5 && sys.like(
					value,
					'/dbs/*/colls/*'
				)),
			'The value must be "/", "/dbs/{databaseName}", or "/dbs/{databaseName}/colls/{containerName}".'
		)
		scope: string
	}
}

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name

@description('Collection of role assignments.')
@sealed()
param resources {
	sqlRoleAssignments: RoleAssignmentResourceInput[]
}

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview' existing = {
	name: parentName
}

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlRoleDefinitions_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2026-04-01-preview' existing = [
	for item in resources.sqlRoleAssignments: {
		name: item.properties.roleDefinitionName
		parent: DocumentDB_databaseAccounts_
	}
]

/* RESOURCES */

@batchSize(1)
#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlRoleAssignments_ 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2026-04-01-preview' = [
	for (item, index) in resources.sqlRoleAssignments: {
		name: sys.guid(
			DocumentDB_databaseAccounts_.id,
			item.properties.scope,
			item.properties.principalId,
			item.properties.roleDefinitionName
		)
		parent: DocumentDB_databaseAccounts_
		properties: {
			principalId: item.properties.principalId
			roleDefinitionId: DocumentDB_databaseAccounts_sqlRoleDefinitions_[index].id
			scope: '${DocumentDB_databaseAccounts_.id}${item.properties.scope}'
		}
	}
]
