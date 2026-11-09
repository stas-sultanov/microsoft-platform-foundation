metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions an active-active, route-based Microsoft.Network/virtualNetworkGateways VPN gateway for S2S/VNet-to-VNet connectivity, with child NAT rules and extensions. Point-to-site VPN is outside this specification.'

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
@validate(
	value =>
		settings.properties.sku.name != 'VpnGw1AZ' || sys.empty(value.natRules),
	'resources.natRules must be empty when settings.properties.sku.name is "VpnGw1AZ".'
)
param resources {
	@description('The VPN gateway NAT rules. Nonempty rules require VpnGw2AZ or higher.')
	natRules: NetworkVirtualNetworkGateways.NatRuleResource[]
}

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
		@description('The custom BGP settings.')
		bgpSettings: NetworkVirtualNetworkGateways.BgpSettings?
		@description('Specifies whether BGP is enabled.')
		enableBgp: bool
		@description('Specifies whether BGP routes are translated using NAT.')
		enableBgpRouteTranslationForNat: bool
		@description('Two gateway IP configurations referencing the same subnet and distinct Standard, Static public IP resources. Deploy the public IP resources separately.')
		@sealed()
		@validate(
			value =>
				sys.toLower(value.Instance0.properties.subnet.id) == sys.toLower(value.Instance1.properties.subnet.id) && sys.toLower(value.Instance0.properties.publicIPAddress.id) != sys.toLower(value.Instance1.properties.publicIPAddress.id) && sys.toLower(value.Instance0.name) != sys.toLower(value.Instance1.name),
			'Both gateway instances must have different IP configuration names and reference the same subnet and different public IP address resources.'
		)
		ipConfigurations: {
			@description('The IP configuration for the gateway instance 0.')
			Instance0: NetworkVirtualNetworkGateways.IpConfigurationResource
			@description('The IP configuration for the gateway instance 1.')
			Instance1: NetworkVirtualNetworkGateways.IpConfigurationResource
		}
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
					bgpPeeringAddresses: settings.properties.?bgpSettings.?customBgpIpAddresses == null
						? null
						: [
								NetworkVirtualNetworkGateways.CreateBgpPeeringAddress(
									settings.name,
									settings.properties.ipConfigurations.Instance0.name,
									settings.properties.bgpSettings!.customBgpIpAddresses!.Instance0
								)
								NetworkVirtualNetworkGateways.CreateBgpPeeringAddress(
									settings.name,
									settings.properties.ipConfigurations.Instance1.name,
									settings.properties.bgpSettings!.customBgpIpAddresses!.Instance1
								)
							]
				}
		enableBgp: settings.properties.enableBgp
		enableBgpRouteTranslationForNat: settings.properties.enableBgpRouteTranslationForNat
		gatewayType: 'Vpn'
		ipConfigurations: [
			settings.properties.ipConfigurations.Instance0
			settings.properties.ipConfigurations.Instance1
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
	for item in resources.natRules: {
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
