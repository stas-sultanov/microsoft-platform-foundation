metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a private DNS zone.'

/* IMPORTS */

import * as NetworkDnsZones from '../../../library/Network/dnsZones.bicep'

/* TYPES */

@sealed()
type Resources = {
	@description('The array of virtual network links.')
	A: NetworkDnsZones.ARecord[]
	@description('The array of virtual network links.')
	virtualNetworkLinks: VirtualNetworkLinkResource[]
}

@sealed()
type VirtualNetworkLinkResource = {
	@description('The resource name.')
	name: string
	@description('Properties of the virtual network link to the Private DNS zone.')
	properties: resourceInput<'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'>.tags
}

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The child resources settings.')
param resources Resources

@description('The tags.')
param tags resourceInput<'Microsoft.Network/privateDnsZones@2024-06-01'>.tags

/* RESOURCES */

resource Network_privateDnsZones_ 'Microsoft.Network/privateDnsZones@2024-06-01' = {
	location: location
	name: name
	tags: tags
}

resource Network_privateDnsZones_A_ 'Microsoft.Network/privateDnsZones/A@2024-06-01' = [
	for aRecord in resources.A: {
		parent: Network_privateDnsZones_
		name: aRecord.name
		properties: {
			aRecords: sys.map(
				aRecord.values,
				value => {
					ipv4Address: value
				}
			)
			ttl: aRecord.ttl
		}
	}
]

resource Network_privateDnsZones_virtualNetworkLinks_ 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [
	for resource in resources.virtualNetworkLinks: {
		location: location
		name: resource.name
		parent: Network_privateDnsZones_
		properties: resource.properties
		tags: resource.tags
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_privateDnsZones_.id
