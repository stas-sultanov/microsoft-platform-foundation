metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions resources within the DNS Zone.'

/* IMPORTS */

import {
	ARecord
	NSRecord
} from '../../../library/Network/dnsZones.bicep'

/* PARAMETERS */

@description('The A records.')
param A ARecord[] = []

@description('The NS records.')
param NS NSRecord[] = []

@description('The name of the parent Microsoft.Network/dnsZones resource.')
param parentName string

/* EXISTING RESOURCES */

resource Network_dnsZones_ 'Microsoft.Network/dnsZones@2018-05-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_dnsZones_A_ 'Microsoft.Network/dnsZones/A@2018-05-01' = [
	for item in A: {
		parent: Network_dnsZones_
		name: item.name
		properties: {
			ARecords: sys.map(
				item.values,
				value => {
					ipv4Address: value
				}
			)
			TTL: item.ttl
		}
	}
]

resource Network_dnsZones_NS_ 'Microsoft.Network/dnsZones/NS@2018-05-01' = [
	for item in NS: {
		parent: Network_dnsZones_
		name: item.name
		properties: {
			NSRecords: sys.map(
				item.values,
				value => {
					nsdname: value
				}
			)
			TTL: item.ttl
		}
	}
]
