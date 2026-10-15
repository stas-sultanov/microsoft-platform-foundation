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
	@sealed()
	@validate(
		value =>
			value.publicIPAddressVersion == 'IPv4'
				? value.prefixLength <= 32 && (value.?customIPPrefix != null || (value.prefixLength >= 28 && value.prefixLength <= 31))
				: value.?customIPPrefix != null || (value.prefixLength >= 124 && value.prefixLength <= 127),
		'Azure-assigned prefixes require IPv4 /28-/31 or IPv6 /124-/127.'
	)
	properties: {
		@description('The customIpPrefix that this prefix is associated with.')
		customIPPrefix: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.properties.customIPPrefix?
		@description('The IP tags for the public IP prefix.')
		ipTags: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.properties.ipTags?
		@description('The CIDR prefix length.')
		@minValue(1)
		@maxValue(128)
		prefixLength: int
		@description('The public IP address version.')
		publicIPAddressVersion:
			| 'IPv4'
			| 'IPv6'
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/publicIPPrefixes@2026-01-01'>.tags
	@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
	@minLength(1)
	@maxLength(3)
	@validate(
		value =>
			value == null || sys.length(value!) == 1 || value == [
				'1'
				'2'
				'3'
			],
		'Specify null, one zone, or exactly [\'1\', \'2\', \'3\'].'
	)
	zones: (
		| '1'
		| '2'
		| '3')[]?
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

/* OUTPUTS */

@description('The ID.')
output id string = Network_publicIPPrefixes_.id

@description('The name.')
output name string = Network_publicIPPrefixes_.name
