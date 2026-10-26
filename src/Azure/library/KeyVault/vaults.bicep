metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.KeyVault/vaults resources.'

/* TYPES */

@description('The configuration of a Microsoft.KeyVault/vaults/keys resource.')
@export()
@sealed()
type KeyResource = {
	@description('The name.')
	name: resourceInput<'Microsoft.KeyVault/vaults/keys@2026-05-15'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.KeyVault/vaults/keys@2026-05-15'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.KeyVault/vaults/keys@2026-05-15'>.tags?
}

@description('The configuration of a Microsoft.KeyVault/vaults/secrets resource.')
@export()
@sealed()
type SecretResource = {
	@description('The name.')
	name: resourceInput<'Microsoft.KeyVault/vaults/secrets@2026-05-15'>.name
	@description('The properties.')
	properties: resourceInput<'Microsoft.KeyVault/vaults/secrets@2026-05-15'>.properties
	@description('The tags.')
	tags: resourceInput<'Microsoft.KeyVault/vaults/secrets@2026-05-15'>.tags?
}
