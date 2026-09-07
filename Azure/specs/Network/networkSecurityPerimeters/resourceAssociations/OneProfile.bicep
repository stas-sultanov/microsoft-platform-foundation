metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions Microsoft.Network/networkSecurityPerimeters/resourceAssociations resources and assigns them to one existing profile.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as NetworkNetworkSecurityPerimeters from '../../../../library/Network/networkSecurityPerimeters.bicep'

/* PARAMETERS */

@description('The parent resource identification.')
@sealed()
param parent {
	@description('The name of the Microsoft.Network/networkSecurityPerimeters resource.')
	networkSecurityPerimeterName: resourceInput<'Microsoft.Network/networkSecurityPerimeters@2025-07-01'>.name
	@description('The name of the Microsoft.Network/networkSecurityPerimeters/profiles resource.')
	profileName: resourceInput<'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01'>.name
}

@description('The child resources.')
@sealed()
param resources {
	@description('The collection of resource associations.')
	resourceAssociations: NetworkNetworkSecurityPerimeters.ResourceAssociationChildResource[]
}

/* EXISTING RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2025-07-01' existing = {
	name: parent.networkSecurityPerimeterName
}

resource Network_networkSecurityPerimeters_profile_ 'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01' existing = {
	name: parent.profileName
	parent: Network_networkSecurityPerimeters_
}

/* RESOURCES */

resource Network_networkSecurityPerimeters_resourceAssociations_ 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01' = [
	for item in resources.resourceAssociations: {
		name: item.name
		parent: Network_networkSecurityPerimeters_
		properties: {
			...item.properties
			profile: {
				id: Network_networkSecurityPerimeters_profile_.id
			}
		}
	}
]
