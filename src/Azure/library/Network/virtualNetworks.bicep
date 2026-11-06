metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/virtualNetworks resources.'

/* TYPES */

@description('A reference to a subnet.')
@export()
@sealed()
type SubnetReference = {
	@description('The ID of the Microsoft.Network/virtualNetworks/subnets resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/virtualNetworks/*/subnets/*'
			),
		'The value must be a Microsoft.Network/virtualNetworks/subnets resource ID.'
	)
	id: string
}
