metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityGroups resource with child security rules and extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as NetworkNetworkSecurityGroups from '../../../library/Network/networkSecurityGroups.bicep'

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
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The child resources.')
@sealed()
param resources {
	@description('The security rules of the network security group.')
	securityRules: NetworkNetworkSecurityGroups.SecurityRuleResource[]
}?

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkSecurityGroups@2026-03-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Specifies whether flows created from network security group connections are re-evaluated when rules are updated.')
		flushConnection: bool
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkSecurityGroups@2026-03-01'>.tags
}

/* RESOURCES */

resource Network_networkSecurityGroups_ 'Microsoft.Network/networkSecurityGroups@2026-03-01' = {
	location: settings.location
	name: settings.name
	properties: {
		flushConnection: settings.properties.flushConnection
		// The current NSG API design resets security rules omitted from parent updates, including separately deployed child rules.
		// Read the existing resource's rules and pass them back inline to preserve them before deploying child updates.
		securityRules: this.existingResource().?properties.securityRules
	}
	tags: settings.tags
}

// Competing writes to the same network security group can fail with AnotherOperationInProgress, so the rules are deployed one at a time.
@batchSize(1)
resource Network_networkSecurityGroups_securityRules_ 'Microsoft.Network/networkSecurityGroups/securityRules@2026-03-01' = [
	for item in resources.?securityRules ?? []: {
		name: item.name
		parent: Network_networkSecurityGroups_
		properties: item.properties
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_networkSecurityGroups_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityGroups_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityGroups_
	}
]
