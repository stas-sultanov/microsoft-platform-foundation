metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DataFactory/factories/linkedservices resource.'

/* PARAMETERS */

@description('The resource settings.')
@sealed()
param settings {
	@description('Name of the credential to use for authentication and authorization.')
	credentialName: string
	@description('Name of the DataFactory/factories resource.')
	DataFactory_factories__name: string
	@description('Name of the resource.')
	name: resourceInput<'Microsoft.DataFactory/factories/linkedservices@2018-06-01'>.name
	@description('The id of the Storage/storageAccounts resource.')
	Storage_storageAccounts__id: string
}

/* VARIABLES */

var storage_storageAccounts__Id_split = split(
	settings.Storage_storageAccounts__id,
	'/'
)

/* EXISTING RESOURCES */

resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' existing = {
	name: settings.DataFactory_factories__name
}

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2026-04-01' existing = {
	name: storage_storageAccounts__Id_split[8]
	scope: resourceGroup(
		storage_storageAccounts__Id_split[2],
		storage_storageAccounts__Id_split[4]
	)
}

/* RESOURCES */

resource DataFactory_factories_linkedService_ 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
	name: settings.name
	parent: DataFactory_factories_
	properties: {
		type: 'AzureBlobStorage'
		typeProperties: {
			accountKind: Storage_storageAccounts_.kind
			credential: {
				referenceName: settings.credentialName
				type: 'CredentialReference'
			}
			serviceEndpoint: Storage_storageAccounts_.properties.primaryEndpoints.blob
		}
	}
}
