metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions role eligibility schedule requests for a subscription.'

/* SCOPE */

targetScope = 'subscription'

/* PARAMETERS */

@description('Collection of role eligibility schedule request properties.')
param requestsProperties resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview'>.properties[]

/* VARIABLES */

var scope = az.subscription()

/* RESOURCES */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleEligibilityScheduleRequests@2022-04-01-preview' = [
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
