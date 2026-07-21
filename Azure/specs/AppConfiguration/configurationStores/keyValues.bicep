metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.AppConfiguration/configurationStores/keyValues resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as AppConfigurationConfigurationStores from '../../../../library/AppConfiguration/configurationStores.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.AppConfiguration/configurationStores resource.')
param parentName string

@description('The child resources.')
param resources AppConfigurationConfigurationStores.KeyValueChildResource[]

/* EXISTING RESOURCES */

// to use new features, preview version of resource is required

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
	name: parentName
}

/* RESOURCES */

// to use new features, preview version of resource is required
resource AppConfiguration_configurationStores_keyValues_ 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-06-01' = [
	for resource in resources: {
		name: resource.name
		parent: AppConfiguration_configurationStores_
		properties: resource.properties
	}
]
