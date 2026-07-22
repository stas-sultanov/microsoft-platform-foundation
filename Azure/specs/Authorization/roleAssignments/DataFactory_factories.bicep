metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.DataFactory/factories type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('Name of the Microsoft.DataFactory/factories resource.')
param name string

@description('Collection of role assignments.')
param roleAssignments AuthorizationRoleAssignments.ResourceInput[]

/* EXISTING RESOURCES */

resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		DataFactory_factories_.id,
		roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: DataFactory_factories_
	}
]
