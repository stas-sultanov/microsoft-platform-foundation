metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a regional Standard v1 Microsoft.Network/publicIPPrefixes resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@description('The configurable properties for a regional public IP prefix.')
@discriminator('publicIPAddressVersion')
type PublicIPPrefixPropertiesInput =
	| PublicIPPrefixPropertiesIPv4Input
	| PublicIPPrefixPropertiesIPv6Input

@description('The configurable properties for an IPv4 regional public IP prefix.')
@sealed()
type PublicIPPrefixPropertiesIPv4Input = {
	@description('The list of tags associated with the public IP prefix.')
	ipTags: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.properties.ipTags?
	@description('The CIDR prefix length.')
	@minValue(28)
	@maxValue(31)
	prefixLength: int
	@description('The public IP address version.')
	publicIPAddressVersion: 'IPv4'
}

@description('The configurable properties for an IPv6 regional public IP prefix.')
@sealed()
type PublicIPPrefixPropertiesIPv6Input = {
	@description('The list of tags associated with the public IP prefix.')
	@validate(
		value =>
			sys.empty(sys.filter(
				value ?? [],
				tag =>
					tag.?ipTagType == 'RoutingPreference' && tag.?tag == 'Internet'
			)),
		'Internet routing preference requires an IPv4 public IP prefix.'
	)
	ipTags: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.properties.ipTags?
	@description('The CIDR prefix length.')
	@minValue(124)
	@maxValue(127)
	prefixLength: int
	@description('The public IP address version.')
	publicIPAddressVersion: 'IPv6'
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
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.name
	@description('The configurable properties.')
	properties: PublicIPPrefixPropertiesInput
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.tags
	@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
	zones:
		| [
			'1'
		]
		| [
			'2'
		]
		| [
			'3'
		]
		| [
			'1'
			'2'
			'3'
		]
		| null
}

/* RESOURCES */

resource Network_publicIPPrefixes_ 'Microsoft.Network/publicIPPrefixes@2026-01-01' = {
	location: settings.location
	name: settings.name
	properties: settings.properties
	sku: {
		name: 'Standard'
		tier: 'Regional'
	}
	tags: settings.tags
	zones: settings.?zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_publicIPPrefixes_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_publicIPPrefixes_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_publicIPPrefixes_
	}
]
