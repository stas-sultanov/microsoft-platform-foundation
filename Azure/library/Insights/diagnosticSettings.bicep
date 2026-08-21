metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Insights/diagnosticSettings resources.'

/* TYPES */

@description('DiagnosticSettingsProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('The list of logs settings.')
	logs: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs?
	@description('The list of metric settings.')
	metrics: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics?
}

@description('The configuration of a Microsoft.Insights/diagnosticSettings resource.')
@export()
@sealed()
type Resource = {
	@description('The name.')
	name: string
	@description('The properties.')
	properties: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties
}

/* FUNCTIONS */

@description('Creates Resource from configurable properties.')
@export()
func CreateResourceWithLogAnalyticsWorkspace(
	name string,
	properties PropertiesInput,
	workspaceId string
) Resource => {
	name: name
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: properties.?logs ?? []
		metrics: properties.?metrics ?? []
		workspaceId: workspaceId
	}
}
