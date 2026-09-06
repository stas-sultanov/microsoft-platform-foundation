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
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	@sealed()
	Insights: {
		dataCollectionRuleAssociations: InsightsDataCollectionRuleAssociations.Resource[]
	}
	@sealed()
	Maintenance: {
		configurationAssignments: MaintenanceConfigurationAssignments.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.properties
	@description('The SKU.')
	sku: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.sku
	@description('The tags.')
	tags: resourceInput<'Microsoft.Compute/virtualMachineScaleSets@2026-03-01'>.tags
	@description('A list of availability zones denoting the IP allocated for the resource needs to come from.')
	zones: string[]
}

/* RESOURCES */

resource Compute_virtualMachineScaleSets_ 'Microsoft.Compute/virtualMachineScaleSets@2026-03-01' = {
	identity: settings.?identity ?? {
	type: 'None'
}
	location: settings.location
	name: settings.name
	properties: settings.properties
	sku: settings.sku
	tags: settings.tags
	zones: settings.zones
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Compute_virtualMachineScaleSets_.id,
		extensions.?Authorization.roleAssignments ?? []
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
		location: settings.location
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
