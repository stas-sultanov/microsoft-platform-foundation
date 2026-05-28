metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types and functions for Microsoft.Authorization/roleDefinitions resources.'

/* TYPES */

@description('RoleDefinitionProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('The role definition description.')
	description: string
	@description('Role definition permissions.')
	permissions: resourceInput<'Microsoft.Authorization/roleDefinitions@2022-04-01'>.properties.permissions
	@description('The role name.')
	roleName: string
}

/* FUNCTIONS */

@description('Creates RoleDefinitionProperties from input configuration.')
@export()
func CreateProperties(
	assignableScopes string[],
	definition PropertiesInput
) resourceInput<'Microsoft.Authorization/roleDefinitions@2022-04-01'>.properties => {
	assignableScopes: assignableScopes
	description: definition.description
	permissions: definition.permissions
	roleName: definition.roleName
	type: 'CustomRole'
}

@description('Creates RoleDefinitionProperties from an array of input configuration.')
@export()
func CreatePropertiesArray(
	assignableScopes string[],
	definitions PropertiesInput[]
) resourceInput<'Microsoft.Authorization/roleDefinitions@2022-04-01'>.properties[] =>
	sys.map(
		definitions,
		definition =>
			CreateProperties(
				assignableScopes,
				definition
			)
	)
