metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/applicationSecurityGroups resources.'

/* TYPES */

@description('A reference to an application security group.')
@export()
@sealed()
type Reference = {
	@description('The ID of the Microsoft.Network/applicationSecurityGroups resource.')
	@validate(
		value =>
			sys.like(
				value,
				'/subscriptions/*/resourceGroups/*/providers/Microsoft.Network/applicationSecurityGroups/*'
			),
		'The value must be a Microsoft.Network/applicationSecurityGroups resource ID.'
	)
	id: string
}
