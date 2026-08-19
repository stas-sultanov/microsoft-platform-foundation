metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Virtual Network and assigns Insights Diagnostic extensions.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties {
	@description('Address space contains an array of IP address ranges that can be used by subnets in the virtual network.')
	addressSpace: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.addressSpace?
	@description('The BGP community associated with the virtual network.')
	bgpCommunities: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.bgpCommunities?
	@description('The DDoS protection plan associated with the virtual network.')
	ddosProtectionPlan: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.ddosProtectionPlan?
	@description('The DHCP options associated with the virtual network.')
	dhcpOptions: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.dhcpOptions?
	@description('Indicates whether DDoS protection is enabled for all the protected resources in the virtual network.')
	enableDdosProtection: bool?
	@description('Indicates whether VM protection is enabled for all the subnets in the virtual network.')
	enableVmProtection: bool?
	@description('The encryption settings for the virtual network.')
	encryption: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.encryption?
	@description('The flow timeout for the virtual network in minutes.')
	flowTimeoutInMinutes: int?
	@description('The IP allocations associated with the virtual network.')
	ipAllocations: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.ipAllocations?
	@description('Indicates whether the private endpoint network policies are enabled for the virtual network.')
	privateEndpointVNetPolicies: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.privateEndpointVNetPolicies?
	@description('A configurable list of summarized gateway prefixes advertised for the virtual network.')
	summarizedGatewayPrefixes: resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.properties.summarizedGatewayPrefixes?
}

@description('The tags.')
param tags resourceInput<'Microsoft.Network/virtualNetworks@2025-07-01'>.tags

/* RESOURCES */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2025-07-01' = {
	location: location
	name: name
	properties: properties
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_virtualNetworks_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworks_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworks_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_virtualNetworks_.id

@description('The name.')
output name string = Network_virtualNetworks_.name
