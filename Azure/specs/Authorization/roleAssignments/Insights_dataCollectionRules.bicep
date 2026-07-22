metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Insights/dataCollectionRules type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('Name of the Microsoft.Insights/dataCollectionRules resource.')
param name string

@description('Collection of role assignments.')
param roleAssignments AuthorizationRoleAssignments.ResourceInput[]

/* EXISTING RESOURCES */

resource Insights_dataCollectionRules_ 'Microsoft.Insights/dataCollectionRules@2024-03-11' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Insights_dataCollectionRules_.id,
		roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Insights_dataCollectionRules_
	}
]
