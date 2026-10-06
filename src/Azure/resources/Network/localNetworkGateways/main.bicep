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
	@validate(
		value =>
			(value.?fqdn != null) != (value.?gatewayIpAddress != null),
		'Either fqdn or gatewayIpAddress must be specified.'
	)
	properties: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.tags
}

/* RESOURCES */

resource Network_localNetworkGateways_ 'Microsoft.Network/localNetworkGateways@2026-01-01' = {
	location: settings.location
	name: settings.name
	properties: settings.properties
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

/* OUTPUTS */

@description('The ID.')
output id string = Network_localNetworkGateways_.id

@description('The name.')
output name string = Network_localNetworkGateways_.name
