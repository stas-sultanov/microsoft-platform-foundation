metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/networkInterfaces resources.'

/* TYPES */

@description('A reference to a network interface.')
@export()
@sealed()
type Reference = {
	@description('The ID of the Microsoft.Network/networkInterfaces resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/networkInterfaces/*'
			),
		'The value must be a Microsoft.Network/networkInterfaces resource ID.'
	)
	id: string
}
