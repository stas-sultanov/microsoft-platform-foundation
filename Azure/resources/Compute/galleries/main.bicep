metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/galleries resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.tags
}

/* RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-12-03' = {
	identity: settings.?identity ?? {
	type: 'None'
}
	location: settings.location
	name: settings.name
	properties: settings.properties
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_galleries_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Compute_galleries_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Compute_galleries_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Compute/galleries@2025-12-03'>.identity? = Compute_galleries_.?identity

@description('The name.')
output name string = Compute_galleries_.name
