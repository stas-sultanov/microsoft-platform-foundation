metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions custom role definitions for a management group.'

/* SCOPE */

targetScope = 'managementGroup'

/* PARAMETERS */

@description('Collection of role definition properties.')
param definitionsProperties resourceInput<'Microsoft.Authorization/roleDefinitions@2022-04-01'>.properties[]

/* VARIABLES */

var definitions = [
	for properties in definitionsProperties: {
		name: sys.guid(properties.roleName)
		properties: properties
	}
]

var scope = az.managementGroup()

/* RESOURCES */

resource Authorization_roleDefinitions_ 'Microsoft.Authorization/roleDefinitions@2022-04-01' = [
	for definition in definitions: {
		name: definition.name
		properties: definition.properties
		scope: scope
	}
]

/* OUTPUTS */

@description('The names.')
output names string[] = [
	for definition in definitions: definition.name
]
