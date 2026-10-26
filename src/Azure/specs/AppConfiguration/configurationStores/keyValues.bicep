metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions multiple Microsoft.AppConfiguration/configurationStores/keyValues resources.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AppConfigurationConfigurationStores from '../../../library/AppConfiguration/configurationStores.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.AppConfiguration/configurationStores resource.')
param parentName resourceInput<'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview'>.name

@description('The child resources.')
@sealed()
param resources {
	keyValues: AppConfigurationConfigurationStores.KeyValueResource[]
}

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2025-08-01-preview' existing = {
	name: parentName
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource AppConfiguration_configurationStores_keyValues_ 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-08-01-preview' = [
	for item in resources.keyValues: {
		name: item.name
		parent: AppConfiguration_configurationStores_
		properties: item.properties
	}
]
