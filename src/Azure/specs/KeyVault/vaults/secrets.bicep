metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions multiple Microsoft.KeyVault/vaults/secrets resources.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as KeyVaultVaults from '../../../library/KeyVault/vaults.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.KeyVault/vaults resource.')
param parentName resourceInput<'Microsoft.KeyVault/vaults@2026-05-15'>.name

@description('The child secret resources.')
@secure()
@sealed()
param resources {
	secrets: KeyVaultVaults.SecretResource[]
}

/* EXISTING RESOURCES */

resource KeyVault_vaults_ 'Microsoft.KeyVault/vaults@2026-05-15' existing = {
	name: parentName
}

/* RESOURCES */

resource KeyVault_vaults_secrets_ 'Microsoft.KeyVault/vaults/secrets@2026-05-15' = [
	for item in resources.secrets: {
		name: item.name
		parent: KeyVault_vaults_
		properties: item.properties
		tags: item.?tags
	}
]
