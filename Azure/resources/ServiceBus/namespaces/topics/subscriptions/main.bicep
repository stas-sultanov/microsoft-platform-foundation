metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ServiceBus/namespaces/topics/subscriptions resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The child resources.')
@sealed()
param resources {
	rules: {
		*: {
			@description('The name.')
			name: string
			@description('The properties.')
			properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2024-01-01'>.properties
		}
	}
}?

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	@sealed()
	name: {
		@description('The name of the Microsoft.ServiceBus/namespaces resource.')
		namespace: resourceInput<'Microsoft.ServiceBus/namespaces@2026-01-01'>.name
		@description('The name of the Microsoft.ServiceBus/namespaces/topics resource.')
		topic: resourceInput<'Microsoft.ServiceBus/namespaces/topics@2026-01-01'>.name
		@description('The name of the Microsoft.ServiceBus/namespaces/topics/subscriptions resource.')
		@minLength(1)
		subscription: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions@2026-01-01'>.name
	}
	@description('The properties.')
	properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01'>.properties
}

/* EXISTING RESOURCES */

resource ServiceBus_namespaces_ 'Microsoft.ServiceBus/namespaces@2026-01-01' existing = {
	name: settings.name.namespace
	resource topics_ 'topics' existing = {
		name: settings.name.topic
	}
}

/* RESOURCES */

resource ServiceBus_namespaces_topics_subscriptions_ 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2026-01-01' = {
	name: settings.name.subscription
	parent: ServiceBus_namespaces_::topics_
	properties: settings.properties
}

resource ServiceBus_namespaces_topics_subscriptions_rules_ 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2026-01-01' = [
	for item in items(resources.?rules ?? {}): {
		name: item.value.name
		parent: ServiceBus_namespaces_topics_subscriptions_
		properties: item.value.properties
	}
]

/* OUTPUTS */

@description('The name.')
output name string = ServiceBus_namespaces_topics_subscriptions_.name
