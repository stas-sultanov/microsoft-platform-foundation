metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkWatchers resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkWatchers@2025-09-01'>.name
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkWatchers@2025-09-01'>.tags
}

/* RESOURCES */

resource Network_networkWatchers_ 'Microsoft.Network/networkWatchers@2025-09-01' = {
	location: settings.location
	name: settings.name
	properties: {}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_networkWatchers_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_networkWatchers_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_networkWatchers_.id

@description('The name.')
output name string = Network_networkWatchers_.name
