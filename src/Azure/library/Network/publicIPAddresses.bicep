metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/publicIPAddresses resources.'

/* TYPES */

@description('A reference to a public IP address.')
@export()
@sealed()
type Reference = {
	@description('The ID of the Microsoft.Network/publicIPAddresses resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/publicIPAddresses/*'
			),
		'The value must be a Microsoft.Network/publicIPAddresses resource ID.'
	)
	id: string
}
