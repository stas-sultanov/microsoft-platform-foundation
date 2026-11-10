metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/virtualNetworkGateways resource for active-active, route-based S2S/VNet-to-VNet connectivity with child NAT rules and extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as MaintenanceConfigurationAssignments from '../../../library/Maintenance/configurationAssignments.bicep'

import * as NetworkVirtualNetworkGateways from '../../../library/Network/virtualNetworkGateways.bicep'

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

@description('The child resources.')
@sealed()
param resources {
	@description('The VPN gateway NAT rules. Nonempty rules require VpnGw2AZ or higher.')
	@validate(
		value =>
			settings.properties.sku.name != 'VpnGw1AZ' || sys.empty(value),
		'natRules must be empty when settings.properties.sku.name is "VpnGw1AZ".'
	)
	natRules: NetworkVirtualNetworkGateways.NatRuleResource[]?
}?

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-03-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-03-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The BGP speaker settings.')
		@sealed()
		bgpSettings: {
			@description('The BGP autonomous system number.')
			@minValue(1)
			@maxValue(4294967294)
			asn: int?
			@description('BGP peering addresses for the gateway IP configurations.')
			@validate(
				value =>
					value == null || sys.empty(sys.intersection(
						value![0].customBgpIpAddresses,
						value![1].customBgpIpAddresses
					)),
				'Custom BGP peering IP addresses must be unique across both gateway IP configurations.'
			)
			bgpPeeringAddresses: [
				NetworkVirtualNetworkGateways.IPConfigurationBgpPeeringAddress
				NetworkVirtualNetworkGateways.IPConfigurationBgpPeeringAddress
			]?
		}?
		@description('Specifies whether BGP is enabled.')
		enableBgp: bool
		@description('Specifies whether BGP routes are translated using NAT.')
		enableBgpRouteTranslationForNat: bool
		@description('IP configurations.')
		@validate(
			value =>
				sys.toLower(value[0].properties.subnet.id) == sys.toLower(value[1].properties.subnet.id) && sys.toLower(value[0].properties.publicIPAddress.id) != sys.toLower(value[1].properties.publicIPAddress.id) && sys.toLower(value[0].name) != sys.toLower(value[1].name),
			'IP configuration names and public IP address resource IDs must be unique across both gateway instances, ignoring case. Both gateway instances must reference the same subnet.'
		)
		ipConfigurations: [
			@description('The IP configuration for the gateway instance 0.')
			NetworkVirtualNetworkGateways.IpConfigurationResource
			@description('The IP configuration for the gateway instance 1.')
			NetworkVirtualNetworkGateways.IpConfigurationResource
		]
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
	tags: resourceInput<'Microsoft.Network/virtualNetworkGateways@2026-03-01'>.tags
}

/* RESOURCES */

resource Network_virtualNetworkGateways_ 'Microsoft.Network/virtualNetworkGateways@2026-03-01' = {
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
					bgpPeeringAddresses: settings.properties.?bgpSettings.?bgpPeeringAddresses == null
						? null
						: [
								NetworkVirtualNetworkGateways.CreateBgpPeeringAddress(
									settings.name,
									settings.properties.ipConfigurations[0].name,
									settings.properties.bgpSettings!.bgpPeeringAddresses![0].customBgpIpAddresses
								)
								NetworkVirtualNetworkGateways.CreateBgpPeeringAddress(
									settings.name,
									settings.properties.ipConfigurations[1].name,
									settings.properties.bgpSettings!.bgpPeeringAddresses![1].customBgpIpAddresses
								)
							]
				}
		enableBgp: settings.properties.enableBgp
		enableBgpRouteTranslationForNat: settings.properties.enableBgpRouteTranslationForNat
		gatewayType: 'Vpn'
		ipConfigurations: [
			settings.properties.ipConfigurations[0]
			settings.properties.ipConfigurations[1]
		]
		// Parent updates can reset separately deployed NAT rules; pass existing rules back inline before deploying child updates.
		natRules: this.existingResource().?properties.natRules
		sku: {
			name: settings.properties.sku.name
			tier: settings.properties.sku.name
		}
		vpnType: 'RouteBased'
	}
	tags: settings.tags
}

// NAT rule writes update the same gateway, so deploy them one at a time.
@batchSize(1)
resource Network_virtualNetworkGateways_natRules_ 'Microsoft.Network/virtualNetworkGateways/natRules@2026-03-01' = [
	for item in resources.?natRules ?? []: {
		name: item.name
		parent: Network_virtualNetworkGateways_
		properties: item.properties
	}
]

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
