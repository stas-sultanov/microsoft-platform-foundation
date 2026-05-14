metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Sql/servers resource.'

/* TYPES */

type EntraPrincipalType =
	| 'Application'
	| 'Group'
	| 'User'

type EntraPrincipal = {
	@description('Name of the principal within the Entra tenant.')
	name: string

	@description('ObjectId of the principal within the Entra tenant.')
	objectId: string

	@description('Id of the Entra tenant.')
	tenantId: string?

	@description('Type of the principal within the Entra tenant.')
	type: EntraPrincipalType
}

/* PARAMETERS */

@description('Administrator principal.')
param adminPrincipal EntraPrincipal

@description('Managed Service Identity.')
param identity resourceInput<'Microsoft.Sql/servers@2025-01-01'>.identity

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Define if access from Public Network is allowed.')
@allowed([
	'Enabled'
	'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Common tags to put on the resource.')
param tags object

@description('Id of the OperationalInsights/Workspace resource.')
param workspaceId string

/* VARIABLES */

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

/* EXISTING RESOURCES */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(
		operationalInsights_workspaces__id_split[2],
		operationalInsights_workspaces__id_split[4]
	)
}

/* RESOURCES */

#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: OperationalInsights_workspaces_.name
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				category: 'SQLSecurityAuditEvents'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Sql_servers_databases__master
}

resource Sql_servers_ 'Microsoft.Sql/servers@2025-01-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		administrators: {
			administratorType: 'ActiveDirectory'
			azureADOnlyAuthentication: true
			login: adminPrincipal.name
			principalType: adminPrincipal.type
			sid: adminPrincipal.objectId
			tenantId: adminPrincipal.?tenantId ?? subscription().tenantId
		}
		minimalTlsVersion: '1.2'
		publicNetworkAccess: publicNetworkAccess
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

resource Sql_servers_firewallRules__AllowPublicNetworkAccess 'Microsoft.Sql/servers/firewallRules@2025-01-01' = if (publicNetworkAccess == 'Enabled') {
	name: 'AllowPublicNetworkAccess'
	parent: Sql_servers_
	properties: {
		endIpAddress: '255.255.255.255'
		startIpAddress: '0.0.0.0'
	}
}

/* OUTPUTS */

@description('The id.')
output id string = Sql_servers_.id

@description('The identity.')
output identity object = Sql_servers_.identity

@description('The name.')
output name string = Sql_servers_.name

@description('The properties.')
output properties object = {
	fullyQualifiedDomainName: Sql_servers_.properties.fullyQualifiedDomainName
}
