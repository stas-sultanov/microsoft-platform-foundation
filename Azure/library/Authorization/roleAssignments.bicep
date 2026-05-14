metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provides reusable types and functions for Microsoft.Authorization/roleAssignments resources.'

/* TYPES */

@description('RoleAssignmentProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('Description of role assignment.')
	description: string
	@description('The principal ID.')
	principalId: string
	@description('The principal type of the assigned principal ID.')
	principalType: resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties.principalType?
	@description('The role definition name.')
	roleName: string
}

@export()
@sealed()
type ResourceInput = {
	@description('The configurable properties.')
	properties: PropertiesInput
}

@export()
@sealed()
type Resource = {
	@description('The name.')
	name: string
	@description('The properties.')
	properties: resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties
}

/* FUNCTIONS */

@description('Creates resource from input configuration.')
@export()
func Create(
	scopeId string,
	input ResourceInput
) Resource => {
	name: sys.guid(
		scopeId,
		input.properties.roleName,
		input.properties.principalId
	)
	properties: CreateProperties(input.properties)
}

@description('Creates resources from an array of input configuration.')
@export()
func CreateArray(
	scopeId string,
	inputs ResourceInput[]
) Resource[] =>
	sys.map(
		inputs,
		input =>
			Create(
				scopeId,
				input
			)
	)

@description('Creates RoleAssignmentProperties from input configuration.')
@export()
func CreateProperties(
	input PropertiesInput
) resourceInput<'Microsoft.Authorization/roleAssignments@2022-04-01'>.properties => {
	description: input.description
	principalId: input.principalId
	principalType: input.?principalType
	roleDefinitionId: az.roleDefinitions(input.roleName).id
}
