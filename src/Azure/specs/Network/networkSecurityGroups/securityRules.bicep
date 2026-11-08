metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions multiple Microsoft.Network/networkSecurityGroups/securityRules resources for a network security group.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as NetworkNetworkSecurityGroups from '../../../library/Network/networkSecurityGroups.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.Network/networkSecurityGroups resource.')
param parentName resourceInput<'Microsoft.Network/networkSecurityGroups@2026-03-01'>.name

@description('The child resources.')
@sealed()
param resources {
	securityRules: NetworkNetworkSecurityGroups.SecurityRuleResource[]
}

/* EXISTING RESOURCES */

resource Network_networkSecurityGroups_ 'Microsoft.Network/networkSecurityGroups@2026-03-01' existing = {
	name: parentName
}

/* RESOURCES */

// Competing writes to the same network security group can fail with AnotherOperationInProgress, so the rules are deployed one at a time.
@batchSize(1)
resource Network_networkSecurityGroups_securityRules_ 'Microsoft.Network/networkSecurityGroups/securityRules@2026-03-01' = [
	for item in resources.securityRules: {
		name: item.name
		parent: Network_networkSecurityGroups_
		properties: item.properties
	}
]
