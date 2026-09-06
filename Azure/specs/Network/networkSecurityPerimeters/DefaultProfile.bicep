metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Network/networkSecurityPerimeters resource with one profile and associations.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

import * as NetworkNetworkSecurityPerimeters from '../../../library/Network/networkSecurityPerimeters.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The child resources.')
@sealed()
param resources {
	profiles: {
		Default: {
			@description('The name.')
			name: string
			@description('The child resources.')
			resources: {
				accessRules: NetworkNetworkSecurityPerimeters.AccessRuleChildResource[]
			}
		}
	}
	resourceAssociations: {
		*: {
			@description('The name.')
			name: string
			@description('The configurable properties.')
			properties: {
				accessMode: resourceInput<'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01'>.properties.accessMode
				privateLinkResource: resourceInput<'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01'>.properties.privateLinkResource
			}
		}
	}
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Network/networkSecurityPerimeters@2025-07-01'>.name
	@description('The tags.')
	tags: resourceInput<'Microsoft.Network/networkSecurityPerimeters@2025-07-01'>.tags
}

/* RESOURCES */

resource Network_networkSecurityPerimeters_ 'Microsoft.Network/networkSecurityPerimeters@2025-07-01' = {
	location: settings.location
	name: settings.name
	properties: {}
	tags: settings.tags
}

resource Network_networkSecurityPerimeters_profiles__Default 'Microsoft.Network/networkSecurityPerimeters/profiles@2025-07-01' = {
	name: resources.profiles.Default.name
	parent: Network_networkSecurityPerimeters_
	properties: {}
}

resource Network_networkSecurityPerimeters_profiles_accessRules__Default 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2025-07-01' = [
	for item in resources.profiles.Default.resources.accessRules: {
		name: item.name
		parent: Network_networkSecurityPerimeters_profiles__Default
		properties: item.properties
	}
]

resource Network_networkSecurityPerimeters_resourceAssociations_ 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2025-07-01' = [
	for item in items(resources.resourceAssociations ?? {}): {
		name: item.value.name
		parent: Network_networkSecurityPerimeters_
		properties: {
			...item.value.properties
			profile: {
				id: Network_networkSecurityPerimeters_profiles__Default.id
			}
		}
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Network_networkSecurityPerimeters_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityPerimeters_
	}
]

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Network_networkSecurityPerimeters_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Network_networkSecurityPerimeters_.id

@description('The name.')
output name string = Network_networkSecurityPerimeters_.name

@description('The child resources.')
output resources {
	profiles: {
		Default: {
			name: string
		}
	}
} = {
	profiles: {
		Default: {
			name: resources.profiles.Default.name
		}
	}
}
