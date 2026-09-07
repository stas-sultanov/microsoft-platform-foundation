metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityPerimeters/profiles resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as NetworkNetworkSecurityPerimeters from '../../../../library/Network/networkSecurityPerimeters.bicep'

/* PARAMETERS */

@description('The child resources.')
@sealed()
param resources {
	accessRules: {
		*: NetworkNetworkSecurityPerimeters.AccessRuleChildResource
	}
}?

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	@sealed()
	name: {
		@description('The name of the Microsoft.Network/networkSecurityPerimeters resource.')
		networkSecurityPerimeter: resourceInput<'Microsoft.Network/networkSecurityPerimeters@2025-07-01'>.name
		@description('The name of the Microsoft.Network/networkSecurityPerimeters/profiles resource.')
		@maxLength(80)
		profile: resourceInput<'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01'>.name
	}
}

/* EXISTING RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2025-07-01' existing = {
	name: settings.name.networkSecurityPerimeter
}

/* RESOURCES */

resource Network_networkSecurityPerimeters_profiles_ 'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01' = {
	name: settings.name.profile
	parent: Network_networkSecurityPerimeters_
	properties: {}
}

resource Network_networkSecurityPerimeters_profiles_accessRules_ 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-07-01' = [
	for item in items(resources.?accessRules ?? {}): {
		name: item.value.name
		parent: Network_networkSecurityPerimeters_profiles_
		properties: item.value.properties
	}
]
