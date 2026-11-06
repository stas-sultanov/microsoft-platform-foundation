metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/applicationGateways resources.'

/* TYPES */

@description('A reference to an application gateway backend address pool.')
@export()
@sealed()
type BackendAddressPoolReference = {
	@description('The ID of the Microsoft.Network/applicationGateways/backendAddressPools resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/applicationGateways/*/backendAddressPools/*'
			),
		'The value must be a Microsoft.Network/applicationGateways/backendAddressPools resource ID.'
	)
	id: string
}
