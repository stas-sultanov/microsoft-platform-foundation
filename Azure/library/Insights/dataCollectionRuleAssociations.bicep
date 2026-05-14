metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provides reusable types for Microsoft.Insights/dataCollectionRuleAssociations resources.'

/* TYPES */

@export()
@sealed()
type Resource = {
	@description('The name.')
	name: string
	@description('The properties.')
	properties: resourceInput<'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11'>.properties
}
