metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions custom role definitions for a management group.'

/* SCOPE */

targetScope = 'managementGroup'

/* PARAMETERS */

@description('Collection of role definition properties.')
param definitionsProperties resourceInput<'Microsoft.Authorization/roleDefinitions@2022-04-01'>.properties[]

/* RESOURCES */

resource Authorization_roleDefinitions_ 'Microsoft.Authorization/roleDefinitions@2022-04-01' = [
	for item in definitionsProperties: {
		name: sys.guid(item.roleName)
		properties: item
	}
]
