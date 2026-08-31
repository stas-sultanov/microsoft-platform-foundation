metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.VirtualMachineImages/imageTemplates resource with extensions.'

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
param identity resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.name

@description('The configurable properties.')
param properties resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties

@description('The child resources.')
param resources {
	triggers: {
		@description('The trigger on SourceImage change.')
		SourceImage: {
			@description('The configurable properties.')
			properties: {}
		}
	}
}?

@description('The tags.')
param tags resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.tags

/* RESOURCES */

resource VirtualMachineImages_imageTemplates_ 'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01' = {
	identity: identity
	location: location
	name: name
	properties: properties
	tags: tags
}

resource VirtualMachineImages_imageTemplates_triggers__SourceImage 'Microsoft.VirtualMachineImages/imageTemplates/triggers@2025-10-01' = if (resources.?triggers != null) {
	name: 'SourceImage'
	parent: VirtualMachineImages_imageTemplates_
	properties: {
		kind: 'SourceImage'
	}
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		VirtualMachineImages_imageTemplates_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: VirtualMachineImages_imageTemplates_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = VirtualMachineImages_imageTemplates_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.identity? = VirtualMachineImages_imageTemplates_.?identity

@description('The name.')
output name string = VirtualMachineImages_imageTemplates_.name
