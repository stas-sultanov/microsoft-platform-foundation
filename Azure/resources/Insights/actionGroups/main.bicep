metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/actionGroups resource with extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]
	}?
}

@description('The resource settings.')
@sealed()
param settings {
	@description('The identity.')
	identity: resourceInput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.identity?
	@description('The geo-location.')
	location: string
	@description('The name.')
	name: resourceInput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('Indicates whether this action group is enabled.')
		enabled: bool
		@description('The short name of the action group.')
		groupShortName: resourceInput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.properties.groupShortName
		@description('The webhook receivers.')
		webhookReceivers: resourceInput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.properties.webhookReceivers
	}
	@description('The tags.')
	tags: resourceInput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.tags
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // Managed identity support is available only in the preview API.
resource Insights_actionGroups_ 'Microsoft.Insights/actionGroups@2024-10-01-preview' = {
	identity: settings.?identity ?? {
		type: 'None'
	}
	location: settings.location
	name: settings.name
	properties: settings.properties
	tags: settings.tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		Insights_actionGroups_.id,
		extensions.?Authorization.roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: Insights_actionGroups_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Insights_actionGroups_.id

@description('The identity.')
output identity resourceOutput<'Microsoft.Insights/actionGroups@2024-10-01-preview'>.identity? = Insights_actionGroups_.?identity

@description('The name.')
output name string = Insights_actionGroups_.name
