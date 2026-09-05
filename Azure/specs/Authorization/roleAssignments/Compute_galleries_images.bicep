metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Compute/galleries/images type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('Name of the Microsoft.Compute/galleries/images resource.')
	galleryImageName: string
	@description('Name of the Microsoft.Compute/galleries resource.')
	galleryName: string
	@description('Collection of role assignments.')
	roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
}

/* EXISTING RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-12-03' existing = {
	name: settings.galleryName
	resource images_ 'images' existing = {
		name: settings.galleryImageName
	}
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_galleries_::images_.id,
		settings.roleAssignments
	): {
		name: item.name
		properties: item.properties
		scope: Compute_galleries_::images_
	}
]
