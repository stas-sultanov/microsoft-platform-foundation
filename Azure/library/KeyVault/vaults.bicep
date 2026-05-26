metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provides reusable types for Microsoft.KeyVault/vaults resources.'

/* TYPES */

@description('VaultProperties input configuration.')
@export()
@sealed()
type PropertiesInput = {
	@description('Specifies whether protection against purge is enabled for this vault.')
	enablePurgeProtection: bool
	@description('Specifies whether the \'soft delete\' functionality is enabled for this key vault.')
	enableSoftDelete: bool
	@description('Rules governing the accessibility of the key vault from specific network locations.')
	networkAcls: resourceInput<'Microsoft.KeyVault/vaults@2021-10-01'>.properties.networkAcls?
	@description('Specifies whether the vault accepts traffic from the public internet.')
	publicNetworkAccess:
		| 'Enabled'
		| 'Disabled'
	@description('The \'soft delete\' data retention days.')
	@maxValue(90)
	@minValue(7)
	softDeleteRetentionInDays: int?
}
