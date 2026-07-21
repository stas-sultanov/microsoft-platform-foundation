metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/virtualMachineScaleSets resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDataCollectionRuleAssociations from '../../../library/Insights/dataCollectionRuleAssociations.bicep'

import * as MaintenanceConfigurationAssignments from '../../../library/Maintenance/configurationAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
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

@description('The identity.')
param identity resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties

@description('The SKU.')
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
	properties: properties
	sku: sku
	tags: tags
	zones: zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		Compute_virtualMachineScaleSets_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: Compute_virtualMachineScaleSets_
	}
]

resource Insights_dataCollectionRuleAssociations_ 'Microsoft.Insights/dataCollectionRuleAssociations@2024-03-11' = [
	for extension in extensions.Insights.dataCollectionRuleAssociations: {
		name: extension.name
		properties: extension.properties
		scope: Compute_virtualMachineScaleSets_
	}
]

resource Maintenance_configurationAssignments_ 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = [
	for extension in extensions.Maintenance.configurationAssignments: {
		location: location
		name: extension.name
		properties: extension.properties
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
