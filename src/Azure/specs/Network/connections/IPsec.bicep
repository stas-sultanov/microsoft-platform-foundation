metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/connections resource for an IPsec connection with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@description('The configuration of a custom IPsec policy.')
@sealed()
type IpsecPolicyInput = {
	@description('The Diffie-Hellman group for IKE key exchange.')
	dhGroup:
		| 'DHGroup24'
		| 'ECP256'
		| 'ECP384'
	@description('The IKE encryption algorithm. Pair GCMAES256 with GCMAES256 integrity.')
	ikeEncryption:
		| 'AES256'
		| 'GCMAES256'
	@description('The IKE integrity and pseudo-random function algorithm.')
	ikeIntegrity:
		| 'SHA256'
		| 'SHA384'
	@description('The IPsec encryption algorithm. Pair GCMAES256 with GCMAES256 integrity.')
	ipsecEncryption:
		| 'AES256'
		| 'GCMAES256'
	@description('The IPsec integrity algorithm.')
	ipsecIntegrity:
		| 'GCMAES256'
		| 'SHA256'
	@description('The Perfect Forward Secrecy group for IPsec key exchange.')
	pfsGroup:
		| 'ECP256'
		| 'ECP384'
		| 'PFS24'
	@description('The IPSec Security Association (also called Quick Mode or Phase 2 SA) payload size in KB for a site to site VPN tunnel.')
	saDataSizeKilobytes: int
	@description('The IPSec Security Association (also called Quick Mode or Phase 2 SA) lifetime in seconds for a site to site VPN tunnel.')
	saLifeTimeSeconds: int
}

@description('The settings for an IPsec connection.')
@sealed()
type ConnectionPropertiesInput = {
	@description('The connection authentication type.')
	authenticationType:
		| 'Certificate'
		| 'PSK'
	@description('Certificate authentication settings for the connection.')
	certificateAuthentication: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.certificateAuthentication?
	@description('The dead peer detection timeout in seconds.')
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
	ipsecPolicies: IpsecPolicyInput[]
	@description('The resource ID of the local network gateway for this IPsec connection.')
	localNetworkGateway2: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.localNetworkGateway2
	@description('The shared key for the connection.')
	sharedKey: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.sharedKey?
	@description('The traffic selector policies.')
	trafficSelectorPolicies: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.trafficSelectorPolicies?
	@description('The resource ID of the primary Microsoft.Network/virtualNetworkGateways resource.')
	virtualNetworkGateway1: resourceInput<'Microsoft.Network/connections@2026-01-01'>.properties.virtualNetworkGateway1
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

/* RESOURCES */

resource Network_connections_ 'Microsoft.Network/connections@2026-01-01' = {
	location: settings.location
	name: settings.name
	properties: {
		...settings.properties
		connectionProtocol: 'IKEv2'
		connectionType: 'IPsec'
	}
	tags: settings.tags
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

/* OUTPUTS */

@description('The ID.')
output id string = Network_connections_.id

@description('The name.')
output name string = Network_connections_.name
