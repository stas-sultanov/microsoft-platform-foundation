metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Network/virtualNetworks/subnets type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('Collection of role assignments.')
	roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	@description('Name of the Microsoft.Network/virtualNetworks resource.')
	virtualNetworkName: string
	@description('Name of the Microsoft.Network/virtualNetworks/subnets resource.')
	virtualNetworkSubnetName: string
}

/* EXISTING RESOURCES */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2025-07-01' existing = {
	name: settings.virtualNetworkName
	resource subnets_ 'subnets' existing = {
		name: settings.virtualNetworkSubnetName
	}
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_virtualNetworks_::subnets_.id,
		settings.roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworks_::subnets_
	}
]
