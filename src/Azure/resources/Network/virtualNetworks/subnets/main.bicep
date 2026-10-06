metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/virtualNetworks/subnets resource with explicit outbound connectivity and extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The name of the parent Microsoft.Network/virtualNetworks resource.')
param parentName resourceInput<'Microsoft.Network/virtualNetworks@2026-01-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	name: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The subnet address prefixes in CIDR notation.')
		@minLength(1)
		addressPrefixes: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.addressPrefixes
		@description('The service delegations for the subnet.')
		delegations: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.delegations?
		@description('The array of IpAllocation which reference this subnet.')
		ipAllocations: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.ipAllocations?
		@description('The NAT gateway associated with the subnet.')
		natGateway: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.natGateway?
		@description('The network security group associated with the subnet.')
		networkSecurityGroup: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.networkSecurityGroup?
		@description('The network policies applied to private endpoints in the subnet.')
		privateEndpointNetworkPolicies: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.privateEndpointNetworkPolicies?
		@description('The network policies applied to private link services in the subnet.')
		privateLinkServiceNetworkPolicies: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.privateLinkServiceNetworkPolicies?
		@description('The route table associated with the subnet.')
		routeTable: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.routeTable?
		@description('An array of service endpoint policies.')
		serviceEndpointPolicies: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.serviceEndpointPolicies?
		@description('An array of service endpoints.')
		serviceEndpoints: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.serviceEndpoints?
		@description('Reference to an existing service gateway.')
		serviceGateway: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.serviceGateway?
		@description('The sharing scope of the subnet.')
		sharingScope: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-01-01'>.properties.sharingScope?
	}
}

/* EXISTING RESOURCES */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2026-01-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_virtualNetworks_subnets_ 'Microsoft.Network/virtualNetworks/subnets@2026-01-01' = {
	name: settings.name
	parent: Network_virtualNetworks_
	properties: {
		...settings.properties
		defaultOutboundAccess: false
	}
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_virtualNetworks_subnets_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworks_subnets_
	}
]

/* OUTPUTS */

@description('The ID.')
output id string = Network_virtualNetworks_subnets_.id

@description('The name.')
output name string = Network_virtualNetworks_subnets_.name
