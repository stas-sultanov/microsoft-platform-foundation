metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/disks resource for a Trusted Launch Linux OS disk created from a pinned platform image or Azure Compute Gallery image version.'

/*
This spec provides a managed OS disk for a Trusted Launch Linux virtual machine:
- OS: Linux
- Creation: once, from an image; the source cannot change after creation
- Source: exactly one pinned Azure Marketplace platform image or Azure Compute Gallery image version; "latest" is not allowed
- Source purchase plan: not supported
- Compatibility validation: consumer verifies the image is a Linux, Generation 2, Trusted Launch-capable image
- Hyper-V generation: V2
- Security type: Trusted Launch
- SKU: Premium SSD or Standard SSD with LRS or ZRS; Standard HDD, Premium SSD v2, and Ultra Disk are not supported
- Availability zone: optional single zone for LRS; none for ZRS
- Size: source image size by default; up to 4,095 GiB
- Performance tier, bursting, and sharing: platform defaults
- Encryption at rest: platform-managed keys
- Azure Disk Encryption: not supported
- Import and export authorization: Microsoft Entra ID; incompatible with Azure Backup and Azure Site Recovery
- Import and export network access: all networks when public network access is enabled; denied otherwise
- Private import and export through disk access: not supported
*/

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* TYPES */

@description('The creation data for one of the supported image sources.')
@discriminator('createOption')
@sealed()
type CreationData =
	| CreationDataFromImageGallery
	| CreationDataFromImageMarketplace

@description('The creation data for a pinned Azure Compute Gallery image version.')
@sealed()
type CreationDataFromImageGallery = {
	@description('The selected image source, deployed as the FromImage create option.')
	createOption: 'FromImageGallery'
	@description('The pinned Azure Compute Gallery image version.')
	@sealed()
	galleryImageReference: {
		@description('The ID of the Microsoft.Compute/galleries/images/versions resource.')
		@validate(
			value =>
				sys.like(
					value,
					'/subscriptions/*/resourceGroups/*/providers/Microsoft.Compute/galleries/*/images/*/versions/*'
				) && !sys.like(
					value,
					'*/versions/latest'
				),
			'The value must be a pinned Microsoft.Compute/galleries/images/versions resource ID.'
		)
		id: string
	}
}

@description('The creation data for a pinned Azure Marketplace platform image without a purchase plan.')
@sealed()
type CreationDataFromImageMarketplace = {
	@description('The selected image source, deployed as the FromImage create option.')
	createOption: 'FromImageMarketplace'
	@description('The pinned Azure Marketplace platform image without a purchase plan.')
	@sealed()
	imageReference: {
		@description('The ID of the Microsoft.Compute/locations/publishers/artifacttypes/offers/skus/versions resource.')
		@validate(
			value =>
				sys.like(
					value,
					'/subscriptions/*/providers/Microsoft.Compute/locations/*/publishers/*/artifacttypes/VMImage/offers/*/skus/*/versions/*'
				) && !sys.like(
					value,
					'*/versions/latest'
				),
			'The value must be a pinned Microsoft.Compute/locations/publishers/artifacttypes/offers/skus/versions resource ID.'
		)
		id: string
	}
}

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
@validate(
	value =>
		value.?zones == null || !sys.contains(
			[
				'Premium_ZRS'
				'StandardSSD_ZRS'
			],
			value.sku.name
		),
	'zones must be null when sku.name is "Premium_ZRS" or "StandardSSD_ZRS".'
)
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	@minLength(1)
	@maxLength(80)
	name: resourceInput<'Microsoft.Compute/disks@2026-03-02'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The image to create the disk from. It cannot change after creation.')
		creationData: CreationData
		@description('The disk size in GiB. When omitted, the source image size is used. It must not be smaller than the source image size and cannot be reduced.')
		@minValue(1)
		@maxValue(4095)
		diskSizeGB: resourceInput<'Microsoft.Compute/disks@2026-03-02'>.properties.diskSizeGB?
		@description('The network access mode for disk import and export. Enabled allows all networks; Disabled denies all networks.')
		publicNetworkAccess: (
			| 'Disabled'
			| 'Enabled')
	}
	@description('The SKU.')
	@sealed()
	sku: {
		@description('The SKU name.')
		name: (
			| 'Premium_LRS'
			| 'Premium_ZRS'
			| 'StandardSSD_LRS'
			| 'StandardSSD_ZRS')
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Compute/disks@2026-03-02'>.tags
	@description('The availability zone of a zonal locally redundant disk, or null for a regional locally redundant disk or a zone-redundant disk. A zonal virtual machine requires a disk in the same zone or a zone-redundant disk; a regional virtual machine requires a regional or zone-redundant disk.')
	zones:
		| [
			'1'
		]
		| [
			'2'
		]
		| [
			'3'
		]
		| null
}

/* RESOURCES */

resource Compute_disks_ 'Microsoft.Compute/disks@2026-03-02' = {
	location: settings.location
	name: settings.name
	properties: {
		creationData: {
			createOption: 'FromImage'
			galleryImageReference: settings.properties.creationData.?galleryImageReference
			imageReference: settings.properties.creationData.?imageReference
		}
		dataAccessAuthMode: 'AzureActiveDirectory'
		diskSizeGB: settings.properties.?diskSizeGB
		encryption: {
			type: 'EncryptionAtRestWithPlatformKey'
		}
		hyperVGeneration: 'V2'
		networkAccessPolicy: settings.properties.publicNetworkAccess == 'Enabled'
			? 'AllowAll'
			: 'DenyAll'
		osType: 'Linux'
		publicNetworkAccess: settings.properties.publicNetworkAccess
		securityProfile: {
			securityType: 'TrustedLaunch'
		}
	}
	sku: settings.sku
	tags: settings.tags
	zones: settings.?zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_disks_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Compute_disks_
	}
]
