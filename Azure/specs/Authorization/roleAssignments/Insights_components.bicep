metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.Insights/components type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.Insights/components resource.')
param name string

/* EXISTING RESOURCES */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			Insights_components_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: Insights_components_
	}
]
