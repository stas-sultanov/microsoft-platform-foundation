metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Sql/servers resource with extensions.'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extension settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The child resources.')
@sealed()
param resources {
	auditingSettings: {
		Default: {
			@description('The configurable properties.')
			properties: {
				@description('Specifies whether audit events are sent to Azure Monitor.')
				isAzureMonitorTargetEnabled: bool
				@description('Specifies whether devops audit is enabled.')
				isDevopsAuditEnabled: bool
				@description('Specifies the state of the audit.')
				state: resourceInput<'Microsoft.Sql/servers/auditingSettings@2025-01-01'>.properties.state
			}
		}
	}
	connectionPolicies: {
		Default: {
			@description('The configurable properties.')
			properties: resourceInput<'Microsoft.Sql/servers/connectionPolicies@2025-01-01'>.properties
		}
	}
	databases: {
		Master: {
			@description('The extension settings.')
			extensions: {
				Insights: {
					diagnosticSettings: InsightsDiagnosticSettings.Resource[]
				}
			}
		}
	}
	firewallRules: {
		*: {
			@description('The name.')
			name: string
			@description('The start IP address of the firewall rule.')
			properties: resourceInput<'Microsoft.Sql/servers/firewallRules@2025-01-01'>.properties
		}
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
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
		isIPv6Enabled: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.isIPv6Enabled
		@description('The network access mode.')
		publicNetworkAccess: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.publicNetworkAccess
		@description('The resource id of a user assigned identity to be used by default.')
		primaryUserAssignedIdentityId: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.primaryUserAssignedIdentityId
		@description('Specifies whether or not outbound network access is restricted for this server.')
		restrictOutboundNetworkAccess: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.restrictOutboundNetworkAccess
		@description('The number of days this server will stay soft-deleted.')
		retentionDays: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.properties.retentionDays
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Sql/servers@2025-01-01'>.tags
}

/* RESOURCES */

resource Sql_servers_ 'Microsoft.Sql/servers@2025-01-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		administrators: {
			administratorType: 'ActiveDirectory'
			azureADOnlyAuthentication: true
			login: settings.properties.administrators.name
			principalType: settings.properties.administrators.principalType
			sid: settings.properties.administrators.objectId
			tenantId: settings.properties.administrators.?tenantId ?? az.tenant().tenantId
		}
		isIPv6Enabled: settings.properties.isIPv6Enabled
		minimalTlsVersion: '1.3'
		primaryUserAssignedIdentityId: settings.properties.primaryUserAssignedIdentityId
		publicNetworkAccess: settings.properties.publicNetworkAccess
		restrictOutboundNetworkAccess: settings.properties.restrictOutboundNetworkAccess
		retentionDays: settings.properties.retentionDays
	}
	tags: settings.tags
}

resource Sql_servers_auditingSettings__Default 'Microsoft.Sql/servers/auditingSettings@2025-01-01' = {
	name: 'default'
	parent: Sql_servers_
	properties: {
		isAzureMonitorTargetEnabled: resources.auditingSettings.Default.properties.isAzureMonitorTargetEnabled
		isDevopsAuditEnabled: resources.auditingSettings.Default.properties.isDevopsAuditEnabled
		state: resources.auditingSettings.Default.properties.state
	}
}

resource Sql_servers_connectionPolicies__Default 'Microsoft.Sql/servers/connectionPolicies@2025-01-01' = {
	name: 'default'
	parent: Sql_servers_
	properties: resources.connectionPolicies.Default.properties
}

resource Sql_servers_databases__Master 'Microsoft.Sql/servers/databases@2025-01-01' = {
	location: settings.location
	name: 'master'
	parent: Sql_servers_
	properties: {}
}

resource Sql_servers_firewallRules_ 'Microsoft.Sql/servers/firewallRules@2025-01-01' = [
	for item in items(resources.firewallRules ?? {}): {
		name: item.value.name
		parent: Sql_servers_
		properties: item.value.properties
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Sql_servers_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Sql_servers_
	}
]

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings__Master 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in resources.databases.Master.extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Sql_servers_databases__Master
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
