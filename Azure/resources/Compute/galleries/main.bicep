metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Compute/galleries resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Compute/galleries@2025-03-03'>.properties

@description('The tags.')
param tags resourceInput<'Microsoft.Compute/galleries@2025-03-03'>.tags

/* RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-03-03' = {
	location: location
	name: name
	properties: properties
	tags: tags
}

/* OUTPUTS */

@description('The id.')
output id string = Compute_galleries_.id

@description('The name.')
output name string = Compute_galleries_.name
