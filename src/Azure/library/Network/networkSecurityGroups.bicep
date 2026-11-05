metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/networkSecurityGroups resources.'

/* TYPES */

@description('A reference to a network security group.')
@export()
@sealed()
type Reference = {
	@description('The ID of the Microsoft.Network/networkSecurityGroups resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/networkSecurityGroups/*'
			),
		'The value must be a Microsoft.Network/networkSecurityGroups resource ID.'
	)
	id: string
}
