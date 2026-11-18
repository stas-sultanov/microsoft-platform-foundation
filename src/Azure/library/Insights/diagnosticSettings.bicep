metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Insights/diagnosticSettings resources.'

/* TYPES */

@description('The configuration of a Microsoft.Insights/diagnosticSettings resource.')
@export()
@sealed()
type Resource = {
	@description('The name.')
	name: string
	@description('The properties.')
	properties: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties
}

@description('The input configuration of a Microsoft.Insights/diagnosticSettings resource.')
@export()
@sealed()
type ResourceInput = {
	@description('The name.')
	name: string
	@description('The configurable properties.')
	properties: {
		@description('The list of logs settings.')
		logs: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs?
		@description('The list of metric settings.')
		metrics: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics?
	}
}

/* FUNCTIONS */

@description('Creates Resource with Log Analytics Workspace destination.')
@export()
func CreateWithLogAnalyticsWorkspace(
	resourceInput ResourceInput,
	workspaceId string
) Resource => {
	name: resourceInput.name
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: resourceInput.properties.?logs ?? []
		metrics: resourceInput.properties.?metrics ?? []
		workspaceId: workspaceId
	}
}
