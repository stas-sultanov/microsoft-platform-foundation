metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.Network/connections resources.'

/* TYPES */

@description('The configuration of a custom IPsec policy.')
@export()
@sealed()
type IPSecPolicyInput = {
	@description('The Diffie-Hellman group for IKE key exchange.')
	dhGroup:
		| 'DHGroup24'
		| 'ECP256'
		| 'ECP384'
	@description('The IKE encryption algorithm. Pair GCMAES256 with GCMAES256 integrity.')
	ikeEncryption:
		| 'AES256'
		| 'GCMAES256'
	@description('The IKE integrity and pseudo-random function algorithm.')
	ikeIntegrity:
		| 'SHA256'
		| 'SHA384'
	@description('The IPsec encryption algorithm. Pair GCMAES256 with GCMAES256 integrity.')
	ipsecEncryption:
		| 'AES256'
		| 'GCMAES256'
	@description('The IPsec integrity algorithm.')
	ipsecIntegrity:
		| 'GCMAES256'
		| 'SHA256'
	@description('The Perfect Forward Secrecy group for IPsec key exchange.')
	pfsGroup:
		| 'ECP256'
		| 'ECP384'
		| 'PFS24'
	@description('The IPSec Security Association (also called Quick Mode or Phase 2 SA) payload size in KB for a site to site VPN tunnel.')
	saDataSizeKilobytes: int
	@description('The IPSec Security Association (also called Quick Mode or Phase 2 SA) lifetime in seconds for a site to site VPN tunnel.')
	saLifeTimeSeconds: int
}
