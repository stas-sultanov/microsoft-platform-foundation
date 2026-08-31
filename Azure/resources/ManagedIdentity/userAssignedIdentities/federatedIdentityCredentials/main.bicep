metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The name.')
param name resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30'>.name

@description('The name of the parent Microsoft.ManagedIdentity/userAssignedIdentities resource.')
param parentName resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30'>.name

@description('The properties.')
param properties resourceInput<'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30'>.properties

/* EXISTING RESOURCES */

resource ManagedIdentity_userAssignedIdentities_ 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = {
	name: parentName
}

/* RESOURCES */

resource ManagedIdentity_userAssignedIdentities_federatedIdentityCredentials_ 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
	name: name
	parent: ManagedIdentity_userAssignedIdentities_
	properties: properties
}

/* OUTPUTS */

@description('The id.')
output id string = ManagedIdentity_userAssignedIdentities_federatedIdentityCredentials_.id

@description('The name.')
output name string = ManagedIdentity_userAssignedIdentities_federatedIdentityCredentials_.name
