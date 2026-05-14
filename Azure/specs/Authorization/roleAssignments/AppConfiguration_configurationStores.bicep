metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.AppConfiguration/configurationStores type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.AppConfiguration/configurationStores resource.')
param name string

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions
resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			AppConfiguration_configurationStores_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: AppConfiguration_configurationStores_
	}
]
