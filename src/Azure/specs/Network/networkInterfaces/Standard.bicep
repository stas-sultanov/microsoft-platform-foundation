metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkInterfaces resource for a standard virtual machine network interface without IP forwarding.'

/*
This spec provides a network interface for a virtual machine, such as the StandaloneLinux spec:
- Subnet: one existing subnet shared by all IP configurations
- IP configurations: IPv4 only; a required primary configuration and up to 255 optional secondaries
- IPv6 and dual-stack: not supported
- Private IP allocation: Dynamic or Static per IP configuration
- Public IP addresses: optional existing references; inbound access is controlled by network security groups
- Compatibility validation: consumer verifies referenced resource location, subnet address ranges, public IP IPv4 version and Standard SKU, backend pool compatibility, and guest OS configuration of secondary addresses
- NIC type: Standard
- IP forwarding: disabled
- Accelerated networking: required consumer choice; the VM size must support it
- DNS servers: inherited from the virtual network
- Network security group: optional
- Application security groups, load balancer backend pools, and application gateway backend pools: optional per IP configuration
- Load balancer inbound NAT rule associations: not supported; define inbound NAT rules that target a backend pool on the load balancer instead
- Private Link Service, gateway load balancer, virtual network TAP, and auxiliary mode: not supported
- Lifecycle: independent of the virtual machine; StandaloneLinux detaches the NIC when the VM is deleted
- Diagnostics: metrics only
*/

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as Common from '../../../library/common.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@description('The properties of an IPv4 IP configuration with one of the supported private IP address allocation methods.')
@discriminator('privateIPAllocationMethod')
@sealed()
type IPConfigurationProperties =
	| IPConfigurationPropertiesDynamic
	| IPConfigurationPropertiesStatic

@description('The properties of an IPv4 IP configuration with a dynamically allocated private IP address.')
@sealed()
type IPConfigurationPropertiesDynamic = {
	@description('The application gateway backend address pools.')
	applicationGatewayBackendAddressPools: Common.ReferenceById[]?
	@description('The application security groups.')
	applicationSecurityGroups: Common.ReferenceById[]?
	@description('The load balancer backend address pools.')
	loadBalancerBackendAddressPools: Common.ReferenceById[]?
	@description('The private IP address allocation method.')
	privateIPAllocationMethod: 'Dynamic'
	@description('The public IP address. It must be an IPv4 address with the Standard SKU.')
	publicIPAddress: Common.ReferenceById?
	@description('The subnet. It must be the same for all IP configurations of the network interface.')
	subnet: Common.ReferenceById
}

@description('The properties of an IPv4 IP configuration with a statically allocated private IP address.')
@sealed()
type IPConfigurationPropertiesStatic = {
	@description('The application gateway backend address pools.')
	applicationGatewayBackendAddressPools: Common.ReferenceById[]?
	@description('The application security groups.')
	applicationSecurityGroups: Common.ReferenceById[]?
	@description('The load balancer backend address pools.')
	loadBalancerBackendAddressPools: Common.ReferenceById[]?
	@description('The private IPv4 address within the subnet address range.')
	@minLength(1)
	privateIPAddress: string
	@description('The private IP address allocation method.')
	privateIPAllocationMethod: 'Static'
	@description('The public IP address. It must be an IPv4 address with the Standard SKU.')
	publicIPAddress: Common.ReferenceById?
	@description('The subnet. It must be the same for all IP configurations of the network interface.')
	subnet: Common.ReferenceById
}

@description('An IPv4 IP configuration of the network interface.')
@sealed()
type IPConfigurationResourceInput = {
	@description('The name. It must be unique within the network interface.')
	@minLength(1)
	@maxLength(80)
	name: string
	@description('The configurable properties.')
	properties: IPConfigurationProperties
}

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	@sealed()
	Insights: {
		@validate(
			value =>
				sys.empty(sys.filter(
					value,
					item =>
						!sys.empty(item.properties.?logs)
				)),
			'logs must be empty or omitted for network interface diagnostic settings.'
		)
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	@minLength(1)
	@maxLength(80)
	name: resourceInput<'Microsoft.Network/networkInterfaces@2026-03-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Specifies whether accelerated networking is enabled.')
		enableAcceleratedNetworking: bool
		@description('The IPv4 IP configurations.')
		@validate(
			value =>
				sys.length(sys.items(value)) <= 256 && sys.length(sys.union(
					sys.map(
						sys.items(value),
						item =>
							sys.toLower(item.value.name)
					),
					[]
				)) == sys.length(sys.items(value)) && sys.length(sys.union(
					sys.map(
						sys.items(value),
						item =>
							sys.toLower(item.value.properties.subnet.id)
					),
					[]
				)) == 1,
			'The number of IP configurations must not exceed 256. IP configuration names must be unique within the network interface, ignoring case. All IP configurations must use the same subnet.'
		)
		ipConfigurations: {
			@description('The required primary IP configuration.')
			Primary: IPConfigurationResourceInput
			@description('The optional secondary IP configurations.')
			*: IPConfigurationResourceInput
		}
		@description('The network security group associated with the network interface.')
		networkSecurityGroup: Common.ReferenceById?
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkInterfaces@2026-03-01'>.tags
}

/* RESOURCES */

resource Network_networkInterfaces_ 'Microsoft.Network/networkInterfaces@2026-03-01' = {
	location: settings.location
	name: settings.name
	properties: {
		enableAcceleratedNetworking: settings.properties.enableAcceleratedNetworking
		enableIPForwarding: false
		ipConfigurations: sys.concat(
			[
				{
					name: settings.properties.ipConfigurations.Primary.name
					properties: {
						...settings.properties.ipConfigurations.Primary.properties
						primary: true
						privateIPAddressVersion: 'IPv4'
					}
				}
			],
			sys.map(
				sys.filter(
					sys.items(settings.properties.ipConfigurations),
					item =>
						item.key != 'Primary'
				),
				item => {
					name: item.value.name
					properties: {
						...item.value.properties
						primary: false
						privateIPAddressVersion: 'IPv4'
					}
				}
			)
		)
		networkSecurityGroup: settings.properties.?networkSecurityGroup
		nicType: 'Standard'
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_networkInterfaces_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_networkInterfaces_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkInterfaces_
	}
]
