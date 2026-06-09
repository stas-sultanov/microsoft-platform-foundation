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

@description('The name.')
@minLength(1)
param name string

@description('The name of the parent resource of Microsoft.ServiceBus/namespaces type.')
param parentNamespaceName string

@description('The name of the parent resource of Microsoft.ServiceBus/namespaces/topics type.')
param parentTopicName string

@description('The properties.')
param properties resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01'>.properties

@description('The child resources.')
param resources {
	rules: {
		@description('The name.')
		name: string
		@description('The properties.')
		properties: resourceInput<'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2024-01-01'>.properties
	}[]
}?

/* EXISTING RESOURCES */

resource ServiceBus_namespaces_ 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
	name: parentNamespaceName
}

resource ServiceBus_namespaces_topics_ 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' existing = {
	name: parentTopicName
	parent: ServiceBus_namespaces_
}

/* RESOURCES */

resource ServiceBus_namespaces_topics_subscriptions_ 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01' = {
	name: name
	parent: ServiceBus_namespaces_topics_
	properties: properties
}

resource ServiceBus_namespaces_topics_subscriptions_rules_ 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2024-01-01' = [
	for resource in resources.?rules ?? []: {
		name: resource.name
		parent: ServiceBus_namespaces_topics_subscriptions_
		properties: resource.properties
	}
]

/* OUTPUTS */

@description('The name.')
output name string = ServiceBus_namespaces_topics_subscriptions_.name
