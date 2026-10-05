metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/virtualNetworkGateways/natRules resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as NetworkVirtualNetworkGateways from '../../../../library/Network/virtualNetworkGateways.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.Network/virtualNetworkGateways resource.')
param parentName resourceInput<'Microsoft.Network/virtualNetworkGateways@2025-09-01'>.name

@description('The resource settings.')
param settings NetworkVirtualNetworkGateways.NatRuleChildResource

/* EXISTING RESOURCES */

resource Network_virtualNetworkGateways_ 'Microsoft.Network/virtualNetworkGateways@2025-09-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_virtualNetworkGateways_natRules_ 'Microsoft.Network/virtualNetworkGateways/natRules@2025-09-01' = {
	name: settings.name
	parent: Network_virtualNetworkGateways_
	properties: settings.properties
}

/* OUTPUTS */

@description('The ID.')
output id string = Network_virtualNetworkGateways_natRules_.id

@description('The name.')
output name string = Network_virtualNetworkGateways_natRules_.name
