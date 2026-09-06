metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ServiceBus/namespaces resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

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

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Alternate name specified when alias and namespace names are same.')
		alternateName: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.alternateName?
		@description('Geo-data replication settings for the namespace.')
		geoDataReplication: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.geoDataReplication?
		@description('IP address type for namespace endpoints.')
		ipAddressType: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.ipAddressType
		@description('Number of premium messaging partitions for the namespace. Requires: sku.name == \'Premium\'.')
		premiumMessagingPartitions: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.premiumMessagingPartitions?
		@description('Private endpoint connections for the namespace.')
		privateEndpointConnections: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.privateEndpointConnections?
		@description('The network access mode.')
		publicNetworkAccess: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.publicNetworkAccess
		@description('Value that indicates whether this namespace is zone-redundant. Requires: sku.name == \'Premium\'.')
		zoneRedundant: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.properties.zoneRedundant
	}
	@description('The SKU.')
	sku: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.sku
	@description('The tags.')
	tags: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.tags
}

/* VARIABLES */

var isPremiumSku = settings.sku.name == 'Premium'

/* RESOURCES */

resource ServiceBus_namespaces_ 'Microsoft.ServiceBus/namespaces@2026-01-01' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: {
		...settings.properties
		disableLocalAuth: true
		minimumTlsVersion: '1.3'
		premiumMessagingPartitions: isPremiumSku
			? settings.properties.?premiumMessagingPartitions
			: null
		zoneRedundant: isPremiumSku
			? settings.properties.zoneRedundant
			: false
	}
	sku: settings.sku
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		ServiceBus_namespaces_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: ServiceBus_namespaces_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: ServiceBus_namespaces_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = ServiceBus_namespaces_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.identity? = ServiceBus_namespaces_.?identity

@description('The name.')
output name string = ServiceBus_namespaces_.name
