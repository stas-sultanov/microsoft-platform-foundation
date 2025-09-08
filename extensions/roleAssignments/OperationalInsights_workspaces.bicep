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

@description('Name of the Microsoft.OperationalInsights/workspaces resource.')
param name string

/* variables */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'Log Analytics Contributor': '92aaf0da-9dab-42b6-94a3-d43ce8d16293'
		'Log Analytics Reader': '73c42c96-874c-492b-b04d-ab87d138a893'
		'Monitoring Contributor': '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
		'Monitoring Reader': '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
	}
)

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
	name: name
}

/* RESOURCE EXTENSIONS */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			OperationalInsights_workspaces_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: OperationalInsights_workspaces_
	}
]
