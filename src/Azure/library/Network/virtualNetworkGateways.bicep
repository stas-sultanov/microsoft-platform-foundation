metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types and functions for Microsoft.Network/virtualNetworkGateways resources.'

/* TYPES */

@description('A resource reference to a virtual network subnet named GatewaySubnet.')
@export()
@sealed()
type GatewaySubnetReference = {
	@description('The resource ID of the Microsoft.Network/virtualNetworks/subnets resource named GatewaySubnet.')
	@validate(
		value =>
			sys.endsWith(
				sys.toLower(value),
				'/subnets/gatewaysubnet'
			),
		'The subnet resource ID must refer to a subnet named GatewaySubnet.'
	)
	id: string
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
	publicIpAddressId string,
	subnetId string
) resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.properties.ipConfigurations[*] => {
	name: name
	properties: {
		privateIPAllocationMethod: 'Dynamic'
		publicIPAddress: {
			id: publicIpAddressId
		}
		subnet: {
			id: subnetId
		}
	}
}
