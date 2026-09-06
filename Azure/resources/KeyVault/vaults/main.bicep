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
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.KeyVault/vaults@2026-02-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
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
	tags: resourceInput<'Microsoft.KeyVault/vaults@2026-02-01'>.tags
}

/* RESOURCES */

resource KeyVault_vaults_ 'Microsoft.KeyVault/vaults@2026-02-01' = {
	location: settings.location
	name: settings.name
	properties: {
		enablePurgeProtection: settings.properties.enableSoftDelete && settings.properties.enablePurgeProtection
			? true
			: null
		enableRbacAuthorization: true
		enableSoftDelete: settings.properties.enableSoftDelete
		networkAcls: settings.properties.?networkAcls ?? {}
		publicNetworkAccess: settings.properties.publicNetworkAccess
		sku: {
			family: 'A'
			name: 'standard'
		}
		softDeleteRetentionInDays: settings.properties.?softDeleteRetentionInDays ?? 7
		tenantId: az.tenant().tenantId
	}
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		KeyVault_vaults_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: KeyVault_vaults_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
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
