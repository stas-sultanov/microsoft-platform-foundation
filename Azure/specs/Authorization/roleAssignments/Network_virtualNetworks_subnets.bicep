metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Network/virtualNetworks/subnets type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.Network/virtualNetworks resource.')
param virtualNetworkName string

@description('Name of the Microsoft.Network/virtualNetworks/subnets resource.')
param virtualNetworkSubnetName string

/* EXISTING RESOURCES */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
	name: virtualNetworkName
	resource subnets_ 'subnets' existing = {
		name: virtualNetworkSubnetName
	}
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			Network_virtualNetworks_::subnets_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: Network_virtualNetworks_::subnets_
	}
]
