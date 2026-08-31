metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ManagedIdentity/userAssignedIdentities resource with child resources and extensions.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

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
param name resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30'>.name

@description('The configurable properties.')
param properties resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30'>.properties = {}

@description('The child resources.')
@sealed()
param resources {
	@description('The federated identity credentials.')
	federatedIdentityCredentials: {
		@description('The resource name.')
		name: resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30'>.name
		@description('The properties.')
		properties: resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30'>.properties
	}[]?
} = {}

@description('The tags.')
param tags resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30'>.tags

/* RESOURCES */

resource ManagedIdentity_userAssignedIdentities_ 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
	location: location
	name: name
	properties: properties
	tags: tags
}

resource ManagedIdentity_userAssignedIdentities_federatedIdentityCredentials_ 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = [
	for item in resources.?federatedIdentityCredentials ?? []: {
		name: item.name
		parent: ManagedIdentity_userAssignedIdentities_
		properties: item.properties
	}
]

/* EXTENSIONS */

resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for item in AuthorizationRoleAssignments.CreateArray(
		ManagedIdentity_userAssignedIdentities_.id,
		extensions.?Authorization.?roleAssignments ?? []
	): {
		name: item.name
		properties: item.properties
		scope: ManagedIdentity_userAssignedIdentities_
	}
]

/* OUTPUTS */

@description('The id.')
output id string = ManagedIdentity_userAssignedIdentities_.id

@description('The name.')
output name string = ManagedIdentity_userAssignedIdentities_.name

@description('The properties.')
output properties {
	clientId: resourceOutput<'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30'>.properties.clientId
	principalId: resourceOutput<'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30'>.properties.principalId
} = {
	clientId: ManagedIdentity_userAssignedIdentities_.properties.clientId
	principalId: ManagedIdentity_userAssignedIdentities_.properties.principalId
}
