metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/dnsResolverPolicies resource with extensions.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

type DnsSecurityRuleResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the DNS security rule.')
	properties: resourceInput<'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01'>.tags
}

type VirtualNetworkLinkResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the DNS resolver policy virtual network link.')
	properties: resourceInput<'Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01'>.tags
}

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
param name resourceInput<'Microsoft.Network/dnsResolverPolicies@2025-05-01'>.name

@description('The child resources.')
param resources {
	@description('The DNS security rules.')
	dnsSecurityRules: {
		*: DnsSecurityRuleResource
	}
	@description('The virtual network links.')
	virtualNetworkLinks: {
		*: VirtualNetworkLinkResource
	}
}

@description('The tags.')
param tags resourceInput<'Microsoft.Network/dnsResolverPolicies@2025-05-01'>.tags

/* RESOURCES */

resource Network_dnsResolverPolicies_ 'Microsoft.Network/dnsResolverPolicies@2025-05-01' = {
	location: location
	name: name
	tags: tags
}

resource Network_dnsResolverPolicies_dnsSecurityRules_ 'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01' = [
	for item in items(resources.dnsSecurityRules): {
		location: location
		name: item.value.name
		parent: Network_dnsResolverPolicies_
		properties: item.value.properties
		tags: item.value.tags
	}
]

resource Network_dnsResolverPolicies_virtualNetworkLinks_ 'Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01' = [
	for item in items(resources.virtualNetworkLinks): {
		location: location
		name: item.value.name
		parent: Network_dnsResolverPolicies_
		properties: item.value.properties
		tags: item.value.tags
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_dnsResolverPolicies_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_dnsResolverPolicies_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_dnsResolverPolicies_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_dnsResolverPolicies_.id
