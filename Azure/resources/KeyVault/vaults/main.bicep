metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.KeyVault/vaults resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as KeyVaultVaults from '../../../library/KeyVault/vaults.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties KeyVaultVaults.PropertiesInput

@description('The tags.')
param tags resourceInput<'Microsoft.KeyVault/vaults@2024-11-01'>.tags

/* RESOURCES */

resource KeyVault_vaults_ 'Microsoft.KeyVault/vaults@2026-02-01' = {
	location: location
	name: name
	properties: {
		enablePurgeProtection: properties.enableSoftDelete && properties.enablePurgeProtection
			? true
			: null
		enableRbacAuthorization: true
		enableSoftDelete: properties.enableSoftDelete
		networkAcls: properties.?networkAcls ?? {}
		publicNetworkAccess: properties.publicNetworkAccess
		sku: {
			family: 'A'
			name: 'standard'
		}
		softDeleteRetentionInDays: properties.?softDeleteRetentionInDays ?? 7
		tenantId: az.tenant().tenantId
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		KeyVault_vaults_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: KeyVault_vaults_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: KeyVault_vaults_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = KeyVault_vaults_.id

@description('The name.')
output name string = KeyVault_vaults_.name
