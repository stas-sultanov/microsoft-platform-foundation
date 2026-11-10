metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides common reusable types across Bicep modules.'

/* TYPES */

@description('A resource reference by ID.')
@export()
@sealed()
type ReferenceById = {
	@description('The resource ID.')
	id: string
}

@description('A resource reference within the current deployment scope.')
@export()
@sealed()
type ReferenceByName = {
	@description('The resource name.')
	name: string
}

@description('A resource reference with explicit scope information.')
@export()
@sealed()
type ReferenceByNameAndScope = {
	@description('The resource name.')
	name: string
	@description('The resource scope.')
	scope: ResourceGroupScope
}

@description('A resource group scope reference.')
@export()
@sealed()
type ResourceGroupScope = {
	@description('The resource group name.')
	resourceGroupName: string
	@description('The subscription id.')
	subscriptionId: string?
}

@description('Tags to be applied to the resource.')
@export()
type Tags = {
	@description('A tag to be applied to the resource.')
	*: string
}
