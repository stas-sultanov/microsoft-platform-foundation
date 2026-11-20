metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Insights/diagnosticSettings resources.'

/* TYPES */

@description('The log settings of a Microsoft.Insights/diagnosticSettings resource.')
@sealed()
type LogSettings = {
	@description('The diagnostic log category.')
	category: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs[*].category?
	@description('The diagnostic log category group.')
	categoryGroup: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs[*].categoryGroup?
	@description('Specifies whether the log category is enabled.')
	enabled: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logs[*].enabled
}

@description('The metric settings of a Microsoft.Insights/diagnosticSettings resource.')
@sealed()
type MetricSettings = {
	@description('The diagnostic metric category.')
	category: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics[*].category?
	@description('Specifies whether the metric category is enabled.')
	enabled: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics[*].enabled
	@description('The metric time grain in ISO 8601 format.')
	timeGrain: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.metrics[*].timeGrain?
}

@description('The configuration of a Microsoft.Insights/diagnosticSettings resource, excluding Marketplace partner destinations and diagnostic retention policies.')
@export()
@sealed()
type Resource = {
	@description('The name.')
	name: string
	@description('The properties.')
	@sealed()
	properties: {
		@description('The Log Analytics destination type.')
		logAnalyticsDestinationType: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.logAnalyticsDestinationType?
		@description('The list of logs settings.')
		logs: LogSettings[]?
		@description('The list of metric settings.')
		metrics: MetricSettings[]?
		@description('The ID of the Microsoft.Storage/storageAccounts resource.')
		storageAccountId: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.storageAccountId?
		@description('The ID of the Microsoft.OperationalInsights/workspaces resource.')
		workspaceId: resourceInput<'Microsoft.Insights/diagnosticSettings@2021-05-01-preview'>.properties.workspaceId?
	}
}

@description('The input configuration of a Microsoft.Insights/diagnosticSettings resource.')
@export()
@sealed()
type ResourceInput = {
	@description('The name.')
	name: string
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The list of logs settings.')
		logs: LogSettings[]?
		@description('The list of metric settings.')
		metrics: MetricSettings[]?
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
		logs: resourceInput.properties.?logs
		metrics: resourceInput.properties.?metrics
		workspaceId: workspaceId
	}
}
