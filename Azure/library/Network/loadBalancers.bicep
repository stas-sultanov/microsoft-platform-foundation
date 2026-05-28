metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/loadBalancers resources.'

/* TYPES */

@export()
@sealed()
type LoadBalancingRule = {
	@description('The name.')
	name: string
	@description('The configurable properties.')
	properties: {
		@description('Receive bidirectional TCP Reset on TCP flow idle timeout or unexpected connection termination. This element is only used when the protocol is set to TCP.')
		enableTcpReset: bool
		@description('The port. Note that value 0 enables "Any Port".')
		@maxValue(65534)
		@minValue(0)
		port: int
		@description('The reference to the transport protocol used by the load balancing rule.')
		protocol: resourceInput<'Microsoft.Network/loadBalancers/loadBalancingRules@2024-07-01'>.properties.protocol
	}
}

@export()
@sealed()
type PrivateFrontendIPConfigurationSettings = {
	@description('Properties of the frontend IP configuration.')
	properties: {
		@description('The private IP address of the IP configuration.')
		privateIPAddress: string
		@description('The reference to the subnet resource.')
		subnet: resourceInput<'Microsoft.Network/loadBalancers/frontendIPConfigurations@2024-07-01'>.properties.subnet
	}
	@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
	zones: resourceInput<'Microsoft.Network/loadBalancers/frontendIPConfigurations@2024-07-01'>.zones
}

@export()
@sealed()
type ProbeSettings = {
	@description('Properties of the probe.')
	properties: resourceInput<'Microsoft.Network/loadBalancers/probes@2024-07-01'>.properties
}

@export()
@sealed()
type PublicFrontendIPConfigurationSettings = {
	@description('Properties of frontend IP configuration.')
	properties: {
		@description('The private IP address of the IP configuration.')
		publicIPAddress: resourceInput<'Microsoft.Network/loadBalancers/frontendIPConfigurations@2024-07-01'>.properties.publicIPAddress
	}
}
