metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkWatchers/connectionMonitors resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2025-07-01'>.name

@description('The name of the parent Microsoft.Network/networkWatchers resource.')
param parentName string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2025-07-01'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Network/networkWatchers/connectionMonitors@2025-07-01'>.tags

/* EXISTING RESOURCES */

resource Network_networkWatchers_ 'Microsoft.Network/networkWatchers@2025-07-01' existing = {
	name: parentName
}

/* RESOURCES */

resource Network_networkWatchers_connectionMonitors_ 'Microsoft.Network/networkWatchers/connectionMonitors@2025-07-01' = {
	location: location
	name: name
	parent: Network_networkWatchers_
	properties: properties
	tags: tags
}

/* OUTPUTS */

@description('The id.')
output id string = Network_networkWatchers_connectionMonitors_.id

@description('The name.')
output name string = Network_networkWatchers_connectionMonitors_.name
