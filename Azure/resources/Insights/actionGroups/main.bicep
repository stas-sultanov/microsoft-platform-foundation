metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.Insights/actionGroups resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import {
	PropertiesInput
} from '../../../library/Insights/actionGroups.bicep'

/* PARAMETERS */

@description('The geo-location.')
param location string

@description('The name.')
param name string

@description('The configurable properties.')
param properties PropertiesInput

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

/* OUTPUTS */

@description('The ID.')
output id string = Insights_actionGroups_.id

@description('The name.')
output name string = Insights_actionGroups_.name
