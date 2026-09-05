metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Maintenance/maintenanceConfigurations resource.'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
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
	tags: resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.tags
}

/* RESOURCES */

resource Maintenance_maintenanceConfigurations_ 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
	location: settings.location
	name: settings.name
	properties: {
		extensionProperties: {
			InGuestPatchMode: 'user'
		}
		installPatches: {
			linuxParameters: {
				classificationsToInclude: [
					'Critical'
					'Security'
				]
			}
			rebootSetting: 'RebootIfRequired'
		}
		maintenanceScope: 'InGuestPatch'
		maintenanceWindow: {
			...settings.properties.maintenanceWindow
			duration: '04:00' // This is the hard requirement on the date of writing this
		}
		visibility: settings.properties.?visibility ?? 'Custom'
	}
	tags: settings.tags
}

/* OUTPUTS */

@description('The id.')
output id string = Maintenance_maintenanceConfigurations_.id

@description('The name.')
output name string = Maintenance_maintenanceConfigurations_.name
