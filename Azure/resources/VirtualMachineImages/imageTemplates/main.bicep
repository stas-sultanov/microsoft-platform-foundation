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
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The child resources.')
@sealed()
param resources {
	@sealed()
	triggers: {
		@description('The trigger on SourceImage change.')
		@sealed()
		SourceImage: {
			@description('The configurable properties.')
			properties: {}
		}?
	}
}?

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.tags
}

/* RESOURCES */

resource VirtualMachineImages_imageTemplates_ 'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: settings.properties
	tags: settings.tags
}

resource VirtualMachineImages_imageTemplates_triggers__SourceImage 'Microsoft.VirtualMachineImages/imageTemplates/triggers@2025-10-01' = if (resources.?triggers.?SourceImage != null) {
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
		extensions.?Authorization.roleAssignments ?? []
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
