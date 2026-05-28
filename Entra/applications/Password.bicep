metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions an Entra application with password credentials.'

/* SCOPE */

targetScope = 'tenant'

/* EXTENSIONS */

extension microsoftGraph

/* TYPES */

@export()
@sealed()
type Settings = {
	@description('The display name for the application.')
	@maxLength(256)
	@minLength(3)
	displayName: string

	@description('Basic profile information of the application.')
	info: resourceInput<'Microsoft.Graph/applications@beta'>.info

	@description('The base64-encoded logo for the application.')
	logo: string

	@description('Management notes for the application.')
	notes: string

	@description('The owners of the application.')
	owners: string[]?

	@description('The collection of password credentials associated with the application.')
	passwordCredentials: resourceInput<'Microsoft.Graph/applications@beta'>.passwordCredentials

	@description('Specifies the resources that the application needs to access.')
	requiredResourceAccess: resourceInput<'Microsoft.Graph/applications@beta'>.requiredResourceAccess?

	@description('Specifies the Microsoft accounts that are supported for the current application.')
	signInAudience: resourceInput<'Microsoft.Graph/applications@beta'>.signInAudience?

	@description('Custom strings that can be used to categorize and identify the application.')
	tags: resourceInput<'Microsoft.Graph/applications@beta'>.tags?
}

/* PARAMETERS */

@description('The configuration settings.')
param settings Settings

// Do not change this value after provisioning.
@description('The unique identifier that can be assigned to an application and used as an alternate key.')
param uniqueName string

/* RESOURCES */

resource Graph_applications_ 'Microsoft.Graph/applications@beta' = {
	displayName: settings.displayName
	info: settings.info
	logo: settings.logo
	notes: settings.notes
	owners: {
		relationships: settings.?owners ?? []
		relationshipSemantics: 'replace'
	}
	passwordCredentials: settings.passwordCredentials
	requiredResourceAccess: settings.?requiredResourceAccess ?? []
	signInAudience: settings.?signInAudience ?? 'AzureADMyOrg'
	tags: settings.?tags ?? []
	uniqueName: uniqueName
}

resource Graph_servicePrincipals_ 'Microsoft.Graph/servicePrincipals@beta' = {
	appId: Graph_applications_.appId
}

/* OUTPUTS */

@description('The result.')
output result {
	appId: string
	applicationObjectId: string
	passwordCredentials: {
		hint: string
		keyId: string
		secretText: string
	}[]
	servicePrincipalObjectId: string
} = {
	appId: Graph_applications_.appId
	applicationObjectId: Graph_applications_.id
	passwordCredentials: sys.map(
		Graph_applications_.passwordCredentials,
		(
			credential
		) => {
			hint: credential.hint
			keyId: credential.keyId
			secretText: credential.secretText
		}
	)
	servicePrincipalObjectId: Graph_servicePrincipals_.id
}
