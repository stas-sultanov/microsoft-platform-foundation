metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Sql/servers/databases resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../../library/Insights/diagnosticSettings.bicep'

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

@description('The identity.')
param identity resourceInput<'Microsoft.Sql/servers/databases@2025-01-01'>.identity = {
	type: 'None'
}

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Sql/servers/databases@2025-01-01'>.name

@description('The name of the parent Microsoft.Sql/servers resource.')
param parentName string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Sql/servers/databases@2025-01-01'>.properties

@description('The child resources.')
@sealed()
param resources {
	auditingSettings: {
		Default: {
			properties: resourceInput<'Microsoft.Sql/servers/databases/auditingSettings@2025-01-01'>.properties
		}?
	}?
}?

@description('The SKU.')
param sku resourceInput<'Microsoft.Sql/servers/databases@2025-01-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Sql/servers/databases@2025-01-01'>.tags

/* EXISTING RESOURCES */

resource Sql_servers_ 'Microsoft.Sql/servers@2025-01-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Sql_servers_databases_ 'Microsoft.Sql/servers/databases@2025-01-01' = {
	identity: identity
	location: location
	name: name
	parent: Sql_servers_
	properties: properties
	sku: sku
	tags: tags
}

resource Sql_servers_databases_auditingSettings__Default 'Microsoft.Sql/servers/databases/auditingSettings@2025-01-01' = if (resources.?auditingSettings.?Default != null) {
	name: 'default'
	parent: Sql_servers_databases_
	properties: resources!.auditingSettings!.Default!.properties
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Sql_servers_databases_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Sql_servers_databases_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Sql_servers_databases_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Sql_servers_databases_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Sql/servers/databases@2025-01-01'>.identity? = Sql_servers_databases_.?identity

@description('The name.')
output name string = Sql_servers_databases_.name
