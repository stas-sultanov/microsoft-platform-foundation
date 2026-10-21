metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/localNetworkGateways resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as NetworkLocalNetworkGateways from '../../../library/Network/localNetworkGateways.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.name
	@description('The configurable properties.')
	properties: NetworkLocalNetworkGateways.PropertiesInput
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.tags
}

/* RESOURCES */

resource Network_localNetworkGateways_ 'Microsoft.Network/localNetworkGateways@2026-01-01' = {
	location: settings.location
	name: settings.name
	properties: {
		bgpSettings: settings.properties.?bgpSettings
		fqdn: settings.properties.?fqdn
		gatewayIpAddress: settings.properties.?gatewayIpAddress
		localNetworkAddressSpace: settings.properties.?localNetworkAddressSpace
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_localNetworkGateways_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_localNetworkGateways_
	}
]
