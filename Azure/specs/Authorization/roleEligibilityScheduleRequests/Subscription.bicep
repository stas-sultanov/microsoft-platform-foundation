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
param requestsProperties resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties[]

/* VARIABLES */

var scope = az.subscription()

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Authorization_roleEligibilityScheduleRequests_ 'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview' = [
	for item in requestsProperties: {
		name: sys.guid(
			scope.id,
			item.roleDefinitionId,
			item.principalId,
			item.scheduleInfo.startDateTime
		)
		properties: item
		scope: scope
	}
]
