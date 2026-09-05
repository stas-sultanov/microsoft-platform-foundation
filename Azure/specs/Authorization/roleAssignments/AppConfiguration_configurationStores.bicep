metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.AppConfiguration/configurationStores type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('Name of the Microsoft.AppConfiguration/configurationStores resource.')
	name: resourceInput<'Microsoft.AppConfiguration/configurationStores@2024-06-01'>.name
	@description('Collection of role assignments.')
	roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
}

/* EXISTING RESOURCES */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
	name: settings.name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		AppConfiguration_configurationStores_.id,
		settings.roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: AppConfiguration_configurationStores_
	}
]
