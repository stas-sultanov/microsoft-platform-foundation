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

/* TYPES */
@description('Versioning settings for the Latest scheme.')
@sealed()
type DistributeVersionerLatest = {
	@description('Major version for the generated version number.')
	major: int?
	@description('Version numbering scheme to be used.')
	scheme: 'Latest'
}

@description('Versioning settings for the Source scheme.')
@sealed()
type DistributeVersionerSource = {
	@description('Version numbering scheme to be used.')
	scheme: 'Source'
}

@description('Versioning settings for a shared image distributor.')
@discriminator('scheme')
@sealed()
type DistributeVersioner =
	| DistributeVersionerLatest
	| DistributeVersionerSource

@description('Represents a shared image distributor in an image template.')
@sealed()
type ImageTemplateSharedImageDistributor = {
	@description('Tags that will be applied to the artifact once it has been created/updated by the distributor.')
	artifactTags: {
		@description('A tag to be applied to the artifact.')
		*: string
	}?
	@description('Specifies whether the created image version is excluded from the latest version.')
	excludeFromLatest: bool?
	@description('Resource Id of the Azure Compute Gallery image.')
	galleryImageId: 'string'
	@description('Describes replication mode for distribution in Azure Compute Gallery.')
	replicationMode:
		| 'Full'
		| 'Shallow'
		| null
	@description('The name to be used for the associated RunOutput.')
	@minLength(1)
	@maxLength(64)
	runOutputName: string
	@description('The target regions where the distributed Image Version is going to be replicated to.')
	targetRegions: {
		@description('The replication settings for the region where the resource is located.')
		Default: {
			@description('The number of replicas to create in the target region.')
			@minValue(1)
			replicaCount: int?
			@description('The type of storage account to use in the target region.')
			storageAccountType: ImageTemplateSharedImageDistributorTargetRegionStorageAccountType
		}
		@description('The replication settings for all other target regions.')
		*: {
			@description('The name of the target region.')
			name: 'string'
			@description('The number of replicas to create in the target region.')
			@minValue(1)
			replicaCount: int?
			@description('The type of storage account to use in the target region.')
			storageAccountType: ImageTemplateSharedImageDistributorTargetRegionStorageAccountType
		}
	}
	@description('Type of distribution.')
	type: 'SharedImage'
	@description('Describes how to generate new x.y.z version number for distribution.')
	versioning: DistributeVersioner?
}

@description('The type of storage account to use in the target region.')
type ImageTemplateSharedImageDistributorTargetRegionStorageAccountType =
	| 'Premium_LRS'
	| 'Standard_LRS'
	| 'Standard_ZRS'
	| null

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
	@sealed()
	properties: {
		@description('Optional array of additional data disks to be added to the image.')
		additionalDataDisks: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.additionalDataDisks
		@description('Indicates whether or not to automatically run the image template build on template creation or update.')
		autoRun: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.autoRun
		@description('Maximum duration to wait while building the image template in minutes.')
		buildTimeoutInMinutes: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.buildTimeoutInMinutes
		@description('Specifies the properties used to describe the customization steps of the image.')
		customize: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.customize
		@description('The distribution targets where the image output needs to go to.')
		distribute: ImageTemplateSharedImageDistributor[]
		@description('Error handling options upon a build failure.')
		errorHandling: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.errorHandling
		@description('Tags that will be applied to resources created by the service.')
		managedResourceTags: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.managedResourceTags
		@description('Specifies optimization to be performed on the image.')
		optimize: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.optimize
		@description('Specifies the properties used to describe the source image.')
		source: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.source
		@description('The staging resource group id used to build the image.')
		stagingResourceGroup: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.stagingResourceGroup
		@description('Configuration options and validations to be performed on the resulting image.')
		validate: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.validate
		@description('Describes how the virtual machine is set up to build images.')
		vmProfile: resourceInput<'Microsoft.VirtualMachineImages/imageTemplates@2025-10-01'>.properties.vmProfile
	}
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
	properties: {
		additionalDataDisks: settings.properties.additionalDataDisks
		autoRun: settings.properties.autoRun
		buildTimeoutInMinutes: settings.properties.buildTimeoutInMinutes
		customize: settings.properties.customize
		distribute: [
			for item in settings.properties.distribute: union(
				item,
				{
					targetRegions: concat(
						[
							{
								name: settings.location
								replicaCount: item.targetRegions.Default.?replicaCount
								storageAccountType: item.targetRegions.Default.?storageAccountType
							}
						],
						map(
							filter(
								items(item.targetRegions),
								region =>
									region.key != 'Default'
							),
							region =>
								region.value
						)
					)
				}
			)
		]
		errorHandling: settings.properties.errorHandling
		managedResourceTags: settings.properties.managedResourceTags
		optimize: settings.properties.optimize
		source: settings.properties.source
		stagingResourceGroup: settings.properties.stagingResourceGroup
		validate: settings.properties.validate
		vmProfile: settings.properties.vmProfile
	}
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
