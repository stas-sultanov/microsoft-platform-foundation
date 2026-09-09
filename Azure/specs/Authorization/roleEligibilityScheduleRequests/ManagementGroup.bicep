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
param requestsProperties resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties[]

/* VARIABLES */

@description('The ID of the management group.')
var scopeId = az.managementGroup().id

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource Authorization_roleEligibilityScheduleRequests_ 'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview' = [
	for item in requestsProperties: {
		name: sys.guid(
			scopeId,
			item.roleDefinitionId,
			item.principalId,
			item.scheduleInfo.startDateTime
		)
		properties: item
	}
]
