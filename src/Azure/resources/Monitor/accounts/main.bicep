metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Monitor/accounts resource with extensions.'

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
	@description('The identity.')
	identity: resourceInput<'Microsoft.Monitor/accounts@2025-10-03'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: string
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The public network access setting.')
		publicNetworkAccess: (
			| 'Disabled'
			| 'Enabled')
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Monitor/accounts@2025-10-03'>.tags
}

/* RESOURCES */

resource Monitor_accounts_ 'Microsoft.Monitor/accounts@2025-10-03' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		metrics: {
			enableAccessUsingResourcePermissions: true
		}
		publicNetworkAccess: settings.properties.publicNetworkAccess
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Monitor_accounts_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Monitor_accounts_
	}
]
