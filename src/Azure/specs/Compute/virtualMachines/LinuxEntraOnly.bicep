metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a standalone Linux virtual machine with Microsoft Entra SSH access, Azure Monitor Agent, and optional extensions.'

/*
This spec provides a security-hardened Linux VM for always-on services.
This is a standalone VM, not a high-availability deployment:
- OS: Linux
- Priority: Regular
- VMSS: no
- Availability set: no
- Availability zone: optional single zone
- Network interfaces: one or more existing NICs; the first is primary
- Network and public IP resources: not created
- NIC deletion: detached when the VM is deleted
- Password authentication: disabled
- Local password: not configured
- Local SSH key: one required public key for the provisioning account, because Azure requires it to create a Linux VM
- Microsoft Entra login extension: always installed
- Trusted Launch: required
- Secure Boot: enabled
- vTPM: enabled
- Metadata Security Protocol: enabled in Enforce mode for IMDS and WireServer, with the Guest Proxy Agent extension installed implicitly; incompatible with Azure Backup, ephemeral OS disks, and ARM64
- Boot diagnostics: enabled
- Managed disk encryption: platform-managed keys
- VM agent: provisioned
- VM agent platform updates: enabled
- Guest OS updates: applied automatically within the required InGuestPatch maintenance window
- Patching reboot: only when required
- Image source: standard Microsoft-provided Linux images; purchase-plan images are out of scope
- Image selection: exactly one source; marketplace and gallery versions must be pinned
- Compatibility validation: consumer verifies Linux, agent, image, and VM-size compatibility
- VM size allowlist: none
- OS disk deletion: deleted with the VM
- New data disk deletion: Detach by default when the VM is deleted
- Data disk LUNs: unique
- Data disks over 4095 GiB: caching must be None
- Azure Monitor Agent: always installed with automatic upgrades
- Boot integrity monitoring: enabled by the Guest Attestation extension, which is always installed with automatic upgrades; it requires the enforced Secure Boot and vTPM and outbound access to Azure Attestation
- Azure Monitor data collection: requires a DCR
- Additional extension order: ascending alias order, after the required agents
- Extension uniqueness: names must be unique; the name of an additional extension must equal its type, which also makes types unique
- Required extensions: declared by alias with fixed names; callers cannot replace them
- Extension failures: not suppressed
- Extension inputs: secure; keep secrets out of names and public settings
*/

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDataCollectionRuleAssociations from '../../../library/Insights/dataCollectionRuleAssociations.bicep'

import * as MaintenanceConfigurationAssignments from '../../../library/Maintenance/configurationAssignments.bicep'

/* TYPES */

@description('A new managed data disk. Existing disks and disk images are not accepted.')
@sealed()
type DataDiskPropertiesInput = {
	@description('The disk caching mode.')
	caching: (
		| 'None'
		| 'ReadOnly'
		| 'ReadWrite')?
	@description('The disk disposition when the virtual machine is deleted. Defaults to Detach.')
	deleteOption: (
		| 'Delete'
		| 'Detach')?
	@description('The size of the disk in GiB.')
	@minValue(4)
	@maxValue(32767)
	diskSizeGB: int
	@description('The logical unit number. It must be unique within the virtual machine.')
	@minValue(0)
	@maxValue(63)
	lun: int
	@description('The managed disk settings.')
	@sealed()
	managedDisk: {
		@description('The storage account type.')
		storageAccountType:
			| 'Premium_LRS'
			| 'Premium_ZRS'
			| 'StandardSSD_LRS'
			| 'StandardSSD_ZRS'
	}
}

