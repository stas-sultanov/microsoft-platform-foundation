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

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.Compute/virtualMachineScaleSets resource.')
param name string

/* EXISTING RESOURCES */

resource Compute_virtualMachineScaleSets_ 'Microsoft.Compute/virtualMachineScaleSets@2025-11-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			Compute_virtualMachineScaleSets_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: Compute_virtualMachineScaleSets_
	}
]
