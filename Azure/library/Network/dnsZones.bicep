metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/dnsZones resources.'

/* TYPES */

@export()
@sealed()
type ARecord = {
	@description('The name.')
	name: string
	@description('The TTL (time-to-live) of the records in the record set.')
	ttl: int
	@description('The list of A records in the record set.')
	values: string[]
}

@export()
@sealed()
type NSRecord = {
	@description('The name.')
	name: string
	@description('The TTL (time-to-live) of the records in the record set.')
	ttl: int
	@description('The list of NS records in the record set.')
	values: string[]
}
