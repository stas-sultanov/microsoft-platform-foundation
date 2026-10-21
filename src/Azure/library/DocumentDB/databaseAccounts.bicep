metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provides reusable types for Microsoft.DocumentDB/databaseAccounts resources.'

/* TYPES */

@description('The request unit throughput settings.')
@export()
@sealed()
type ThroughputOptions = {
	@description('The autoscale settings.')
	@sealed()
	autoscaleSettings: {
		@description('The maximum throughput the resource can autoscale to.')
		@maxValue(10000000)
		@minValue(4000)
		maxThroughput: int
	}?
	@description('Request Units per second.')
	@maxValue(10000000)
	@minValue(400)
	throughput: int?
}
