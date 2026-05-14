metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provides reusable types for Microsoft.Insights/actionGroups resources.'

/* TYPES */

@description('ActionGroupProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('Indicates whether this action group is enabled.')
	enabled: bool?
	@description('The short name of the action group.')
	groupShortName: resourceInput<'Microsoft.Insights/actionGroups@2023-01-01'>.properties.groupShortName
	@description('The webhook receivers.')
	webhookReceivers: resourceInput<'Microsoft.Insights/actionGroups@2023-01-01'>.properties.webhookReceivers
}
