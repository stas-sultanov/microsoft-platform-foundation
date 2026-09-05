metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Compute/galleries type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('Name of the Microsoft.Compute/galleries resource.')
	name: resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.name
	@description('Collection of role assignments.')
	roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
}

/* EXISTING RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-12-03' existing = {
	name: settings.name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_galleries_.id,
		settings.roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Compute_galleries_
	}
]
