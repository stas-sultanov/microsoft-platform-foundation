metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Maintenance/configurationAssignments resources.'

/* TYPES */

@description('The configuration of a Microsoft.Maintenance/configurationAssignments resource.')
@export()
@sealed()
type Resource = {
	@description('The name.')
	name: string
	@description('The properties.')
	properties: resourceInput<'Microsoft.Maintenance/configurationAssignments@2023-04-01'>.properties
}
