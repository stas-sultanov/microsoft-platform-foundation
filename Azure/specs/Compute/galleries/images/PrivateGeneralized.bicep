metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/galleries/images resource.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
}

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.name

@description('The name of the parent Microsoft.Compute/galleries resource.')
param parentName string

@description('The configurable properties.')
@sealed()
param properties {
	@description('The architecture of the image. Applicable to OS disks only.')
	architecture: resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.properties.architecture
	@description('The description of this gallery image definition resource.')
	description: string?
	@description('Describes the disallowed disk types.')
	disallowed: resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.properties.disallowed?
	@description('The end of life date of the gallery image definition.')
	endOfLifeDate: string?
	@description('A list of gallery image features.')
	features: {
		@description('Indicates whether the gallery image definition supports hibernation.')
		IsHibernateSupported: bool
	}
	@description('This is the gallery image definition identifier.')
	identifier: resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.properties.identifier
	@description('This property allows you to specify the type of the OS that is included in the disk when creating a VM from a managed image.')
	osType: resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.properties.osType
	@description('The properties describe the recommended machine configuration for this Image Definition.')
	recommended: resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.properties.recommended?
}

@description('The tags.')
param tags resourceInput<'Microsoft.Compute/galleries/images@2025-12-03'>.tags

/* VARIABLES */

var features = [
	{
		// NVMe-only currently is not supported.
		name: 'DiskControllerTypes'
		value: 'SCSI, NVMe'
	}
	{
		name: 'IsAcceleratedNetworkSupported'
		value: 'True'
	}
	{
		name: 'IsHibernateSupported'
		value: properties.features.IsHibernateSupported
			? 'True'
			: 'False'
	}
	{
		name: 'SecurityType'
		value: 'TrustedLaunch'
	}
]

/* EXISTING RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-12-03' existing = {
	name: parentName
}

/* RESOURCES */

resource Compute_galleries_images_ 'Microsoft.Compute/galleries/images@2025-12-03' = {
	location: location
	name: name
	parent: Compute_galleries_
	properties: {
		allowUpdateImage: false
		architecture: properties.architecture
		description: properties.?description
		disallowed: properties.?disallowed
		endOfLifeDate: properties.?endOfLifeDate
		features: features
		hyperVGeneration: 'V2'
		identifier: properties.identifier
		osState: 'Generalized'
		osType: properties.osType
		recommended: properties.?recommended
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_galleries_images_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Compute_galleries_images_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Compute_galleries_images_.id

@description('The name.')
output name string = Compute_galleries_images_.name
