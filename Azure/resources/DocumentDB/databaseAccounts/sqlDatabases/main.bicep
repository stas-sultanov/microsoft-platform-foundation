metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlDatabases resource.'

/* PARAMETERS */

@description('The capacity mode for database operations.')
param capacityMode 'Autoscale' | 'Serverless' | 'Static'

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Tags to put on the resource.')
param tags resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-10-15'>.tags

@minValue(400)
@maxValue(5000)
@description('Request Units per second.')
param throughput int = 400

@minValue(4000)
@maxValue(10000)
@description('Maximal Request Units per second.')
param throughputMax int = 4000

/* VARIABLES */

var options = {
	Autoscale: {
		autoscaleSettings: {
			maxThroughput: throughputMax
		}
	}
	Serverless: {}
	Static: {
		throughput: throughput
	}
}

/* EXISTING RESOURCES */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2025-10-15' existing = {
	name: DocumentDB_databaseAccounts__name
}

/* RESOURCES */

resource DocumentDB_databaseAccounts_sqlDatabases_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-10-15' = {
	location: location
	name: name
	parent: DocumentDB_databaseAccounts_
	properties: {
		options: options[capacityMode]
		resource: {
			id: name
		}
	}
	tags: union(
		tags,
		{
			capacityMode: capacityMode
		}
	)
}
