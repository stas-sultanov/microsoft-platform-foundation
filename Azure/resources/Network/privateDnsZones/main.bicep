metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a private DNS zone.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as NetworkDnsZones from '../../../library/Network/dnsZones.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
}

@description('The child resources.')
@sealed()
param resources {
	@description('The array of virtual network links.')
	A: {
		*: NetworkDnsZones.ARecord
	}
	@description('The array of virtual network links.')
	virtualNetworkLinks: {
		*: {
			@description('The resource name.')
			name: string
			@description('Properties of the virtual network link to the Private DNS zone.')
			properties: resourceInput<'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'>.properties
			@description('The tags.')
			tags: resourceInput<'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'>.tags
		}
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/privateDnsZones@2024-06-01'>.name
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/privateDnsZones@2024-06-01'>.tags
}

/* RESOURCES */

resource Network_privateDnsZones_ 'Microsoft.Network/privateDnsZones@2024-06-01' = {
	location: settings.location
	name: settings.name
	tags: settings.tags
}

resource Network_privateDnsZones_A_ 'Microsoft.Network/privateDnsZones/A@2024-06-01' = [
	for item in items(resources.A): {
		parent: Network_privateDnsZones_
		name: item.value.name
		properties: {
			aRecords: sys.map(
				item.value.values,
				value => {
					ipv4Address: value
				}
			)
			ttl: item.value.ttl
		}
	}
]

resource Network_privateDnsZones_virtualNetworkLinks_ 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [
	for item in items(resources.virtualNetworkLinks): {
		location: settings.location
		name: item.value.name
		parent: Network_privateDnsZones_
		properties: item.value.properties
		tags: item.value.tags
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_privateDnsZones_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_privateDnsZones_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_privateDnsZones_.id
