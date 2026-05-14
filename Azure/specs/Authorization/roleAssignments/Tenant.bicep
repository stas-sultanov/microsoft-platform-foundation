metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions role assignments for the tenant root.'

/* SCOPE */

targetScope = 'tenant'

/* PARAMETERS */

@description('Collection of role assignments.')
param assignmentsProperties resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties[]

/* VARIABLES */

var scope = az.tenant()

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for properties in assignmentsProperties: {
		name: sys.guid(
			properties.roleDefinitionId,
			properties.principalId
		)
		properties: properties
		scope: scope
	}
]
