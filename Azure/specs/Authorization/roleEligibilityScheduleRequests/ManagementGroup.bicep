metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role eligibility schedule requests for a management group.'

/* SCOPE */

targetScope = 'managementGroup'

/* PARAMETERS */

@description('Collection of role eligibility schedule request properties.')
param requestsProperties resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview'>.properties[]

/* VARIABLES */

var scope = az.managementGroup()

/* RESOURCES */

resource Authorization_roleEligibilityScheduleRequests_ 'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview' = [
	for properties in requestsProperties: {
		name: sys.guid(
			scope.id,
			properties.roleDefinitionId,
			properties.principalId,
			properties.scheduleInfo.startDateTime
		)
		properties: properties
		scope: scope
	}
]
