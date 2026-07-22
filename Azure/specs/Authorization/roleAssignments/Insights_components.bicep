metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Insights/components type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('Name of the Microsoft.Insights/components resource.')
param name string

@description('Collection of role assignments.')
param roleAssignments AuthorizationRoleAssignments.ResourceInput[]

/* EXISTING RESOURCES */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Insights_components_.id,
		roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Insights_components_
	}
]
