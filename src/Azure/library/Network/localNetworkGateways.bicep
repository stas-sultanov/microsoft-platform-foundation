metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/localNetworkGateways resources.'

/* TYPES */

@description('The BGP speaker settings for the local network gateway.')
@sealed()
type BgpSettingsInput = {
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
}

@description('The local network gateway properties for one of the supported BGP and endpoint configurations.')
@discriminator('configuration')
@export()
@sealed()
type PropertiesInput =
	| BgpWithFqdnInput
	| BgpWithIpInput
	| StaticWithFqdnInput
	| StaticWithIpInput

@description('A local network gateway using BGP and an FQDN endpoint.')
@sealed()
type BgpWithFqdnInput = {
	@description('The selected BGP and endpoint configuration.')
	configuration: 'BgpWithFqdn'
	@description('The local network gateway BGP speaker settings.')
	bgpSettings: BgpSettingsInput
	@description('The FQDN of the local network gateway.')
	fqdn: string
	@description('The address space of the local network site.')
	localNetworkAddressSpace: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.properties.localNetworkAddressSpace?
}

@description('A local network gateway using BGP and an IP address endpoint.')
@sealed()
type BgpWithIpInput = {
	@description('The selected BGP and endpoint configuration.')
	configuration: 'BgpWithIp'
	@description('The local network gateway BGP speaker settings.')
	bgpSettings: BgpSettingsInput
	@description('The IP address of the local network gateway.')
	gatewayIpAddress: string
	@description('The address space of the local network site.')
	localNetworkAddressSpace: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.properties.localNetworkAddressSpace?
}

@description('A local network gateway using static routing and an FQDN endpoint.')
@sealed()
type StaticWithFqdnInput = {
	@description('The selected BGP and endpoint configuration.')
	configuration: 'StaticWithFqdn'
	@description('The FQDN of the local network gateway.')
	fqdn: string
	@description('The address space of the local network site.')
	localNetworkAddressSpace: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.properties.localNetworkAddressSpace
}

@description('A local network gateway using static routing and an IP address endpoint.')
@sealed()
type StaticWithIpInput = {
	@description('The selected BGP and endpoint configuration.')
	configuration: 'StaticWithIp'
	@description('The IP address of the local network gateway.')
	gatewayIpAddress: string
	@description('The address space of the local network site.')
	localNetworkAddressSpace: resourceInput<'Microsoft.Network/localNetworkGateways@2026-01-01'>.properties.localNetworkAddressSpace
}
