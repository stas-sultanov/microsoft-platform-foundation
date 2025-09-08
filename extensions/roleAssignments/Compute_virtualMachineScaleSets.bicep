metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* IMPORTS */

import {
	ConvertToRoleAssignmentProperties
	RoleAssignment
	StandardRoleDictionary
} from 'common.bicep'

/* PARAMETERS */

@description('Collection of roles assignments.')
param assignments RoleAssignment[]

@description('Name of the Microsoft.Compute/virtualMachineScaleSets resource.')
param name string

/* VARIABLES */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'Virtual Machine Administrator Login': '1c0163c0-47e6-4577-8991-ea5c82e286e4'
		'Virtual Machine User Login': 'fb879df8-f326-4884-b1cf-06f3ad86be52'
	}
)

/* EXISTING RESOURCES */

resource Storage_storageAccounts_ 'Microsoft.Compute/virtualMachineScaleSets@2024-11-01' existing = {
	name: name
}

/* RESOURCES */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			Storage_storageAccounts_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: Storage_storageAccounts_
	}
]
