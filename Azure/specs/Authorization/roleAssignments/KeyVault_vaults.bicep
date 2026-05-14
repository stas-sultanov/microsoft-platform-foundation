metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.KeyVault/vaults type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.KeyVault/vaults resource.')
param name string

/* EXISTING RESOURCES */

resource KeyVault_vaults_ 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			KeyVault_vaults_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: KeyVault_vaults_
	}
]