@description('A standard Microsoft-provided generalized Linux image compatible with the selected VM size, Trusted Launch, Microsoft Entra SSH login, Azure Monitor Agent, and Guest Attestation. Images requiring a purchase plan are out of scope. Supply exactly one image source.')
@sealed()
type ImageReference = {
	@description('The community gallery image version ID, including an explicit version rather than latest.')
	@minLength(1)
	@validate(
		value =>
			value == null || sys.like(
				value!,
				'/CommunityGalleries/*/Images/*/Versions/*'
			),
		'The value must be a community gallery image version ID.'
	)
	communityGalleryImageId: string?
	@description('The ID of the Microsoft.Compute/images or Microsoft.Compute/galleries/images/versions resource.')
	@minLength(1)
	@validate(
		value =>
			value == null || sys.like(
				value ?? '',
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Compute/images/*'
			) || sys.like(
				value ?? '',
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Compute/galleries/*/images/*/versions/*'
			),
		'The value must be a Microsoft.Compute/images or Microsoft.Compute/galleries/images/versions resource ID.'
	)
	id: string?
	@description('The Microsoft marketplace image offer, supplied together with publisher, sku, and version.')
	@minLength(1)
	offer: string?
	@description('The Microsoft marketplace image publisher.')
	@minLength(1)
	publisher: string?
	@description('The direct shared gallery image version ID, including an explicit version rather than latest.')
	@minLength(1)
	@validate(
		value =>
			value == null || sys.like(
				value!,
				'/SharedGalleries/*/Images/*/Versions/*'
			),
		'The value must be a direct shared gallery image version ID.'
	)
	sharedGalleryImageId: string?
	@description('The Microsoft marketplace image SKU.')
	@minLength(1)
	sku: string?
	@description('The explicit Microsoft marketplace image version. The latest alias is not accepted.')
	@minLength(1)
	version: string?
}

@description('An existing network interface retained when the virtual machine is deleted.')
@sealed()
type NetworkInterfaceReference = {
	@description('The ID of the Microsoft.Network/networkInterfaces resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/networkInterfaces/*'
			),
		'The value must be a Microsoft.Network/networkInterfaces resource ID.'
	)
	id: string
}

/* PARAMETERS */

@description('VM-scoped Azure resources. Requires a customer-scheduled InGuestPatch maintenance assignment.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	@sealed()
	Insights: {
		dataCollectionRuleAssociations: InsightsDataCollectionRuleAssociations.Resource[]
	}?
	@description('The required customer-scheduled guest patch configuration.')
	@sealed()
	Maintenance: {
		@description('At least one scheduled InGuestPatch assignment.')
		@minLength(1)
		@validate(
			value =>
				sys.length(sys.filter(
					value,
					item =>
						sys.empty(item.properties.?maintenanceConfigurationId)
				)) == 0,
			'Each assignment must reference a maintenance configuration.'
		)
		configurationAssignments: MaintenanceConfigurationAssignments.Resource[]
	}
}

@description('The child resources.')
@secure()
@sealed()
param resources {
	@description('The VM extensions by alias. EntraLogin, GuestAttestation, and MonitorAgent are installed by this spec and must be declared with their fixed names. Additional extensions deploy sequentially in ascending alias order. All names must be unique, and the name of each additional extension must equal its type.')
	@validate(
		value =>
			sys.length(sys.union(
				sys.map(
					sys.items(value),
					item =>
						sys.toLower(item.value.name)
				),
				[]
			)) == sys.length(sys.items(value)) && sys.empty(sys.filter(
				sys.items(value),
				item =>
					sys.toLower(item.value.name) != sys.toLower(item.value.?properties.?type ?? item.value.name)
			)),
		'Extension names must be unique, and the name of each additional extension must equal its type.'
	)
	extensions: {
		@description('The Microsoft Entra login extension installed by this spec. It is declared to indicate its presence.')
		@sealed()
		EntraLogin: {
			@description('The name.')
			name: 'AADSSHLoginForLinux'
		}
		@description('The Guest Attestation extension, which provides boot integrity monitoring, installed by this spec. It is declared to indicate its presence.')
		@sealed()
		GuestAttestation: {
			@description('The name.')
			name: 'GuestAttestation'
		}
		@description('The Azure Monitor Agent extension installed by this spec. It is declared to indicate its presence.')
		@sealed()
		MonitorAgent: {
			@description('The name.')
			name: 'AzureMonitorLinuxAgent'
		}
		@description('An additional Linux VM extension. Extensions run sequentially in ascending alias order after Microsoft Entra login, Azure Monitor Agent, and Guest Attestation are installed.')
		@sealed()
		*: {
			@description('The extension name. It must equal the extension type and be unique among all extensions; the Microsoft Entra login, Azure Monitor Agent, and Guest Attestation names are reserved.')
			@minLength(1)
			@maxLength(64)
			name: string
			@description('The configurable extension properties. Failure suppression and custom dependency graphs are not exposed.')
			@sealed()
			properties: {
				@description('Specifies whether a newer minor handler version is selected during deployment. Defaults to true.')
				autoUpgradeMinorVersion: bool?
				@description('Specifies whether the platform automatically upgrades the extension when supported by its handler. Defaults to true.')
				enableAutomaticUpgrade: bool?
				@description('A value changed by the consumer to force the extension handler to run again.')
				forceUpdateTag: string?
				@description('The protected, handler-specific configuration. The resources parameter is secure.')
				protectedSettings: resourceInput<'Microsoft.Compute/virtualMachines/extensions@2026-04-01'>.properties.protectedSettings?
				@description('The extension publisher.')
				@minLength(1)
				publisher: string
				@description('The public, handler-specific configuration. Secrets must be supplied through protectedSettings.')
				settings: resourceInput<'Microsoft.Compute/virtualMachines/extensions@2026-04-01'>.properties.settings?
				@description('The extension handler type.')
				@minLength(1)
				type: string
				@description('The extension handler version.')
				@minLength(1)
				typeHandlerVersion: string
			}
		}
	}
}

@description('The Linux VM settings. Authentication, operating system type, and Trusted Launch security are controlled by this spec.')
@sealed()
param settings {
	@description('The identity. The system-assigned identity is required by the AADSSHLoginForLinux extension.')
	@validate(
		value =>
			sys.contains(
				[
					'SystemAssigned'
					'SystemAssigned, UserAssigned'
				],
				value.?type ?? ''
			),
		'The identity type must be "SystemAssigned" or "SystemAssigned, UserAssigned".'
	)
	identity: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.identity
	@description('The geo-location. The existing NIC must be in the same region.')
	location: string
	@description('The virtual machine name.')
	@minLength(1)
	@maxLength(64)
	name: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.name
	@description('The configurable virtual machine properties.')
	@sealed()
	properties: {
		@description('The native VM application profile for Azure Compute Gallery applications.')
		applicationProfile: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.properties.applicationProfile?
		@description('The existing capacity reservation group.')
		@sealed()
		capacityReservation: {
			@description('The reference to the Microsoft.Compute/capacityReservationGroups resource.')
			@sealed()
			capacityReservationGroup: {
				@description('The ID of the Microsoft.Compute/capacityReservationGroups resource.')
				@validate(
					value =>
						sys.like(
							value,
							'/subscriptions/*/resourceGroups/*/providers/Microsoft.Compute/capacityReservationGroups/*'
						),
					'The value must be a Microsoft.Compute/capacityReservationGroups resource ID.'
				)
				id: string
			}
		}?
		@description('The hardware settings.')
		@sealed()
		hardwareProfile: {
			@description('The virtual machine size.')
			vmSize: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.properties.hardwareProfile.vmSize
		}
		@description('The network interfaces ')
		@sealed()
		networkProfile: {
			@description('One or more existing NICs, retained when the VM is deleted. The first NIC is primary; network configuration is owned by the consumer.')
			@minLength(1)
			networkInterfaces: NetworkInterfaceReference[]
		}
		@description('The provisioning account, SSH public key, host name, custom data, and secrets. No password is accepted.')
		@sealed()
		osProfile: {
			@description('The custom data.')
			customData: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.properties.osProfile.customData?
			@description('The SSH public key of the provisioning account, required by Azure to create a Linux VM. The matching private key is held by the consumer.')
			@minLength(1)
			@validate(
				value =>
					sys.startsWith(
						value,
						'ssh-'
					),
				'The value must be an OpenSSH public key.'
			)
			adminSshPublicKey: string
			@description('The provisioning account name. This account receives no password or authorized SSH key.')
			@minLength(1)
			@maxLength(32)
			adminUsername: string
			@description('The Linux host name.')
			@minLength(1)
			@maxLength(64)
			computerName: string
			@description('The OS profile secrets.')
			secrets: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.properties.osProfile.secrets?
		}
		@description('The generalized Linux image and managed disks.')
		@sealed()
		storageProfile: {
			@description('The new managed data disks. Logical unit numbers must be unique. Disks larger than 4095 GiB require caching None.')
			@maxLength(64)
			@validate(
				value =>
					sys.length(sys.union(
						sys.map(
							value ?? [],
							item =>
								item.lun
						),
						[]
					)) == sys.length(value ?? []) && sys.length(sys.filter(
						value ?? [],
						item =>
							item.diskSizeGB > 4095 && (item.?caching ?? 'ReadOnly') != 'None'
					)) == 0,
				'Data disk logical unit numbers must be unique. caching must be "None" for disks larger than 4095 GiB.'
			)
			dataDisks: DataDiskPropertiesInput[]?
			@description('The Linux image reference. Marketplace and gallery versions must be pinned. Linux and required agent compatibility must be verified by the consumer.')
			@validate(
				value =>
					sys.length(sys.filter(
						[
							!sys.empty(value.?id)
							!sys.empty(value.?sharedGalleryImageId)
							!sys.empty(value.?communityGalleryImageId)
							!sys.empty(value.?publisher) || !sys.empty(value.?offer) || !sys.empty(value.?sku) || !sys.empty(value.?version)
						],
						item =>
							item
					)) == 1 && (sys.empty(value.?publisher) && sys.empty(value.?offer) && sys.empty(value.?sku) && sys.empty(value.?version) || !sys.empty(value.?publisher) && !sys.empty(value.?offer) && !sys.empty(value.?sku) && sys.like(
						value.?version ?? '',
						'*.*.*'
					) && sys.toLower(value.?version ?? '') != 'latest') && !sys.endsWith(
						sys.toLower(value.?id ?? ''),
						'/latest'
					) && (sys.empty(value.?sharedGalleryImageId) || sys.like(
						value.?sharedGalleryImageId ?? '',
						'/sharedGalleries/*/images/*/versions/*'
					) && !sys.endsWith(
						sys.toLower(value.?sharedGalleryImageId ?? ''),
						'/latest'
					)) && (sys.empty(value.?communityGalleryImageId) || sys.like(
						value.?communityGalleryImageId ?? '',
						'/communityGalleries/*/images/*/versions/*'
					) && !sys.endsWith(
						sys.toLower(value.?communityGalleryImageId ?? ''),
						'/latest'
					)),
				'Exactly one of a complete pinned marketplace reference, a managed image ID, or a pinned gallery image version ID must be specified.'
			)
			imageReference: ImageReference
			@description('The managed OS disk, created from the image and deleted with the VM.')
			@sealed()
			osDisk: {
				@description('The OS disk size in GiB. It must be at least the image size. Omit to use the image default.')
				@minValue(30)
				@maxValue(4095)
				diskSizeGB: int?
				@description('The managed disk settings.')
				@sealed()
				managedDisk: {
					@description('The storage account type.')
					storageAccountType:
						| 'Premium_LRS'
						| 'Premium_ZRS'
						| 'StandardSSD_LRS'
						| 'StandardSSD_ZRS'
				}
			}
		}
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Compute/virtualMachines@2026-04-01'>.tags
	@description('The availability zone.')
	@maxLength(1)
	zones: (
		| '1'
		| '2'
		| '3')[]?
}

/* VARIABLES */

/* RESOURCES */

resource Compute_virtualMachines_ 'Microsoft.Compute/virtualMachines@2026-04-01' = {
	identity: settings.identity
	location: settings.location
	name: settings.name
	properties: {
		applicationProfile: settings.properties.?applicationProfile
		capacityReservation: settings.properties.?capacityReservation
		diagnosticsProfile: {
			bootDiagnostics: {
				enabled: true
			}
		}
		hardwareProfile: settings.properties.hardwareProfile
		networkProfile: {
			networkInterfaces: [
				for (item, index) in settings.properties.networkProfile.networkInterfaces: {
					id: settings.properties.networkProfile.networkInterfaces[index].id
					properties: {
						deleteOption: 'Detach'
						primary: index == 0
					}
				}
			]
		}
		osProfile: {
			adminUsername: settings.properties.osProfile.adminUsername
			allowExtensionOperations: true
			computerName: settings.properties.osProfile.computerName
			customData: settings.properties.osProfile.?customData
			linuxConfiguration: {
				disablePasswordAuthentication: true
				enableVMAgentPlatformUpdates: true
				patchSettings: {
					assessmentMode: 'AutomaticByPlatform'
					automaticByPlatformSettings: {
						bypassPlatformSafetyChecksOnUserSchedule: true
						rebootSetting: 'IfRequired'
					}
					patchMode: 'AutomaticByPlatform'
				}
				provisionVMAgent: true
				ssh: {
					publicKeys: [
						{
							keyData: settings.properties.osProfile.adminSshPublicKey
							path: '/home/${settings.properties.osProfile.adminUsername}/.ssh/authorized_keys'
						}
					]
				}
			}
			secrets: settings.properties.osProfile.?secrets
		}
		priority: 'Regular'
		securityProfile: {
			proxyAgentSettings: {
				addProxyAgentExtension: true
				enabled: true
				imds: {
					mode: 'Enforce'
				}
				wireServer: {
					mode: 'Enforce'
				}
			}
			securityType: 'TrustedLaunch'
			uefiSettings: {
				secureBootEnabled: true
				vTpmEnabled: true
			}
		}
		storageProfile: {
			dataDisks: [
				for item in settings.properties.storageProfile.?dataDisks ?? []: {
					caching: item.?caching ?? 'ReadOnly'
					createOption: 'Empty'
					deleteOption: item.?deleteOption ?? 'Detach'
					diskSizeGB: item.diskSizeGB
					lun: item.lun
					managedDisk: item.managedDisk
				}
			]
			imageReference: settings.properties.storageProfile.imageReference
			osDisk: {
				caching: 'ReadWrite'
				createOption: 'FromImage'
				deleteOption: 'Delete'
				diskSizeGB: settings.properties.storageProfile.osDisk.?diskSizeGB
				managedDisk: settings.properties.storageProfile.osDisk.managedDisk
				osType: 'Linux'
			}
		}
	}
	tags: settings.tags
	zones: settings.?zones ?? []
}

@batchSize(1)
resource Compute_virtualMachines_extensions_ 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = [
	for item in sys.filter(
		sys.items(resources.extensions),
		item =>
			!sys.contains(
				[
					'EntraLogin'
					'GuestAttestation'
					'MonitorAgent'
				],
				item.key
			)
	): {
		location: settings.location
		name: item.value.name
		parent: Compute_virtualMachines_
		properties: {
			autoUpgradeMinorVersion: item.value.properties.?autoUpgradeMinorVersion ?? true
			enableAutomaticUpgrade: item.value.properties.?enableAutomaticUpgrade ?? true
			forceUpdateTag: item.value.properties.?forceUpdateTag
			protectedSettings: item.value.properties.?protectedSettings
			publisher: item.value.properties.publisher
			settings: item.value.properties.?settings
			suppressFailures: false
			type: item.value.properties.type
			typeHandlerVersion: item.value.properties.typeHandlerVersion
		}
		tags: settings.tags
		dependsOn: [
			Compute_virtualMachines_extensions__EntraLogin
			Compute_virtualMachines_extensions__GuestAttestation
			Compute_virtualMachines_extensions__MonitorAgent
		]
	}
]

resource Compute_virtualMachines_extensions__EntraLogin 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = {
	location: settings.location
	name: resources.extensions.EntraLogin.name
	parent: Compute_virtualMachines_
	properties: {
		autoUpgradeMinorVersion: true
		publisher: 'Microsoft.Azure.ActiveDirectory'
		suppressFailures: false
		type: 'AADSSHLoginForLinux'
		typeHandlerVersion: '1.0'
	}
	tags: settings.tags
}

resource Compute_virtualMachines_extensions__GuestAttestation 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = {
	location: settings.location
	name: resources.extensions.GuestAttestation.name
	parent: Compute_virtualMachines_
	properties: {
		autoUpgradeMinorVersion: true
		enableAutomaticUpgrade: true
		publisher: 'Microsoft.Azure.Security.LinuxAttestation'
		settings: {
			AttestationConfig: {
				AscSettings: {
					ascReportingEndpoint: ''
					ascReportingFrequency: ''
				}
				MaaSettings: {
					maaEndpoint: ''
					maaTenantName: 'GuestAttestation'
				}
				disableAlerts: 'false'
				useCustomToken: 'false'
			}
		}
		suppressFailures: false
		type: 'GuestAttestation'
		typeHandlerVersion: '1.0'
	}
	tags: settings.tags
}

resource Compute_virtualMachines_extensions__MonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = {
	location: settings.location
	name: resources.extensions.MonitorAgent.name
	parent: Compute_virtualMachines_
	properties: {
		autoUpgradeMinorVersion: true
		enableAutomaticUpgrade: true
		publisher: 'Microsoft.Azure.Monitor'
		suppressFailures: false
		type: 'AzureMonitorLinuxAgent'
		typeHandlerVersion: '1.0'
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_virtualMachines_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachines_
	}
]

resource Insights_dataCollectionRuleAssociations_ 'Microsoft.Insights/dataCollectionRuleAssociations@2024-03-11' = [
	for item in extensions.?Insights.dataCollectionRuleAssociations ?? []: {
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachines_
	}
]

resource Maintenance_configurationAssignments_ 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = [
	for item in extensions.?Maintenance.configurationAssignments ?? []: {
		location: settings.location
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachines_
	}
]
