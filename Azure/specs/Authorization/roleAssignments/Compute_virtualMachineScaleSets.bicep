metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Compute/virtualMachineScaleSets type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('Name of the Microsoft.Compute/virtualMachineScaleSets resource.')
param name string

@description('Collection of role assignments.')
param roleAssignments AuthorizationRoleAssignments.ResourceInput[]

/* EXISTING RESOURCES */

resource Compute_virtualMachineScaleSets_ 'Microsoft.Compute/virtualMachineScaleSets@2026-03-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_virtualMachineScaleSets_.id,
		roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachineScaleSets_
	}
]
