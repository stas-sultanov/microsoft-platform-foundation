metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a regional Standard v1 Microsoft.Network/publicIPAddresses resource with an Azure-assigned static IP address and extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@description('The configurable properties for a regional public IP address.')
@discriminator('publicIPAddressVersion')
type PublicIPAddressPropertiesInput =
	| PublicIPAddressPropertiesIPv4Input
	| PublicIPAddressPropertiesIPv6Input

@description('The configurable properties for an IPv4 regional public IP address.')
@sealed()
type PublicIPAddressPropertiesIPv4Input = {
	@description('The DDoS protection custom policy associated with the public IP address.')
	ddosSettings: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ddosSettings?
	@description('The optional DNS settings. When supplied, both the domain name label and its reuse scope are required.')
	@sealed()
	dnsSettings: {
		@description('The domain name label used to generate the Azure-managed FQDN.')
		@minLength(1)
		domainNameLabel: string
		@description('The reuse scope for the generated domain name label. Can only be set at creation.')
		domainNameLabelScope: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.dnsSettings.domainNameLabelScope
		@description('The reverse FQDN used to create an IPv4 PTR record.')
		reverseFqdn: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.dnsSettings.reverseFqdn?
	}?
	@description('The inbound idle timeout in minutes.')
	@minValue(4)
	@maxValue(30)
	idleTimeoutInMinutes: int?
	@description('The list of tags associated with the public IP address.')
	ipTags: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ipTags?
	@description('The public IP address version.')
	publicIPAddressVersion: 'IPv4'
	@description('The public IP prefix this public IP address should be allocated from.')
	publicIPPrefix: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.publicIPPrefix?
}

@description('The configurable properties for an IPv6 regional public IP address.')
@sealed()
type PublicIPAddressPropertiesIPv6Input = {
	@description('The DDoS protection custom policy associated with the public IP address.')
	ddosSettings: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ddosSettings?
	@description('The optional DNS settings. When supplied, both the domain name label and its reuse scope are required.')
	@sealed()
	dnsSettings: {
		@description('The domain name label used to generate the Azure-managed FQDN.')
		@minLength(1)
		domainNameLabel: string
		@description('The reuse scope for the generated domain name label. Can only be set at creation.')
		domainNameLabelScope: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.dnsSettings.domainNameLabelScope
	}?
	@description('The list of tags associated with the public IP address.')
	ipTags: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ipTags?
	@description('The public IP address version.')
	publicIPAddressVersion: 'IPv6'
	@description('The public IP prefix this public IP address should be allocated from.')
	publicIPPrefix: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.publicIPPrefix?
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
	name: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.name
	@description('The configurable properties.')
	@validate(
		value =>
			value.?publicIPAddressVersion != 'IPv6' || sys.empty(sys.filter(
				value.?ipTags ?? [],
				tag =>
					tag.?ipTagType == 'RoutingPreference' && tag.?tag == 'Internet'
			)),
		'Internet routing preference is not supported for IPv6 public IP addresses.'
	)
	properties: PublicIPAddressPropertiesInput?
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.tags
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

resource Network_publicIPAddresses_ 'Microsoft.Network/publicIPAddresses@2026-01-01' = {
	location: settings.location
	name: settings.name
	properties: {
		...(settings.?properties ?? {})
		publicIPAllocationMethod: 'Static'
	}
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
		Network_publicIPAddresses_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_publicIPAddresses_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_publicIPAddresses_
	}
]

/* OUTPUTS */

@description('The ID.')
output id string = Network_publicIPAddresses_.id

@description('The name.')
output name string = Network_publicIPAddresses_.name
