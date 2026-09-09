metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types and functions for Microsoft.Authorization/roleEligibilityScheduleRequests resources.'

/* TYPES */

@description('RoleEligibilityScheduleRequestProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('The principal id.')
	principalId: string
	@description('The role definition name.')
	roleName: string
}

/* FUNCTIONS */

@description('Creates RoleEligibilityScheduleRequestProperties from input configuration.')
@export()
func CreateProperties(
	scopeId string,
	requestType resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties.requestType,
	scheduleInfo resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties.scheduleInfo,
	request PropertiesInput
) resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties => {
	principalId: request.principalId
	requestType: requestType
	roleDefinitionId: az.roleDefinitions(request.roleName).id
	scheduleInfo: scheduleInfo
}

@description('Creates RoleEligibilityScheduleRequestProperties from an array of input configuration.')
@export()
func CreatePropertiesArray(
	scopeId string,
	requestType resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties.requestType,
	scheduleInfo resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties.scheduleInfo,
	requests PropertiesInput[]
) resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2024-09-01-preview'>.properties[] =>
	sys.map(
		requests,
		request =>
			CreateProperties(
				scopeId,
				requestType,
				scheduleInfo,
				request
			)
	)
