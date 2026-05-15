metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Sql/servers/databases resource.'

/* PARAMETERS */

@description('The mode of database creation.')
@allowed([
	'Default'
	'Copy'
])
param createMode string = 'Default'

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Specifies the SKU of the sql database.')
@allowed([
	'Basic'
	'S0'
	'S1'
	'S2'
	'S3'
	'GP_Gen5_2'
	'GP_Gen5_4'
	'GP_Gen5_6'
	'GP_Gen5_8'
	'GP_Gen5_10'
	'GP_S_Gen5_1'
	'GP_S_Gen5_2'
	'GP_S_Gen5_4'
	'GP_S_Gen5_6'
	'GP_S_Gen5_8'
])
param sku string = 'Basic'

@description('The id of the Sql/servers/databases resource which is used by different creation modes.')
param sourceDatabaseId string = ''

@description('Name of the Sql/servers resource.')
param sqlServerName string

@description('Tags to put on the resource.')
param tags object

@description('The id of the OperationalInsights/Workspace resource.')
param workspaceId string

/* VARIABLES */

var databaseProperties = {
	Default: {
		createMode: 'Default'
	}
	Copy: {
		createMode: 'Copy'
		sourceDatabaseId: createMode == 'Default'
			? ''
			: Sql_servers_databases_Source.id
	}
}

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

var sql_servers_databases_Source_id_split = split(
	sourceDatabaseId,
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

resource Sql_servers_ 'Microsoft.Sql/servers@2025-01-01' existing = {
	name: sqlServerName
}

resource Sql_servers_databases_Source 'Microsoft.Sql/servers/databases@2025-01-01' existing = if (createMode != 'Default') {
	name: sql_servers_databases_Source_id_split[8]
	scope: resourceGroup(
		sql_servers_databases_Source_id_split[2],
		sql_servers_databases_Source_id_split[4]
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
				categoryGroup: 'allLogs'
				enabled: true
			}
			{
				categoryGroup: 'audit'
				enabled: true
			}
		]
		metrics: [
			{
				enabled: true
				timeGrain: 'PT1M'
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Sql_servers_databases_
}

resource Sql_servers_databases_ 'Microsoft.Sql/servers/databases@2025-01-01' = {
	location: location
	name: name
	parent: Sql_servers_
	properties: databaseProperties[createMode]
	sku: {
		name: sku
	}
	tags: tags
}

resource Sql_servers_databases_auditingSettings_ 'Microsoft.Sql/servers/databases/auditingSettings@2025-01-01' = {
	name: 'default'
	parent: Sql_servers_databases_
	properties: {
		isAzureMonitorTargetEnabled: true
		state: 'Enabled'
	}
}

/* OUTPUTS */

@description('The id.')
output id string = Sql_servers_databases_.id

@description('The name.')
output name string = Sql_servers_databases_.name
