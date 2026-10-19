metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types and functions for Microsoft.Network/virtualNetworkGateways resources.'

/* TYPES */

@description('The configurable public IP and subnet references for a gateway IP configuration.')
@export()
@sealed()
type IpConfigurationInput = {
	@description('The reference to a Standard, Static public IP address resource.')
	@sealed()
	publicIPAddress: {
		@description('The resource ID of the Microsoft.Network/publicIPAddresses resource.')
		@validate(
			value =>
				sys.like(
					value,
					'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/publicIPAddresses/*'
				),
			'The value must be a Microsoft.Network/publicIPAddresses resource ID.'
		)
		id: string
	}
	@description('The reference to the subnet resource.')
	@sealed()
	subnet: {
		@description('The resource ID of the Microsoft.Network/virtualNetworks/subnets resource named GatewaySubnet.')
		@validate(
			value =>
				sys.like(
					value,
					'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/virtualNetworks/*/subnets/GatewaySubnet'
				),
			'The value must be a Microsoft.Network/virtualNetworks/subnets resource ID of the subnet named GatewaySubnet.'
		)
		id: string
	}
}

@description('The configuration of a Microsoft.Network/virtualNetworkGateways/natRules resource.')
@export()
@sealed()
type NatRuleChildResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the virtual network gateway NAT rule.')
	properties: resourceInput<'Microsoft.Network/virtualNetworkGateways/natRules@2026-01-01'>.properties
}

/* FUNCTIONS */

@description('Creates a BGP peering address configuration with custom APIPA addresses for a gateway IP configuration.')
@export()
func CreateBgpPeeringAddress(
	gatewayName string,
	ipConfigurationName string,
	customBgpIpAddresses string[]
) resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.properties.bgpSettings.bgpPeeringAddresses[*] => {
	customBgpIpAddresses: customBgpIpAddresses
	ipconfigurationId: az.resourceId(
		'Microsoft.Network/virtualNetworkGateways/ipConfigurations',
		gatewayName,
		ipConfigurationName
	)
}

@description('Creates a gateway IP configuration with a public IP address and dynamically allocated private IP address.')
@export()
func CreateIpConfiguration(
	name string,
	input IpConfigurationInput
) resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.properties.ipConfigurations[*] => {
	name: name
	properties: {
		privateIPAllocationMethod: 'Dynamic'
		publicIPAddress: input.publicIPAddress
		subnet: input.subnet
	}
}
