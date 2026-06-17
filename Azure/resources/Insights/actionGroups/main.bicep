metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/actionGroups resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as ActionGroups from '../../../library/Insights/actionGroups.bicep'

import * as AuthorizationRoleAssignments from '../../../library/Authorization/roleAssignments.bicep'

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Authorization: {
		roleAssignments: AuthorizationRoleAssignments.ResourceInput[]?
	}?
}?

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties ActionGroups.PropertiesInput

@description('The tags.')
param tags resourceInput<'Microsoft.Insights/actionGroups@2023-01-01'>.tags

/* RESOURCES */

resource Insights_actionGroups_ 'Microsoft.Insights/actionGroups@2023-01-01' = {
	location: location
	name: name
	properties: {
		enabled: properties.?enabled ?? true
		groupShortName: properties.groupShortName
		webhookReceivers: properties.webhookReceivers
	}
	tags: tags
}

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for extension in AuthorizationRoleAssignments.CreateArray(
		Insights_actionGroups_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: extension.name
		properties: extension.properties
		scope: Insights_actionGroups_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = Insights_actionGroups_.id

@description('The name.')
output name string = Insights_actionGroups_.name
