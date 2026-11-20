metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkWatchers/connectionMonitors resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

@description('A connection monitor endpoint of one of the supported endpoint types.')
@discriminator('type')
@sealed()
type Endpoint =
	| EndpointAzureSubnet
	| EndpointAzureVM
	| EndpointAzureVMSS
	| EndpointAzureVNet
	| EndpointExternalAddress

@description('An endpoint for an Azure subnet.')
@sealed()
type EndpointAzureSubnet = {
	@description('The test coverage for the endpoint.')
	coverageLevel: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.endpoints[*].coverageLevel?
	@description('The name of the endpoint.')
	name: string
	@description('The ID of the Microsoft.Network/virtualNetworks/subnets resource.')
	resourceId: string
	@description('The addresses included in or excluded from the endpoint.')
	scope: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.endpoints[*].scope?
	@description('The endpoint type.')
	type: 'AzureSubnet'
}

@description('An endpoint for an Azure virtual machine.')
@sealed()
type EndpointAzureVM = {
	@description('The address of the virtual machine.')
	address: string?
	@description('The name of the endpoint.')
	name: string
	@description('The ID of the Microsoft.Compute/virtualMachines resource.')
	resourceId: string
	@description('The endpoint type.')
	type: 'AzureVM'
}

@description('An endpoint for an Azure virtual machine scale set.')
@sealed()
type EndpointAzureVMSS = {
	@description('The test coverage for the endpoint.')
	coverageLevel: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.endpoints[*].coverageLevel?
	@description('The name of the endpoint.')
	name: string
	@description('The ID of the Microsoft.Compute/virtualMachineScaleSets resource.')
	resourceId: string
	@description('The addresses included in or excluded from the endpoint.')
	scope: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.endpoints[*].scope?
	@description('The endpoint type.')
	type: 'AzureVMSS'
}

@description('An endpoint for an Azure virtual network.')
@sealed()
type EndpointAzureVNet = {
	@description('The test coverage for the endpoint.')
	coverageLevel: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.endpoints[*].coverageLevel?
	@description('The name of the endpoint.')
	name: string
	@description('The ID of the Microsoft.Network/virtualNetworks resource.')
	resourceId: string
	@description('The addresses included in or excluded from the endpoint.')
	scope: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.endpoints[*].scope?
	@description('The endpoint type.')
	type: 'AzureVNet'
}

@description('An endpoint for an external IP address, FQDN, or URL.')
@sealed()
type EndpointExternalAddress = {
	@description('The IP address, FQDN, or URL of the endpoint.')
	address: string
	@description('The name of the endpoint.')
	name: string
	@description('The endpoint type.')
	type: 'ExternalAddress'
}

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	@sealed()
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The name of the parent Microsoft.Network/networkWatchers resource.')
param parentName resourceInput<'Microsoft.Network/networkWatchers@2026-03-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Specifies whether the connection monitor starts automatically after creation.')
		autoStart: bool?
		@description('The connection monitor endpoints.')
		endpoints: Endpoint[]
		@description('The notes associated with the connection monitor.')
		notes: string?
		@description('The connection monitor outputs.')
		outputs: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.outputs?
		@description('The connection monitor test configurations.')
		testConfigurations: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.testConfigurations
		@description('The connection monitor test groups.')
		testGroups: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.properties.testGroups
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01'>.tags
}

/* EXISTING RESOURCES */

resource Network_networkWatchers_ 'Microsoft.Network/networkWatchers@2026-03-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_networkWatchers_connectionMonitors_ 'Microsoft.Network/networkWatchers/connectionMonitors@2026-03-01' = {
	location: settings.location
	name: settings.name
	parent: Network_networkWatchers_
	properties: settings.properties
	tags: settings.tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // The repository selects this preview API for all diagnostic settings.
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkWatchers_connectionMonitors_
	}
]
