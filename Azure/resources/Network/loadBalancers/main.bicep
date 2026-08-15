metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Load Balancer and assigns Insights Diagnostic extensions.'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Network/loadBalancers@2025-07-01'>.properties

@description('The SKU.')
param sku resourceInput<'Microsoft.Network/loadBalancers@2025-07-01'>.sku

@description('The tags.')
param tags resourceInput<'Microsoft.Network/loadBalancers@2025-07-01'>.tags

/* RESOURCES */

resource Network_loadBalancers_ 'Microsoft.Network/loadBalancers@2025-07-01' = {
	location: location
	name: name
	properties: properties
	sku: sku
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_loadBalancers_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_loadBalancers_.id

@description('Properties of load balancer.')
output properties {
	@description('Collection of backend address pools used by a load balancer.')
	backendAddressPools: resourceOutput<'Microsoft.Network/loadBalancers@2025-07-01'>.properties.backendAddressPools
} = {
	backendAddressPools: Network_loadBalancers_.properties.backendAddressPools
}
