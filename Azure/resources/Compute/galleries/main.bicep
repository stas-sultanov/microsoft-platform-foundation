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

@description('The identity.')
param identity resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.name

@description('The properties.')
param properties resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.tags

/* RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-12-03' = {
	identity: identity
	location: location
	name: name
	properties: properties
	tags: tags
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
