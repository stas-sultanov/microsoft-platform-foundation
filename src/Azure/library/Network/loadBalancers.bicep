metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/loadBalancers resources.'

/* TYPES */

@description('The load balancing rule child resource.')
@export()
@sealed()
type LoadBalancingRule = {
	@description('The name.')
	name: string
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Receive bidirectional TCP Reset on TCP flow idle timeout or unexpected connection termination. This element is only used when the protocol is set to TCP.')
		enableTcpReset: bool
		@description('The port. Note that value 0 enables "Any Port".')
		@maxValue(65534)
		@minValue(0)
		port: int
		@description('The reference to the transport protocol used by the load balancing rule.')
		protocol: resourceInput<'Microsoft.Network/loadBalancers/loadBalancingRules@2025-09-01'>.properties.protocol
	}
}

@description('The private frontend IP configuration child resource.')
@export()
@sealed()
type PrivateFrontendIPConfigurationSettings = {
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The private IP address of the IP configuration.')
		privateIPAddress: string
		@description('The reference to the subnet resource.')
		subnet: resourceInput<'Microsoft.Network/loadBalancers/frontendIPConfigurations@2025-09-01'>.properties.subnet
	}
	@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
	zones: resourceInput<'Microsoft.Network/loadBalancers/frontendIPConfigurations@2025-09-01'>.zones
}

@description('The probe child resource.')
@export()
@sealed()
type ProbeSettings = {
	@description('Properties of the probe.')
	properties: resourceInput<'Microsoft.Network/loadBalancers/probes@2025-09-01'>.properties
}

@description('The public frontend IP configuration child resource.')
@export()
@sealed()
type PublicFrontendIPConfigurationSettings = {
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The private IP address of the IP configuration.')
		publicIPAddress: resourceInput<'Microsoft.Network/loadBalancers/frontendIPConfigurations@2025-09-01'>.properties.publicIPAddress
	}
}
