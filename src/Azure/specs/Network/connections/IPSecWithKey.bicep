metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/connections resource for an IPsec connection using a pre-shared key with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as NetworkConnections from '../../../library/Network/connections.bicep'

/* TYPES */

@description('The settings for an IPsec connection using a pre-shared key.')
@sealed()
type ConnectionPropertiesInput = {
	@description('The dead peer detection timeout in seconds.')
	@minValue(9)
	@maxValue(3600)
	dpdTimeoutSeconds: int?
	@description('Specifies whether BGP is enabled for this connection.')
	enableBgp: bool?
	@description('The ingress NAT rules.')
	ingressNatRules: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.ingressNatRules?
	@description('The egress NAT rules.')
	egressNatRules: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.egressNatRules?
	@description('Custom IPsec policies. Azure supports at most one policy per connection.')
	@minLength(1)
	@maxLength(1)
	@validate(
		value =>
			sys.length(sys.filter(
				value,
				policy =>
					(policy.ipsecEncryption == 'GCMAES256') != (policy.ipsecIntegrity == 'GCMAES256')
			)) == 0,
		'IPsec encryption and integrity must both use GCMAES256 when either uses GCMAES256.'
	)
	ipsecPolicies: NetworkConnections.IPSecPolicy[]
	@description('The reference to the Microsoft.Network/localNetworkGateways resource.')
	localNetworkGateway2: NetworkConnections.LocalNetworkGatewayReference
	@description('The ID of the Microsoft.KeyVault/vaults/secrets resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.KeyVault/vaults/*/secrets/*'
			),
		'The value must be a Microsoft.KeyVault/vaults/secrets resource ID.'
	)
	sharedKeyKeyVaultId: string
	@description('The custom traffic selector policies, configured independently of usePolicyBasedTrafficSelectors.')
	trafficSelectorPolicies: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.trafficSelectorPolicies?
	@description('Specifies whether policy-based traffic selectors are enabled for this connection.')
	usePolicyBasedTrafficSelectors: bool?
	@description('The reference to the primary Microsoft.Network/virtualNetworkGateways resource.')
	virtualNetworkGateway1: NetworkConnections.VirtualNetworkGatewayReference
}

/* PARAMETERS */

@description('The extensions settings.')
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
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/connections@2026-01-01'>.name
	@description('The configurable properties.')
	properties: ConnectionPropertiesInput
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/connections@2026-01-01'>.tags
}

/* VARIABLES */

@description('The segments of the shared key secret resource ID: /subscriptions/{2}/resourceGroups/{4}/providers/Microsoft.KeyVault/vaults/{8}/secrets/{10}.')
var sharedKeySecretIdSegments = split(
	settings.properties.sharedKeyKeyVaultId,
	'/'
)

/* EXISTING RESOURCES */

resource KeyVault_vaults_ 'Microsoft.KeyVault/vaults@2026-05-15' existing = {
	name: sharedKeySecretIdSegments[8]
	scope: resourceGroup(
		sharedKeySecretIdSegments[2],
		sharedKeySecretIdSegments[4]
	)
}

resource Network_connections_ 'Microsoft.Network/connections@2026-01-01' existing = {
	dependsOn: [
		Network_connections_Module_
	]
	name: settings.name
}

/* RESOURCES */

// TEMPORARY SOLUTION: getSecret() is allowed only when assigning to a module parameter with @secure() decorator (BCP180).
// The Microsoft.Network/connections resource type also defines a sharedKeyKeyVaultId property, but it is not available for either general availability or preview use.
// EXCEPTION: the helper module 'IPSecWithKey/connection.bicep' deviates from the module structure rules.
// - Its path does not follow the 'specs' path conventions, because it must be a separate file to receive the secret as a @secure() parameter.
// - It exposes the 'sharedKey' parameter outside the standard module interface, because that is how the secret is passed in.
module Network_connections_Module_ 'IPSecWithKey/connection.bicep' = {
	name: '${deployment().name}-connection'
	params: {
		settings: {
			location: settings.location
			name: settings.name
			properties: {
				authenticationType: 'PSK'
				connectionProtocol: 'IKEv2'
				connectionType: 'IPsec'
				dpdTimeoutSeconds: settings.properties.?dpdTimeoutSeconds
				egressNatRules: settings.properties.?egressNatRules
				enableBgp: settings.properties.?enableBgp
				ingressNatRules: settings.properties.?ingressNatRules
				ipsecPolicies: settings.properties.ipsecPolicies
				localNetworkGateway2: {
					id: settings.properties.localNetworkGateway2.id
					properties: {}
				}
				trafficSelectorPolicies: settings.properties.?trafficSelectorPolicies
				usePolicyBasedTrafficSelectors: settings.properties.?usePolicyBasedTrafficSelectors
				virtualNetworkGateway1: {
					id: settings.properties.virtualNetworkGateway1.id
					properties: {}
				}
			}
			tags: settings.tags
		}
		sharedKey: KeyVault_vaults_.getSecret(sharedKeySecretIdSegments[10])
	}
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_connections_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_connections_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_connections_
	}
]
