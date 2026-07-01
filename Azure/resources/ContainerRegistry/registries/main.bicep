metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ContainerRegistry/registries resource.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSetting from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSetting.Resource[]
	}
}

@description('The identity.')
param identity resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('Enable a single data endpoint per region for serving data.')
	dataEndpointEnabled: bool?
	@description('Whether or not Tasks allowed to bypass the network rules for this container registry.')
	networkRuleBypassAllowedForTasks: bool?
	@description('Whether to allow trusted Azure services to access a network restricted registry.')
	networkRuleBypassOptions: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.networkRuleBypassOptions?
	@description('The network rule set for a container registry.')
	networkRuleSet: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.networkRuleSet?
	@description('The policies for a container registry.')
	policies: {
		@description('The export policy for a container registry.')
		exportPolicy: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.policies.exportPolicy?
		@description('The quarantine policy for a container registry.')
		quarantinePolicy: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.policies.quarantinePolicy?
		@description('The retention policy for a container registry.')
		retentionPolicy: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.policies.retentionPolicy?
		@description('The content trust policy for a container registry.')
		trustPolicy: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.policies.trustPolicy?
	}?
	@description('Whether or not public network access is allowed for the container registry.')
	publicNetworkAccess: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.publicNetworkAccess?
	@description('Whether or not zone redundancy is enabled for this container registry.')
	zoneRedundancy: resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.properties.zoneRedundancy?
}

@description('The SKU.')
param sku resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.tags

/* RESOURCES */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		adminUserEnabled: false
		anonymousPullEnabled: false
		dataEndpointEnabled: properties.?dataEndpointEnabled
		networkRuleBypassAllowedForTasks: properties.?networkRuleBypassAllowedForTasks
		networkRuleBypassOptions: properties.?networkRuleBypassOptions
		networkRuleSet: properties.?networkRuleSet
		policies: {
			azureADAuthenticationAsArmPolicy: {
				status: 'enabled'
			}
			exportPolicy: properties.?policies.?exportPolicy
			quarantinePolicy: properties.?policies.?quarantinePolicy
			retentionPolicy: properties.?policies.?retentionPolicy
			trustPolicy: properties.?policies.?trustPolicy
		}
		publicNetworkAccess: properties.?publicNetworkAccess
		roleAssignmentMode: 'AbacRepositoryPermissions'
		zoneRedundancy: properties.?zoneRedundancy
	}
	sku: sku
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		ContainerRegistry_registries_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: ContainerRegistry_registries_
	}
]

resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: ContainerRegistry_registries_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = ContainerRegistry_registries_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.ContainerRegistry/registries@2025-11-01'>.identity? = ContainerRegistry_registries_.?identity

@description('The name.')
output name string = ContainerRegistry_registries_.name
