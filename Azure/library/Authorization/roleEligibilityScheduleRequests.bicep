metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provides reusable types and functions for Microsoft.Authorization/roleEligibilityScheduleRequests resources.'

/* TYPES */

@description('RoleEligibilityScheduleRequestProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('The principal ID.')
	principalId: string
	@description('The role definition name.')
	roleName: string
}

/* FUNCTIONS */

@description('Creates RoleEligibilityScheduleRequestProperties from input configuration.')
@export()
func CreateProperties(
	scopeId string,
	requestType resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2020-10-01'>.properties.requestType,
	scheduleInfo resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2020-10-01'>.properties.scheduleInfo,
	request PropertiesInput
) resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2020-10-01'>.properties => {
	principalId: request.principalId
	requestType: requestType
	roleDefinitionId: az.roleDefinitions(request.roleName).id
	scheduleInfo: scheduleInfo
}

@description('Creates RoleEligibilityScheduleRequestProperties from an array of input configuration.')
@export()
func CreatePropertiesArray(
	scopeId string,
	requestType resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2020-10-01'>.properties.requestType,
	scheduleInfo resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2020-10-01'>.properties.scheduleInfo,
	requests PropertiesInput[]
) resourceInput<'Microsoft.Authorization/roleEligibilityScheduleRequests@2020-10-01'>.properties[] =>
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
