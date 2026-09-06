metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.OperationalInsights/workspaces/tables resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('The name of the parent Microsoft.OperationalInsights/workspaces resource.')
param parentName resourceInput<'Microsoft.OperationalInsights/workspaces@2025-07-01'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The table name. Must end with "_CL" to denote a custom log table.')
	@maxLength(63)
	@minLength(4)
	name: resourceInput<'Microsoft.OperationalInsights/workspaces/tables@2025-07-01'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.OperationalInsights/workspaces/tables@2025-07-01'>.properties
}

/* EXISTING RESOURCES */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
	name: parentName
}

/* RESOURCES */

resource OperationalInsights_workspaces_tables_ 'Microsoft.OperationalInsights/workspaces/tables@2025-07-01' = {
	name: settings.name
	parent: OperationalInsights_workspaces_
	properties: settings.properties
}

/* OUTPUTS */

@description('The name.')
output name string = OperationalInsights_workspaces_tables_.name
