metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/publicIPAddresses resource with extensions.'

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
	name: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The DDoS protection custom policy associated with the public IP address.')
		ddosSettings: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ddosSettings?
		@description('Specifies what happens to the public IP address when the VM using it is deleted.')
		deleteOption: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.deleteOption?
		@description('The FQDN of the DNS record associated with the public IP address.')
		dnsSettings: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.dnsSettings?
		@description('The idle timeout of the public IP address.')
		idleTimeoutInMinutes: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.idleTimeoutInMinutes?
		@description('The IP address associated with the public IP address resource.')
		ipAddress: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ipAddress?
		@description('The list of tags associated with the public IP address.')
		ipTags: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.ipTags?
		@description('The linked public IP address of the public IP address resource.')
		linkedPublicIPAddress: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.linkedPublicIPAddress?
		@description('The migration phase of the public IP address.')
		migrationPhase: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.migrationPhase?
		@description('The NAT gateway for the public IP address.')
		natGateway: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.natGateway?
		@description('The public IP address version.')
		publicIPAddressVersion: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.publicIPAddressVersion?
		@description('The public IP prefix this public IP address should be allocated from.')
		publicIPPrefix: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.publicIPPrefix?
		@description('The service public IP address of the public IP address resource.')
		servicePublicIPAddress: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.properties.servicePublicIPAddress?
	}?
	@description('The SKU.')
	@sealed()
	sku: {
		@description('The name of the SKU.')
		name:
			| 'Standard'
			| 'StandardV2'
		@description('The tier of the SKU.')
		tier: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.sku.tier?
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/publicIPAddresses@2026-01-01'>.tags
	@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
	@minLength(1)
	@maxLength(3)
	@validate(
		value =>
			length(value ?? []) == length(union(
				value ?? [],
				[]
			)),
		'Availability zones must be unique.'
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
	sku: settings.sku
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
