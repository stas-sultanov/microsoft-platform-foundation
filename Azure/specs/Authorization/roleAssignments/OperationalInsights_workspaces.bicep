metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.OperationalInsights/workspaces type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.OperationalInsights/workspaces resource.')
param name string

/* EXISTING RESOURCES */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			OperationalInsights_workspaces_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: OperationalInsights_workspaces_
	}
]
