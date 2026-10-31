metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/virtualMachines resource for a security-hardened standalone Linux virtual machine with an existing managed OS disk, Microsoft Entra SSH access, Azure Monitor Agent, and optional extensions.'

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
- Password authentication: inherited from the attached OS disk; must be disabled in the guest
- Local password: not provisioned by this spec
- Local SSH keys: not provisioned by this spec; Microsoft Entra SSH login is provided by the required extension
- Microsoft Entra login extension: always installed
- Trusted Launch: required
- Secure Boot: enabled
- vTPM: enabled
- Metadata Security Protocol: enabled in Enforce mode for IMDS and WireServer, with the Guest Proxy Agent extension installed implicitly; incompatible with Azure Backup, ephemeral OS disks, and ARM64
- Boot diagnostics: enabled
- Managed disk encryption: platform-managed keys
- VM agent: must already be present in the attached OS disk
- VM agent platform updates: inherited from the attached disk; the platform provisioning flag is not set for Attach
- Guest OS updates: AutomaticByPlatform within the required InGuestPatch maintenance assignment
- Guest patch assessment: AutomaticByPlatform
- Patching reboot: only when required
- OS disk: existing managed Linux OS disk, attached to the VM
- OS profile: configures patching without provisioning a local user, SSH key, or custom data
- Compatibility validation: consumer verifies Linux, agent, disk, Trusted Launch, and VM-size compatibility
- VM size allowlist: none
- OS disk deletion: detached from the VM and retained when the VM is deleted
- New data disk deletion: Detach by default when the VM is deleted
- Data disk LUNs: unique
- Data disks over 4095 GiB: caching must be None
- Azure Monitor Agent: always installed with automatic upgrades
- Boot integrity monitoring: enabled by the Guest Attestation extension, which is always installed with automatic upgrades; it requires the enforced Secure Boot and vTPM and outbound access to Azure Attestation
- Azure Monitor data collection: requires a DCR
- Additional extension order: ascending alias order, after the required agents
- Extension uniqueness: names must be unique; the name of an additional extension must equal its type, which also makes types unique
- Required extensions: installed internally with fixed names; callers cannot supply their aliases, names, or types
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

@description('An existing bootable managed Linux OS disk with the Azure VM agent, created separately from an image. The VM deployment does not provision a local user or SSH key.')
@sealed()
type OsDiskReference = {
	@description('The ID of the Microsoft.Compute/disks resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Compute/disks/*'
			),
		'The value must be a Microsoft.Compute/disks resource ID.'
	)
	id: string
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
@validate(
	value =>
		sys.empty(sys.filter(
			sys.items(value.extensions),
			item =>
				sys.contains(
					[
						'entralogin'
						'guestattestation'
						'monitoragent'
					],
					sys.toLower(item.key)
				) || sys.contains(
					[
						'aadsshloginforlinux'
						'guestattestation'
						'azuremonitorlinuxagent'
					],
					sys.toLower(item.value.name)
				) || sys.contains(
					[
						'aadsshloginforlinux'
						'guestattestation'
						'azuremonitorlinuxagent'
					],
					sys.toLower(item.value.properties.type)
				)
		)),
	'EntraLogin, GuestAttestation, and MonitorAgent are already installed by this spec and must not be supplied.'
)
param resources {
	@description('The additional VM extensions by alias. Microsoft Entra login, Azure Monitor Agent, and Guest Attestation are installed internally and must not be supplied. Additional extensions deploy sequentially in ascending alias order.')
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
					sys.toLower(item.value.name) != sys.toLower(item.value.properties.type)
			)),
		'Extension names must be unique, and the name of each additional extension must equal its type.'
	)
	extensions: {
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

@description('The Linux VM settings. The attached OS disk provides the operating system; Trusted Launch security is controlled by this spec.')
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
		@description('The existing Linux OS disk to attach and any new managed data disks.')
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
			@description('The existing bootable managed Linux OS disk with the Azure VM agent.')
			osDisk: OsDiskReference
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
			linuxConfiguration: {
				patchSettings: {
					assessmentMode: 'AutomaticByPlatform'
					automaticByPlatformSettings: {
						bypassPlatformSafetyChecksOnUserSchedule: true
						rebootSetting: 'IfRequired'
					}
					patchMode: 'AutomaticByPlatform'
				}
			}
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
			osDisk: {
				caching: 'ReadWrite'
				createOption: 'Attach'
				deleteOption: 'Detach'
				managedDisk: {
					id: settings.properties.storageProfile.osDisk.id
				}
				osType: 'Linux'
			}
		}
	}
	tags: settings.tags
	zones: settings.?zones ?? []
}

@batchSize(1)
resource Compute_virtualMachines_extensions_ 'Microsoft.Compute/virtualMachines/extensions@2026-04-01' = [
	for item in sys.items(resources.extensions): {
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
	name: 'AADSSHLoginForLinux'
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
	name: 'GuestAttestation'
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
	name: 'AzureMonitorLinuxAgent'
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
