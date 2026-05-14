metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions a Microsoft.AppConfiguration/configurationStores/keyValues resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The key-value name.')
param name string

@description('The name of the parent resource of Microsoft.AppConfiguration/configurationStores type.')
param parentName string

@description('The properties.')
param properties resourceInput<'Microsoft.AppConfiguration/configurationStores/keyValues@2024-06-01'>.properties = {}

/* EXISTING RESOURCES */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
	name: parentName
}

/* RESOURCES */

resource AppConfiguration_configurationStores_keyValues_ 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-06-01' = {
	name: name
	parent: AppConfiguration_configurationStores_
	properties: properties
}

/* OUTPUTS */

@description('The name.')
output name string = AppConfiguration_configurationStores_keyValues_.name
