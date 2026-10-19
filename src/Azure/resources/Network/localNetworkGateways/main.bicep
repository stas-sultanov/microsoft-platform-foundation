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
	@sealed()
	@validate(
		value =>
			(value.?fqdn != null) != (value.?gatewayIpAddress != null),
		'Either fqdn or gatewayIpAddress must be specified.'
	)
	properties: {
		@description('The local network gateway BGP speaker settings.')
		@sealed()
		bgpSettings: {
			@description('The autonomous system number of the on-premises BGP speaker. Azure VPN Gateway FAQ reserved ASNs are not allowed. Must differ from the connected Azure VPN gateway ASN.')
			@minValue(1)
			@maxValue(4294967294)
			@validate(
				value =>
					!sys.contains(
						[
							8074
							8075
							12076
							23456
							65515
							65517
							65518
							65519
							65520
							429496729
						],
						value
					) && (value < 64496 || value > 64511) && (value < 65535 || value > 65551),
				'The ASN must not be reserved by Azure or IANA according to the Azure VPN Gateway FAQ: 8074, 8075, 12076, 23456, 64496-64511, 65515, 65517-65520, 65535-65551, or 429496729.'
			)
			asn: int
			@description('The BGP peering address and identifier of the BGP speaker.')
			bgpPeeringAddress: string
			@description('The weight added to routes learned from the BGP speaker.')
			peerWeight: int?
		}?
		@description('The FQDN of the local network gateway. Specify either fqdn or gatewayIpAddress, but not both.')
		fqdn: string?
		@description('The IP address of the local network gateway. Specify either fqdn or gatewayIpAddress, but not both.')
		gatewayIpAddress: string?
		@description('The address space of the local network site.')
		localNetworkAddressSpace: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.properties.localNetworkAddressSpace?
	}
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
