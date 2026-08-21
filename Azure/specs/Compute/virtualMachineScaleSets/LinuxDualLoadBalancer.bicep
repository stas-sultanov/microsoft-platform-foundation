metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/virtualMachineScaleSets resource.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDataCollectionRuleAssociations from '../../../library/Insights/dataCollectionRuleAssociations.bicep'

import * as MaintenanceConfigurationAssignments from '../../../library/Maintenance/configurationAssignments.bicep'

/* TYPES */

@export()
type Extensions = {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		dataCollectionRuleAssociations: InsightsDataCollectionRuleAssociations.Resource[]
	}
	Maintenance: {
		configurationAssignments: MaintenanceConfigurationAssignments.Resource[]
	}
}

type Properties = {
	@description('Policy for automatic repairs.')
	automaticRepairsPolicy: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties.automaticRepairsPolicy
	@description('The virtual machine profile.')
	virtualMachineProfile: {
		@description('Specifies a collection of settings for extensions installed on virtual machines in the scale set.')
		extensionProfile: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties.virtualMachineProfile.extensionProfile
		@description('Specifies properties of the network interfaces of the virtual machines in the scale set.')
		networkProfile: {
			@description('A reference to a load balancer probe used to determine the health of an instance in the virtual machine scale set.')
			healthProbe: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties.virtualMachineProfile.networkProfile.healthProbe
			@description('The list of network configurations.')
			networkInterfaceConfigurations: {
				Default: {
					@description('Describes a virtual machine scale set network profile\'s IP configuration.')
					properties: {
						@description('Specifies the IP configurations of the network interface.')
						ipConfigurations: {
							Default: {
								@description('Describes a virtual machine scale set network profile\'s IP configuration properties.')
								properties: {
									@description('Specifies an array of references to backend address pools of load balancers.')
									loadBalancerBackendAddressPools: {
										Private: SubResource
										Public: SubResource
									}
									@description('Specifies the identifier of the subnet.')
									subnet: SubResource
								}
							}
						}
						@description('The network security group.')
						networkSecurityGroup: SubResource
					}
				}
			}
		}
	}
	@description('Specifies the operating system settings for the virtual machines in the scale set.')
	osProfile: {
		@description('Specifies the name of the administrator account.')
		adminUsername: string
		@description('Specifies the computer name prefix for all of the virtual machines in the scale set. Computer name prefixes must be 1 to 15 characters long.')
		computerNamePrefix: string
		@description('Specifies a base-64 encoded string of custom data. The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine. The maximum length of the binary array is 65535 bytes.')
		customData: string
		@description('Specifies the Linux operating system settings on the virtual machine.')
		linuxConfiguration: {
			@description('Specifies the ssh key configuration for a Linux OS.')
			ssh: {
				@description('The list of SSH public keys used to authenticate with linux based VMs.')
				publicKeys: {
					Admin: {
						@description('SSH public key certificate used to authenticate with the VM through ssh.')
						keyData: string
					}
				}
			}
		}
	}
	@description('Specifies the storage settings for the virtual machine disks.')
	storageProfile: {
		@description('Specifies information about the image to use.')
		imageReference: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties.virtualMachineProfile.storageProfile.imageReference
		@description('Specifies information about the operating system disk used by the virtual machines in the scale set.')
		osDisk: {
			@description('The managed disk parameters.')
			managedDisk: {
				@description('Specifies the storage account type for the managed disk. NOTE: UltraSSD_LRS can only be used with data disks, it cannot be used with OS Disk.')
				storageAccountType: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties.virtualMachineProfile.storageProfile.osDisk.managedDisk.storageAccountType
			}
		}
	}
}

type SubResource = {
	@description('The resource id.')
	id: string
}

/* PARAMETERS */

@description('The extensions settings.')
param extensions Extensions

@description('The identity.')
param identity resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties Properties

@description('The sku.')
param sku resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.tags

@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
param zones string[]

/* RESOURCES */

resource Compute_virtualMachineScaleSets_ 'Microsoft.Compute/virtualMachineScaleSets@2026-03-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		automaticRepairsPolicy: properties.automaticRepairsPolicy
		orchestrationMode: 'Uniform'
		overprovision: true
		resiliencyPolicy: {
			/**
				automaticZoneRebalancingPolicy: {
					//enabled: true
					// rebalanceBehavior: 'CreateBeforeDelete'
					// rebalanceStrategy: 'Recreate'
				}/**/
			resilientVMCreationPolicy: {
				enabled: true
			}
			resilientVMDeletionPolicy: {
				enabled: true
			}
		}
		scaleInPolicy: {
			forceDeletion: true
			rules: [
				'Default'
			]
		}
		upgradePolicy: {
			automaticOSUpgradePolicy: {
				enableAutomaticOSUpgrade: true
			}
			mode: 'Automatic'
		}
		virtualMachineProfile: {
			/**
			applicationProfile: {
				galleryApplications: [
					{
						packageReferenceId: '/'
						treatFailureAsDeploymentFailure: true
					}
				]
			}
			/**/
			extensionProfile: properties.virtualMachineProfile.extensionProfile
			networkProfile: {
				healthProbe: properties.virtualMachineProfile.networkProfile.healthProbe
				networkInterfaceConfigurations: [
					{
						name: 'Default'
						properties: {
							enableAcceleratedNetworking: true
							ipConfigurations: [
								{
									name: 'Default'
									properties: {
										loadBalancerBackendAddressPools: [
											properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.Default.properties.ipConfigurations.Default.properties.loadBalancerBackendAddressPools.Private
											properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.Default.properties.ipConfigurations.Default.properties.loadBalancerBackendAddressPools.Public
										]
										subnet: properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.Default.properties.ipConfigurations.Default.properties.subnet
									}
								}
							]
							networkSecurityGroup: properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.Default.properties.networkSecurityGroup
							primary: true
						}
					}
				]
			}
			osProfile: {
				adminUsername: properties.osProfile.adminUsername
				computerNamePrefix: properties.osProfile.computerNamePrefix
				customData: properties.osProfile.customData
				linuxConfiguration: {
					disablePasswordAuthentication: true
					enableVMAgentPlatformUpdates: true
					ssh: {
						publicKeys: [
							{
								keyData: properties.osProfile.linuxConfiguration.ssh.publicKeys.Admin.keyData
								path: '/home/${properties.osProfile.adminUsername}/.ssh/authorized_keys'
							}
						]
					}
				}
			}
			storageProfile: {
				imageReference: properties.storageProfile.imageReference
				osDisk: {
					caching: 'ReadWrite'
					createOption: 'FromImage'
					managedDisk: {
						storageAccountType: properties.storageProfile.osDisk.managedDisk.storageAccountType
					}
				}
			}
		}
		zoneBalance: sys.length(zones) > 1
	}
	sku: sku
	tags: tags
	zones: zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_virtualMachineScaleSets_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachineScaleSets_
	}
]

resource Insights_dataCollectionRuleAssociations_ 'Microsoft.Insights/dataCollectionRuleAssociations@2024-03-11' = [
	for item in extensions.Insights.dataCollectionRuleAssociations: {
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachineScaleSets_
	}
]

resource Maintenance_configurationAssignments_ 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = [
	for item in extensions.Maintenance.configurationAssignments: {
		location: location
		name: item.name
		properties: item.properties
		scope: Compute_virtualMachineScaleSets_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Compute_virtualMachineScaleSets_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.identity? = Compute_virtualMachineScaleSets_.?identity

@description('The name.')
output name string = Compute_virtualMachineScaleSets_.name
