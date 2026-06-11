metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Sql/servers resource.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@secure()
type EntraPrincipalType =
	| 'Application'
	| 'Group'
	| 'User'

@sealed()
type EntraPrincipal = {
	@description('Name of the principal within the Entra tenant.')
	name: string

	@description('ObjectId of the principal within the Entra tenant.')
	objectId: string

	@description('The id of the Entra tenant.')
	tenantId: string?

	@description('Type of the principal within the Entra tenant.')
	type: EntraPrincipalType
}

/* PARAMETERS */

@description('The extension settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('Managed Service Identity.')
param identity resourceInput<'Microsoft.Sql/servers@2025-01-01'>.identity

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('The configurable properties.')
@sealed()
param properties {
	@description('The server Entra ID administrator.')
	administrators: {
		@description('Name of the principal within the Entra tenant.')
		name: string
		@description('ObjectId of the principal within the Entra tenant.')
		objectId: string
		@description('Type of the principal within the Entra tenant.')
		principalType: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.administrators.principalType
		@description('The id of the Entra tenant.')
		tenantId: string?
	}
	@description('Specifies whether or not public endpoint access is allowed for this server.')
	publicNetworkAccess: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.publicNetworkAccess
	@description('The number of days this server will stay soft-deleted.')
	retentionDays: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.retentionDays
}

@description('The tags.')
param tags resourceInput<'Microsoft.Sql/servers@2025-01-01'>.tags

/* RESOURCES */

resource Sql_servers_ 'Microsoft.Sql/servers@2025-01-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		administrators: {
			administratorType: 'ActiveDirectory'
			azureADOnlyAuthentication: true
			login: properties.administrators.name
			principalType: properties.administrators.principalType
			sid: properties.administrators.objectId
			tenantId: properties.administrators.?tenantId ?? az.tenant().tenantId
		}
		minimalTlsVersion: '1.3'
		publicNetworkAccess: properties.publicNetworkAccess
		retentionDays: properties.retentionDays
	}
	tags: tags
}

resource Sql_servers_auditingSettings__Default 'Microsoft.Sql/servers/auditingSettings@2025-01-01' = {
	name: 'default'
	parent: Sql_servers_
	properties: {
		isAzureMonitorTargetEnabled: true
		state: 'Enabled'
	}
}

resource Sql_servers_connectionPolicies__default 'Microsoft.Sql/servers/connectionPolicies@2025-01-01' = {
	name: 'default'
	parent: Sql_servers_
	properties: {
		connectionType: 'Default'
	}
}

resource Sql_servers_databases__master 'Microsoft.Sql/servers/databases@2025-01-01' = {
	location: location
	name: 'master'
	parent: Sql_servers_
	properties: {}
}

resource Sql_servers_firewallRules__AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2025-01-01' = {
	name: 'AllowAllWindowsAzureIps'
	parent: Sql_servers_
	properties: {
		endIpAddress: '0.0.0.0'
		startIpAddress: '0.0.0.0'
	}
}

resource Sql_servers_firewallRules__AllowPublicNetworkAccess 'Microsoft.Sql/servers/firewallRules@2025-01-01' = if (properties.publicNetworkAccess == 'Enabled') {
	name: 'AllowPublicNetworkAccess'
	parent: Sql_servers_
	properties: {
		endIpAddress: '255.255.255.255'
		startIpAddress: '0.0.0.0'
	}
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		Sql_servers_.id,
		extensions.Authorization.roleAssignments
	): {
		name: extension.name
		properties: extension.properties
		scope: Sql_servers_
	}
]

resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for extension in extensions.Insights.diagnosticSettings: {
		name: extension.name
		properties: extension.properties
		scope: Sql_servers_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Sql_servers_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Sql/servers@2025-01-01'>.identity? = Sql_servers_.?identity

@description('The name.')
output name string = Sql_servers_.name

@description('The properties.')
output properties {
	fullyQualifiedDomainName: string
} = {
	fullyQualifiedDomainName: Sql_servers_.properties.fullyQualifiedDomainName
}
