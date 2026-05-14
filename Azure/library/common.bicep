metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provides common reusable types across Bicep modules.'

/* TYPES */

@description('A resource reference within the current deployment scope.')
@export()
@sealed()
type ResourceReference = {
	@description('The resource name.')
	name: string
}

@description('A resource group scope reference.')
@export()
@sealed()
type ResourceScope = {
	@description('The resource group name.')
	resourceGroupName: string
	@description('The subscription ID.')
	subscriptionId: string?
}

@description('A resource reference with explicit scope information.')
@export()
@sealed()
type ScopedResourceReference = {
	@description('The resource name.')
	name: string
	@description('The resource scope.')
	scope: ResourceScope
}

@description('Tags to be applied to the resource.')
@export()
type Tags = {
	*: string
}
