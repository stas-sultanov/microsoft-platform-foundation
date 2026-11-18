metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ServiceBus/namespaces/topics resource'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The name of the parent Microsoft.ServiceBus/namespaces resource.')
param parentName resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	name: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The ISO 8601 idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.')
		autoDeleteOnIdle: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.autoDeleteOnIdle?
		@description('The default ISO 8601 message time-to-live value.')
		defaultMessageTimeToLive: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.defaultMessageTimeToLive?
		@description('The ISO 8601 duration of the duplicate detection history.')
		duplicateDetectionHistoryTimeWindow: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.duplicateDetectionHistoryTimeWindow?
		@description('Specifies whether server-side batched operations are enabled.')
		enableBatchedOperations: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.enableBatchedOperations?
		@description('Specifies whether express entities are enabled.')
		enableExpress: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.enableExpress?
		@description('Specifies whether the topic is partitioned across message brokers.')
		enablePartitioning: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.enablePartitioning?
		@description('The maximum message payload size in kilobytes. This property is only used in Premium namespaces.')
		maxMessageSizeInKilobytes: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.maxMessageSizeInKilobytes?
		@description('The maximum size of the topic in megabytes.')
		maxSizeInMegabytes: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.maxSizeInMegabytes?
		@description('Specifies whether the topic requires duplicate detection.')
		requiresDuplicateDetection: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.requiresDuplicateDetection?
		@description('The desired operational status of the topic: Active, Disabled, SendDisabled, or ReceiveDisabled.')
		status:
			| 'Active'
			| 'Disabled'
			| 'SendDisabled'
			| 'ReceiveDisabled'
			| null
		@description('Specifies whether the topic supports ordering.')
		supportOrdering: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.supportOrdering?
		@description('User metadata associated with the topic.')
		userMetadata: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.properties.userMetadata?
	}
}

/* EXISTING RESOURCES */

resource ServiceBus_namespaces_ 'Microsoft.ServiceBus/namespaces@2026-01-01' existing = {
	name: parentName
}

/* RESOURCES */

resource ServiceBus_namespaces_topics_ 'Microsoft.ServiceBus/namespaces/topics@2026-01-01' = {
	name: settings.name
	parent: ServiceBus_namespaces_
	properties: settings.properties
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		ServiceBus_namespaces_topics_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: ServiceBus_namespaces_topics_
	}
]
