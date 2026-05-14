metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for a management group.'

/* SCOPE */

targetScope = 'managementGroup'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

/* VARIABLES */

var resources {
	name: string
	properties: resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties
}[] = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			scope.id,
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
	}
]

var scope = az.managementGroup()

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for resource in resources: {
		name: resource.name
		properties: resource.properties
		scope: scope
	}
]

/* OUTPUTS */

@description('The names.')
output names string[] = sys.map(
	resources,
	resource =>	resource.name
)
