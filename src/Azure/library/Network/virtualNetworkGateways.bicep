metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types and functions for Microsoft.Network/virtualNetworkGateways resources.'

/* IMPORTS */

import * as Common from '../common.bicep'

/* TYPES */

@description('Custom Azure APIPA BGP peering IPv4 addresses for one gateway IP configuration.')
@export()
@sealed()
type IPConfigurationBgpPeeringAddress = {
	@description('The list of custom BGP peering addresses which belong to IP configuration.')
	@minLength(1)
	@validate(
		value =>
			sys.length(sys.union(
				value,
				[]
			)) == sys.length(value) && sys.empty(sys.filter(
				value,
				address =>
					!((sys.startsWith(
						address,
						'169.254.21.'
					) || sys.startsWith(
						address,
						'169.254.22.'
					)) && sys.contains(
						sys.map(
							sys.range(
								0,
								256
							),
							n =>
								sys.string(n)
						),
						sys.substring(
							address,
							11
						)
					))
			)),
		'Custom BGP peering IP addresses must be unique IPv4 addresses from 169.254.21.0 through 169.254.22.255.'
	)
	customBgpIpAddresses: string[]
}

@description('The configuration of a virtual network gateway IP configuration.')
@export()
@sealed()
type IpConfigurationResource = {
	@description('The name.')
	@minLength(1)
	name: string
	@description('The properties.')
	@sealed()
	properties: {
		@description('The private IP allocation method.')
		privateIPAllocationMethod: 'Dynamic'
		@description('The reference to a Standard, Static public IP address resource.')
		publicIPAddress: Common.ReferenceById
		@description('The reference to the subnet resource named GatewaySubnet.')
		@validate(
			value =>
				sys.endsWith(
					sys.toLower(value.id),
					'/GatewaySubnet'
				),
			'The subnet name must be "GatewaySubnet".'
		)
		subnet: Common.ReferenceById
	}
}

@description('The configuration of a Microsoft.Network/virtualNetworkGateways/natRules resource.')
@export()
@sealed()
type NatRuleResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the virtual network gateway NAT rule.')
	properties: resourceInput<'Microsoft.Network/virtualNetworkGateways/natRules@2026-03-01'>.properties
}

/* FUNCTIONS */

@description('Creates a BGP peering address configuration with custom APIPA addresses for a gateway IP configuration.')
@export()
func CreateBgpPeeringAddress(
	gatewayName string,
	ipConfigurationName string,
	customBgpIpAddresses string[]
) resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-03-01'>.properties.bgpSettings.bgpPeeringAddresses[*] => {
	customBgpIpAddresses: customBgpIpAddresses
	ipconfigurationId: az.resourceId(
		'Microsoft.Network/virtualNetworkGateways/ipConfigurations',
		gatewayName,
		ipConfigurationName
	)
}
