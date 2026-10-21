metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types and functions for Microsoft.Network/virtualNetworkGateways resources.'

/* TYPES */

@description('The BGP settings.')
@export()
@sealed()
type BgpSettings = {
	@description('The BGP autonomous system number.')
	@minValue(1)
	@maxValue(4294967294)
	asn: int?
	@description('Optional custom Azure APIPA BGP peering IPv4 addresses for each gateway instance. Azure permits 169.254.21.0 through 169.254.22.255; verify addresses against the remote peers.')
	@sealed()
	@validate(
		value =>
			value == null || sys.empty(sys.intersection(
				value!.Instance0,
				value!.Instance1
			)),
		'Custom BGP peering IP addresses must be unique across both instances.'
	)
	customBgpIpAddresses: {
		@description('Custom Azure APIPA BGP peering IPv4 addresses for the Instance 0.')
		@minLength(1)
		@validate(
			value =>
				IsValidCustomBgpIpAddresses(value),
			'Custom BGP peering IP addresses must be unique IPv4 addresses from 169.254.21.0 through 169.254.22.255.'
		)
		Instance0: string[]
		@description('Custom Azure APIPA BGP peering IPv4 addresses for the Instance 1.')
		@minLength(1)
		@validate(
			value =>
				IsValidCustomBgpIpAddresses(value),
			'Custom BGP peering IP addresses must be unique IPv4 addresses from 169.254.21.0 through 169.254.22.255.'
		)
		Instance1: string[]
	}?
}

@description('The configurable public IP and subnet references for a gateway IP configuration.')
@export()
@sealed()
type IpConfiguration = {
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
type NatRuleResource = {
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
	input IpConfiguration
) resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.properties.ipConfigurations[*] => {
	name: name
	properties: {
		privateIPAllocationMethod: 'Dynamic'
		publicIPAddress: input.publicIPAddress
		subnet: input.subnet
	}
}

@description('Checks whether the provided value is a valid custom BGP peering IPv4 address within the range 169.254.21.0 through 169.254.22.255.')
@export()
func IsValidCustomBgpIpAddress(
	address string
) bool =>
	(sys.startsWith(
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
	)

@description('Checks whether the provided values are unique, valid custom BGP peering IPv4 addresses within the range 169.254.21.0 through 169.254.22.255. An empty array is valid.')
@export()
func IsValidCustomBgpIpAddresses(
	addresses string[]
) bool =>
	sys.length(sys.union(
		addresses,
		[]
	)) == sys.length(addresses) && sys.empty(sys.filter(
		addresses,
		address =>
			!IsValidCustomBgpIpAddress(address)
	))
