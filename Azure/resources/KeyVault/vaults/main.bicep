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
param name resourceInput<'Microsoft.KeyVault/vaults@2026-02-01'>.name

@description('The configurable properties.')
@sealed()
param properties {
	@description('Specifies whether protection against purge is enabled for this vault.')
	enablePurgeProtection: bool
	@description('Specifies whether the \'soft delete\' functionality is enabled for this key vault.')
	enableSoftDelete: bool
	@description('Rules governing the accessibility of the key vault from specific network locations.')
	networkAcls: resourceInput<'Microsoft.KeyVault/vaults@2026-02-01'>.properties.networkAcls?
	@description('The network access mode.')
	publicNetworkAccess:
		| 'Enabled'
		| 'Disabled'
		| 'SecuredByPerimeter'
	@description('The \'soft delete\' data retention days.')
	@maxValue(90)
	@minValue(7)
	softDeleteRetentionInDays: int?
}

@description('The tags.')
param tags resourceInput<'Microsoft.KeyVault/vaults@2026-02-01'>.tags

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
	for item in AuthorizationRoleAssignments.CreateArray(
		KeyVault_vaults_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: KeyVault_vaults_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: KeyVault_vaults_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = KeyVault_vaults_.id

@description('The name.')
output name string = KeyVault_vaults_.name
