metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
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

@description('The parent name.')
param parentName string

/* EXISTING RESOURCES */

resource Network_dnsZones_ 'Microsoft.Network/dnsZones@2018-05-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_privateDnsZones_A_ 'Microsoft.Network/dnsZones/A@2018-05-01' = [
	for record in A: {
		parent: Network_dnsZones_
		name: record.name
		properties: {
			ARecords: sys.map(
				record.values,
				value => {
					ipv4Address: value
				}
			)
			TTL: record.ttl
		}
	}
]

resource Network_privateDnsZones_NS_ 'Microsoft.Network/dnsZones/NS@2018-05-01' = [
	for record in NS: {
		parent: Network_dnsZones_
		name: record.name
		properties: {
			NSRecords: sys.map(
				record.values,
				value => {
					nsdname: value
				}
			)
			TTL: record.ttl
		}
	}
]
