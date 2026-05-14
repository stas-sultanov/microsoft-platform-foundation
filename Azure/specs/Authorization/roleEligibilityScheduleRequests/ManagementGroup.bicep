metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
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

#disable-next-line use-recent-api-versions
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
