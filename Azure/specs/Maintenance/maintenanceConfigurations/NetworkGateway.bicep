metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Maintenance/maintenanceConfigurations resource.'

/* TYPES */

@export()
type PropertiesInput = {
	@description('The maintenance window of the configuration.')
	maintenanceWindow: {
		@description('The start time of the maintenance window.')
		startTime: string
		@description('The time zone of the maintenance window.')
		timeZone: string
	}
	@description('The visibility of the configuration.')
	visibility: resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.properties.visibility?
}

/* PARAMETERS */

@description('Current date in UTC.')
param currentDateUTC string = utcNow('d')

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties PropertiesInput

@description('The tags.')
param tags resourceInput<'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01'>.tags

/* VARIABLES */

var maintenanceStartDate = sys.dateTimeAdd(
	currentDateUTC,
	'P1D',
	'yyyy-MM-dd'
)

/* RESOURCES */

resource Maintenance_maintenanceConfigurations_ 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
	location: location
	name: name
	properties: {
		extensionProperties: {
			maintenanceSubScope: 'NetworkGatewayMaintenance'
		}
		maintenanceScope: 'Resource'
		maintenanceWindow: {
			duration: '05:00' // This is the hard requirement on the date of writing this
			recurEvery: '1Day' // This is the hard requirement on the date of writing this
			startDateTime: '${maintenanceStartDate} ${properties.maintenanceWindow.startTime}'
			timeZone: properties.maintenanceWindow.timeZone
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
