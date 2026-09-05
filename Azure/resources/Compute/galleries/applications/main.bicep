metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Compute/galleries/applications resource.'

/* PARAMETERS */

@description('The name of the parent Microsoft.Compute/galleries resource.')
param parentName resourceInput<'Microsoft.Compute/galleries@2025-12-03'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Compute/galleries/applications@2025-12-03'>.name
	@description('The configurable properties.')
	properties: resourceInput<'Microsoft.Compute/galleries/applications@2025-12-03'>.properties
}

/* EXISTING RESOURCES */

resource Compute_galleries_ 'Microsoft.Compute/galleries@2025-12-03' existing = {
	name: parentName
}

/* RESOURCES */

resource Compute_galleries_applications_ 'Microsoft.Compute/galleries/applications@2025-12-03' = {
	location: settings.location
	name: settings.name
	parent: Compute_galleries_
	properties: settings.properties
}

/* OUTPUTS */

@description('The id.')
output id string = Compute_galleries_applications_.id
