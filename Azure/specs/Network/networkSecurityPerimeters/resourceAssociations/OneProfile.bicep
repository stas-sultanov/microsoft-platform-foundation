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

/* PARAMETERS */

@description('The name of the parent Microsoft.Network/networkSecurityPerimeters resource.')
param parentName resourceInput<'Microsoft.Network/networkSecurityPerimeters@2025-07-01'>.name

@description('The name of the Microsoft.Network/networkSecurityPerimeters/profiles resource under the parent perimeter specified by parentName.')
param parentProfileName resourceInput<'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01'>.name

@description('The child resources.')
@sealed()
param resources {
	@description('The collection of resource associations.')
	resourceAssociations: {
		@description('The resource name.')
		name: string
		@description('The configurable properties.')
		properties: {
			@description('Access mode on the association.')
			accessMode: resourceInput<'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01'>.properties.accessMode
			@description('The PaaS resource to be associated.')
			privateLinkResource: resourceInput<'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01'>.properties.privateLinkResource
		}
	}[]
}

/* EXISTING RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2025-07-01' existing = {
	name: parentName
}

resource Network_networkSecurityPerimeters_profile_ 'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01' existing = {
	name: parentProfileName
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
