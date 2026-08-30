metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Maintenance/maintenanceConfigurations resource.'

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.name

@description('The configurable properties.')
@sealed()
param properties {
	@description('The maintenance window of the configuration.')
	maintenanceWindow: {
		@description('The recurrence interval.')
		recurEvery: string
		@description('The effective start date.')
		startDateTime: string
		@description('The time zone.')
		timeZone: string
	}
	@description('The visibility of the configuration.')
	visibility: resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.properties.visibility?
}

@description('The tags.')
param tags resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.tags

/* RESOURCES */

resource Maintenance_maintenanceConfigurations_ 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
	location: location
	name: name
	properties: {
		maintenanceScope: 'OSImage'
		maintenanceWindow: {
			...properties.maintenanceWindow
			duration: '05:00' // This is the hard requirement on the date of writing this
		}
		visibility: properties.?visibility ?? 'Custom'
	}
	tags: tags
}

/* OUTPUTS */

@description('The id.')
output id string = Maintenance_maintenanceConfigurations_.id

@description('The name.')
output name string = Maintenance_maintenanceConfigurations_.name
