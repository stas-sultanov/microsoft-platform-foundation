metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityPerimeters/resourceAssociations resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as NetworkNetworkSecurityPerimeters from '../../../../library/Network/networkSecurityPerimeters.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.Network/networkSecurityPerimeters resource.')
param parentName string

@description('The child resources.')
param resources NetworkNetworkSecurityPerimeters.ResourceAssociationChildResource[]

/* EXISTING RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2025-07-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_networkSecurityPerimeters_resourceAssociations_ 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01' = [
	for resource in resources: {
		name: resource.name
		parent: Network_networkSecurityPerimeters_
		properties: resource.properties
	}
]
