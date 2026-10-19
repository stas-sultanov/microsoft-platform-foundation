metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions an active-active, route-based Microsoft.Network/virtualNetworkGateways VPN gateway for S2S/VNet-to-VNet connectivity, with extensions. Point-to-site VPN is outside this specification.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as MaintenanceConfigurationAssignments from '../../../library/Maintenance/configurationAssignments.bicep'

import * as NetworkVirtualNetworkGateways from '../../../library/Network/virtualNetworkGateways.bicep'

/* TYPES */

@description('Optional BGP settings. When supplied, BGP is enabled; otherwise, it is disabled. Azure allocates ordinary BGP peering IP addresses automatically.')
@sealed()
type BgpSettingsInput = {
	@description('The BGP autonomous system number.')
	@minValue(1)
	@maxValue(4294967294)
	asn: int?
	@description('Optional custom Azure APIPA BGP peering addresses for each gateway instance. Azure permits 169.254.21.0 through 169.254.22.255; verify addresses against the remote peers.')
	@sealed()
	@validate(
		value =>
			value == null || (sys.length(sys.union(
				sys.map(
					sys.concat(
						value!.Instance0,
						value!.Instance1
					),
					address =>
						sys.toLower(address)
				),
				[]
			)) == sys.length(value!.Instance0) + sys.length(value!.Instance1) && sys.empty(sys.filter(
				sys.concat(value!.Instance0, value!.Instance1),
				address => !sys.contains(
					sys.map(
						sys.range(0, 512),
						index => '169.254.${21 + index / 256}.${index % 256}'
					),
					address
				)
			))),
		'Custom BGP peering IP addresses must be unique across both instances and valid IPv4 addresses from 169.254.21.0 through 169.254.22.255.'
	)
	customBgpIpAddresses: {
		@description('Custom Azure APIPA BGP addresses for the Instance0 instance.')
		@minLength(1)
		Instance0: string[]
		@description('Custom Azure APIPA BGP addresses for the Instance1 instance.')
		@minLength(1)
		Instance1: string[]
	}?
}

/* PARAMETERS */

@description('The extension resource settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
	@sealed()
	Maintenance: {
		configurationAssignments: MaintenanceConfigurationAssignments.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.name
	@description('The configurable properties.')
	@sealed()
	@validate(
		value =>
			sys.empty(value.?natRules ?? []) || value.sku.name != 'VpnGw1AZ',
		'VPN gateway NAT rules require VpnGw2AZ, VpnGw3AZ, VpnGw4AZ, or VpnGw5AZ.'
	)
	properties: {
		@description('The custom BGP settings.')
		bgpSettings: BgpSettingsInput?
		@description('Specifies whether BGP is enabled.')
		enableBgp: bool
		@description('Specifies whether BGP routes are translated using NAT.')
		enableBgpRouteTranslationForNat: bool
		@description('Two gateway IP configurations referencing the same subnet and distinct Standard, Static public IP resources. Deploy the public IP resources separately.')
		@sealed()
		@validate(
			value =>
				sys.toLower(value.Instance0.subnet.id) == sys.toLower(value.Instance1.subnet.id) && sys.toLower(value.Instance0.publicIPAddress.id) != sys.toLower(value.Instance1.publicIPAddress.id),
			'Both gateway instances must reference the same subnet and different public IP address resources.'
		)
		ipConfigurations: {
			@description('The IP configuration for the Instance0 gateway instance.')
			Instance0: NetworkVirtualNetworkGateways.IpConfigurationInput
			@description('The IP configuration for the Instance1 gateway instance.')
			Instance1: NetworkVirtualNetworkGateways.IpConfigurationInput
		}
		@description('The optional VPN gateway NAT rules. Nonempty rules require VpnGw2AZ or higher.')
		natRules: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.properties.natRules?
		@description('The SKU.')
		@sealed()
		sku: {
			@description('The VPN gateway SKU name.')
			name:
				| 'VpnGw1AZ'
				| 'VpnGw2AZ'
				| 'VpnGw3AZ'
				| 'VpnGw4AZ'
				| 'VpnGw5AZ'
		}
	}
	@description('The resource tags.')
	tags: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-01-01'>.tags
}

/* RESOURCES */

resource Network_virtualNetworkGateways_ 'Microsoft.Network/virtualNetworkGateways@2026-01-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		activeActive: true
		bgpSettings: settings.properties.?bgpSettings == null
			? null
			: {
					asn: settings.properties.?bgpSettings.asn
					bgpPeeringAddresses: settings.properties.?bgpSettings.?customBgpIpAddresses == null
						? null
						: [
								NetworkVirtualNetworkGateways.CreateBgpPeeringAddress(
									settings.name,
									'Instance0',
									settings.properties.bgpSettings!.customBgpIpAddresses!.Instance0
								)
								NetworkVirtualNetworkGateways.CreateBgpPeeringAddress(
									settings.name,
									'Instance1',
									settings.properties.bgpSettings!.customBgpIpAddresses!.Instance1
								)
							]
				}
		enableBgp: settings.properties.enableBgp
		enableBgpRouteTranslationForNat: settings.properties.enableBgpRouteTranslationForNat
		gatewayType: 'Vpn'
		ipConfigurations: [
			NetworkVirtualNetworkGateways.CreateIpConfiguration(
				'Instance0',
				settings.properties.ipConfigurations.Instance0
			)
			NetworkVirtualNetworkGateways.CreateIpConfiguration(
				'Instance1',
				settings.properties.ipConfigurations.Instance1
			)
		]
		natRules: settings.properties.?natRules
		sku: {
			name: settings.properties.sku.name
			tier: settings.properties.sku.name
		}
		vpnType: 'RouteBased'
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_virtualNetworkGateways_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworkGateways_
	}
]

#disable-next-line use-recent-api-versions // To use newer diagnostic features, the preview API version is required.
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworkGateways_
	}
]

resource Maintenance_configurationAssignments_ 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = [
	for item in extensions.Maintenance.configurationAssignments: {
		location: settings.location
		name: item.name
		properties: item.properties
		scope: Network_virtualNetworkGateways_
	}
]
