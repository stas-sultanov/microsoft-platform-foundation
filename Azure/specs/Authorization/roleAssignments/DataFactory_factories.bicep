metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a resource of Microsoft.DataFactory/factories type.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

@description('Name of the Microsoft.DataFactory/factories resource.')
param name string

/* EXISTING RESOURCES */

resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' existing = {
	name: name
}

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			DataFactory_factories_.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: DataFactory_factories_
	}
]
