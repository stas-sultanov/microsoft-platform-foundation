metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* imports */

import {
	ConvertToRoleAssignmentProperties
	RoleAssignment
	StandardRoleDictionary
} from 'common.bicep'

/* parameters */

@description('Collection of roles assignments.')
param assignments RoleAssignment[]

@description('Name of the Microsoft.KeyVault/vaults resource.')
param name string

/* variables */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
		'Key Vault Certificate User': 'db79e9a7-68ee-4b58-9aeb-b90e7c24fcba'
		'Key Vault Certificates Officer': 'a4417e6f-fecd-4de8-b567-7b0420556985'
		'Key Vault Contributor': 'f25e0fa2-a7c8-4377-a976-54943a77a395'
		'Key Vault Crypto Officer': '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
		'Key Vault Crypto Service Encryption User': 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
		'Key Vault Crypto User': '12338af0-0e69-4776-bea7-57ae8d297424'
		'Key Vault Reader': '21090545-7ca7-4776-b22c-e363652d74d2'
		'Key Vault Secrets Officer': 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
		'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
	}
)

/* existing resources */

resource KeyVault_vaults_ 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
	name: name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			KeyVault_vaults_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: KeyVault_vaults_
	}
]
