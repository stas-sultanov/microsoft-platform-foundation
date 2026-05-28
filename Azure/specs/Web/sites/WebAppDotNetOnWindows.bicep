metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides shared type definitions for web app specifications.'

/* TYPES */

@export()
@description('dotNet Framework version.')
type DotNetVersion =
	| 'v4.0'
	| 'v6.0'
	| 'v7.0'
	| 'v8.0'
	| 'v9.0'

type IpSecurityRestrictionAction =
	| 'Allow'
	| 'Deny'

@export()
type IpSecurityRestriction = {
	@description('Allow or Deny access for this IP range.')
	action: IpSecurityRestrictionAction

	@description('Information.')
	description: string?

	@description('IP address the security restriction is valid for.')
	ipAddress: string

	@description('IP restriction rule name.')
	name: string
}


@description('AppService parameters.')
type Parameters = {
	@description('true if Always On is enabled; otherwise, false')
	alwaysOn: bool

	@description('OpenApi definition path')
	apiDefinition: string?

	@description('true to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance')
	clientAffinityEnabled: bool

	@description('List of origins that should be allowed to make cross-origin calls. Use "*" to allow all')
	corsAllowedOrigins: string[]

	@description('Maximum number of workers that a site can scale out to.')
	@minValue(0)
	@maxValue(200)
	functionAppScaleLimit: int?

	@description('Health check path.')
	healthCheckPath: string

	@description('Allow clients to connect over http2.0')
	http20Enabled: bool

	@description('HttpsOnly: configures a web site to accept only https requests. Issues redirect for http requests')
	httpsOnly: bool

	@description('List of allowed IP addresses')
	ipSecurityRestrictions: IpSecurityRestriction[]

	@description('Number of minimum instance count for a site.')
	minimumElasticInstanceCount: int?

	@description('dotNet Framework version.')
	netFrameworkVersion: DotNetVersion

	@description('Number of workers.')
	numberOfWorkers: int?

	@description('Number of pre warmed instances.')
	preWarmedInstanceCount: int?

	@description('true if remote debugging is enabled; otherwise, false.')
	remoteDebuggingEnabled: bool

	@description('true to use 32-bit worker process; otherwise, false')
	use32BitWorkerProcess: bool

	@description('true if WebSocket is enabled; otherwise, false')
	webSocketsEnabled: bool
}

/* PARAMETERS */

@description('Application settings to be used as Environment Variables.')
param appSettings object = {}

@description('Managed Service Identity.')
param identity resourceInput<'Microsoft.Web/sites@2025-03-01'>.identity

@description('Type of site to deploy.')
@allowed([
	'api'
	'app'
])
param kind string

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Configuration parameters.')
param parameters Parameters

@description('The id of the Web/serverfarms resource.')
param serverFarmId string

@description('Tags to put on the resource.')
param tags object = {}

@description('The id of the OperationalInsights/workspaces resource.')
param workspaceId string

/* VARIABLES */

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

var web_serverfarms__id_split = split(
	serverFarmId,
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

resource Web_serverFarms_ 'Microsoft.Web/serverfarms@2025-03-01' existing = {
	name: web_serverfarms__id_split[8]
	scope: resourceGroup(
		web_serverfarms__id_split[2],
		web_serverfarms__id_split[4]
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
				category: 'AppServiceAppLogs'
				enabled: true
			}
			{
				category: 'AppServiceAuditLogs'
				enabled: true
			}
			{
				category: 'AppServiceConsoleLogs'
				enabled: true
			}
			{
				category: 'AppServiceHTTPLogs'
				enabled: true
			}
			{
				category: 'AppServiceIPSecAuditLogs'
				enabled: true
			}
			{
				category: 'AppServicePlatformLogs'
				enabled: true
			}
		]
		metrics: [
			{
				category: 'AllMetrics'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Web_sites_
}

resource Web_sites_ 'Microsoft.Web/sites@2025-03-01' = {
	identity: identity
	kind: kind
	location: location
	name: name
	properties: {
		clientAffinityEnabled: parameters.clientAffinityEnabled
		httpsOnly: parameters.httpsOnly
		serverFarmId: Web_serverFarms_.id
		#disable-next-line BCP073 // in API definition this property is read only
		state: 'Stopped'
	}
	tags: tags
}

resource Web_sites_basicPublishingCredentialsPolicies__FTP 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01' = {
	name: 'ftp'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

resource Web_sites_basicPublishingCredentialsPolicies__SCM 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2025-03-01' = {
	name: 'scm'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

resource Web_sites_config__AppSettings 'Microsoft.Web/sites/config@2025-03-01' = {
	name: 'appsettings'
	parent: Web_sites_
	properties: appSettings
}

resource Web_sites_config__Metadata 'Microsoft.Web/sites/config@2025-03-01' = {
	name: 'metadata'
	parent: Web_sites_
	properties: {
		CURRENT_STACK: 'dotnet'
	}
}

resource Web_sites_config__Web 'Microsoft.Web/sites/config@2025-03-01' = {
	name: 'web'
	parent: Web_sites_
	properties: {
		alwaysOn: parameters.alwaysOn
		apiDefinition: {
			url: (!contains(
					parameters,
					'apiDefinition'
				) || empty(parameters.?apiDefinition))
				? null
				: 'https://${Web_sites_.properties.defaultHostName}${parameters.?apiDefinition}'
		}
		cors: {
			allowedOrigins: parameters.corsAllowedOrigins
		}
		defaultDocuments: []
		ftpsState: 'Disabled'
		functionAppScaleLimit: parameters.?functionAppScaleLimit ?? 0
		healthCheckPath: parameters.?healthCheckPath
		http20Enabled: parameters.http20Enabled
		ipSecurityRestrictions: parameters.ipSecurityRestrictions
		minimumElasticInstanceCount: parameters.?minimumElasticInstanceCount ?? 0
		preWarmedInstanceCount: parameters.?preWarmedInstanceCount ?? 0
		remoteDebuggingEnabled: parameters.remoteDebuggingEnabled
		remoteDebuggingVersion: 'VS2022'
		netFrameworkVersion: parameters.netFrameworkVersion
		numberOfWorkers: parameters.?numberOfWorkers
		use32BitWorkerProcess: parameters.use32BitWorkerProcess
		webSocketsEnabled: parameters.webSocketsEnabled
	}
}

/* OUTPUTS */

@description('The id.')
output id string = Web_sites_.id

@description('The identity.')
output identity object = Web_sites_.identity

@description('The properties.')
output properties object = {
	defaultHostName: Web_sites_.properties.defaultHostName
}
