metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Insights/components resources.'

/* TYPES */

@description('ComponentProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('Purge data immediately after 30 days.')
	immediatePurgeDataOn30Days: bool
	@description('Retention period in days.')
	@minValue(30)
	retentionInDays: int
	@description('Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry.')
	@maxValue(100)
	@minValue(0)
	samplingPercentage: int
}
