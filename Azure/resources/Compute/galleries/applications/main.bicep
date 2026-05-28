metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/galleries/applications resource.'

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The name.')
param parentName string

@description('The configurable properties.')
param properties resourceInput<'Microsoft.Compute/galleries/applications@2024-03-03'>.properties

/* EXISTING RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-03-03' existing = {
	name: parentName
}

/* RESOURCES */

resource Compute_galleries_applications_ 'Microsoft.Compute/galleries/applications@2025-03-03' = {
	location: location
	name: name
	parent: Compute_galleries_
	properties: properties
}

/* OUTPUTS */

@description('The id.')
output id string = Compute_galleries_applications_.id
