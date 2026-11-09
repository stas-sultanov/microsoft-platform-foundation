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

import * as Common from '../../../../library/common.bicep'

/* TYPES */

@description('An IPAM pool allocation for subnet address prefixes.')
@sealed()
type IpamPoolPrefixAllocation = {
	@description('The number of IP addresses to allocate.')
	numberOfIpAddresses: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.ipamPoolPrefixAllocations[*].numberOfIpAddresses?
	@description('The IPAM pool providing the address allocation.')
	@validate(
		value =>
			value == null || Common.IsReferenceTo(
				'Microsoft.Network/networkManagers/ipamPools',
				value!.id
			),
		'The value must be a Microsoft.Network/networkManagers/ipamPools resource ID.'
	)
	pool: Common.ReferenceById?
}

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
param parentName resourceInput<'Microsoft.Network/virtualNetworks@2026-03-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	name: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.name
	@description('The configurable properties.')
	@sealed()
	@validate(
		value =>
			sys.empty(value.?addressPrefixes) != sys.empty(value.?ipamPoolPrefixAllocations),
		'Exactly one of addressPrefixes or ipamPoolPrefixAllocations must be specified and nonempty.'
	)
	properties: {
		@description('The subnet address prefixes in CIDR notation. Mutually exclusive with ipamPoolPrefixAllocations.')
		addressPrefixes: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.addressPrefixes?
		@description('The service delegations for the subnet.')
		delegations: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.delegations?
		@description('The array of IpAllocation which reference this subnet.')
		@validate(
			value =>
				sys.empty(sys.filter(
					value ?? [],
					item =>
						!Common.IsReferenceTo(
							'Microsoft.Network/ipAllocations',
							item.id
						)
				)),
			'Each value must be a Microsoft.Network/ipAllocations resource ID.'
		)
		ipAllocations: Common.ReferenceById[]?
		@description('The IPAM pools allocating the subnet address prefixes. Mutually exclusive with addressPrefixes.')
		ipamPoolPrefixAllocations: IpamPoolPrefixAllocation[]?
		@description('The NAT gateway associated with the subnet.')
		@validate(
			value =>
				value == null || Common.IsReferenceTo(
					'Microsoft.Network/natGateways',
					value!.id
				),
			'The value must be a Microsoft.Network/natGateways resource ID.'
		)
		natGateway: Common.ReferenceById?
		@description('The network security group associated with the subnet.')
		@validate(
			value =>
				value == null || Common.IsReferenceTo(
					'Microsoft.Network/networkSecurityGroups',
					value!.id
				),
			'The value must be a Microsoft.Network/networkSecurityGroups resource ID.'
		)
		networkSecurityGroup: Common.ReferenceById?
		@description('The network policies applied to private endpoints in the subnet.')
		privateEndpointNetworkPolicies: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.privateEndpointNetworkPolicies?
		@description('The network policies applied to private link services in the subnet.')
		privateLinkServiceNetworkPolicies: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.privateLinkServiceNetworkPolicies?
		@description('The route table associated with the subnet.')
		@validate(
			value =>
				value == null || Common.IsReferenceTo(
					'Microsoft.Network/routeTables',
					value!.id
				),
			'The value must be a Microsoft.Network/routeTables resource ID.'
		)
		routeTable: Common.ReferenceById?
		@description('An array of service endpoint policies.')
		@validate(
			value =>
				sys.empty(sys.filter(
					value ?? [],
					item =>
						!Common.IsReferenceTo(
							'Microsoft.Network/serviceEndpointPolicies',
							item.id
						)
				)),
			'Each value must be a Microsoft.Network/serviceEndpointPolicies resource ID.'
		)
		serviceEndpointPolicies: Common.ReferenceById[]?
		@description('An array of service endpoints.')
		serviceEndpoints: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.serviceEndpoints?
		@description('Reference to an existing service gateway.')
		@validate(
			value =>
				value == null || Common.IsReferenceTo(
					'Microsoft.Network/serviceGateways',
					value!.id
				),
			'The value must be a Microsoft.Network/serviceGateways resource ID.'
		)
		serviceGateway: Common.ReferenceById?
		@description('The sharing scope of the subnet.')
		sharingScope: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2026-03-01'>.properties.sharingScope?
	}
}

/* EXISTING RESOURCES */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2026-03-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_virtualNetworks_subnets_ 'Microsoft.Network/virtualNetworks/subnets@2026-03-01' = {
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
