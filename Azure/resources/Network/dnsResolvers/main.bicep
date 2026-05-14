metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a DNS Resolver and Inbound Endpoints.'

/* TYPES */

type InboundEndpointResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the inbound endpoint.')
	properties: resourceInput<'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01'>.tags
}

type OutboundEndpointResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the outbound endpoint.')
	properties: resourceInput<'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01'>.tags
}

type Resources = {
	@description('The array of inbound endpoints.')
	inboundEndpoints: InboundEndpointResource[]
	@description('The array of outbound endpoints.')
	outboundEndpoints: OutboundEndpointResource[]
}

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Network/dnsResolvers@2024-07-01'>.properties

@description('The child resources settings.')
param resources Resources

@description('The tags.')
param tags resourceInput<'Microsoft.Network/dnsResolvers@2024-07-01'>.tags

/* RESOURCES */

resource Network_dnsResolvers_ 'Microsoft.Network/dnsResolvers@2025-05-01' = {
	location: location
	name: name
	properties: properties
	tags: tags
}

resource Network_dnsResolvers_inboundEndpoints_ 'Microsoft.Network/dnsResolvers/inboundEndpoints@2025-05-01' = [
	for resource in resources.inboundEndpoints: {
		location: location
		name: resource.name
		parent: Network_dnsResolvers_
		properties: resource.properties
		tags: resource.tags
	}
]

resource Network_dnsResolvers_outboundEndpoints_ 'Microsoft.Network/dnsResolvers/outboundEndpoints@2025-05-01' = [
	for resource in resources.outboundEndpoints: {
		location: location
		name: resource.name
		parent: Network_dnsResolvers_
		properties: resource.properties
		tags: resource.tags
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_dnsResolvers_.id

@description('The name.')
output name string = Network_dnsResolvers_.name
