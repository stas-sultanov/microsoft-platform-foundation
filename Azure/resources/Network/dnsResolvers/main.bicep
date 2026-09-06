metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a DNS Resolver and Inbound Endpoints.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The child resources.')
@sealed()
param resources {
	@description('The inbound endpoints.')
	inboundEndpoints: {
		*: {
			@description('The resource name.')
			name: string
			@description('Properties of the inbound endpoint.')
			properties: resourceInput<'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01'>.properties
			@description('The tags.')
			tags: resourceInput<'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01'>.tags
		}
	}
	@description('The outbound endpoints.')
	outboundEndpoints: {
		*: {
			@description('The resource name.')
			name: string
			@description('Properties of the outbound endpoint.')
			properties: resourceInput<'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01'>.properties
			@description('The tags.')
			tags: resourceInput<'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01'>.tags
		}
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/dnsResolvers@2025-05-01'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.Network/dnsResolvers@2025-05-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/dnsResolvers@2025-05-01'>.tags
}

/* RESOURCES */

resource Network_dnsResolvers_ 'Microsoft.Network/dnsResolvers@2025-05-01' = {
	location: settings.location
	name: settings.name
	properties: settings.properties
	tags: settings.tags
}

resource Network_dnsResolvers_inboundEndpoints_ 'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01' = [
	for item in items(resources.inboundEndpoints): {
		location: settings.location
		name: item.value.name
		parent: Network_dnsResolvers_
		properties: item.value.properties
		tags: item.value.tags
	}
]

resource Network_dnsResolvers_outboundEndpoints_ 'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01' = [
	for item in items(resources.outboundEndpoints): {
		location: settings.location
		name: item.value.name
		parent: Network_dnsResolvers_
		properties: item.value.properties
		tags: item.value.tags
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_dnsResolvers_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_dnsResolvers_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_dnsResolvers_.id

@description('The name.')
output name string = Network_dnsResolvers_.name
