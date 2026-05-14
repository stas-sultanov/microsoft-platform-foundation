metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a DNS Resolver Policy and assigns Insights Diagnostic extensions.'

/* IMPORTS */

import {
	Resource as InsightsDiagnosticSetting
} from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

type DnsSecurityRuleResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the DNS security rule.')
	properties: resourceInput<'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01'>.tags
}

type Resources = {
	@description('The array of virtual network links.')
	dnsSecurityRules: DnsSecurityRuleResource[]
	@description('The array of virtual network links.')
	virtualNetworkLinks: VirtualNetworkLinkResource[]
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
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The child resources settings.')
param resources Resources

@description('The tags.')
param tags resourceInput<'Microsoft.Network/dnsResolverPolicies@2025-05-01'>.tags

/* RESOURCES */

resource Network_dnsResolverPolicies_ 'Microsoft.Network/dnsResolverPolicies@2025-05-01' = {
	location: location
	name: name
	tags: tags
}

resource Network_dnsResolverPolicies_dnsSecurityRules_ 'Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2025-05-01' = [
	for resource in resources.dnsSecurityRules: {
		location: location
		name: resource.name
		parent: Network_dnsResolverPolicies_
		properties: resource.properties
		tags: resource.tags
	}
]

resource Network_dnsResolverPolicies_virtualNetworkLinks_ 'Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2025-05-01' = [
	for resource in resources.virtualNetworkLinks: {
		location: location
		name: resource.name
		parent: Network_dnsResolverPolicies_
		properties: resource.properties
		tags: resource.tags
	}
]

/* EXTENSIONS */

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Network_dnsResolverPolicies_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_dnsResolverPolicies_.id
