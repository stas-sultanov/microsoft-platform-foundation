metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers resource.'

/* SCOPE */

targetScope = 'resourceGroup'

/* IMPORTS */

import * as DocumentDBDatabaseAccounts from '../../../../../library/DocumentDB/databaseAccounts.bicep'

/* PARAMETERS */

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts resource.')
param parentDatabaseAccountName resourceInput<'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview'>.name

@description('The name of the parent Microsoft.DocumentDB/databaseAccounts/sqlDatabases resource.')
param parentSqlDatabaseName resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2026-04-01-preview'>.name

@description('The resource settings.')
@sealed()
param settings {
	@description('The name.')
	name: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.name
	@description('The configurable properties.')
	@sealed()
	properties: {
		@description('The throughput settings.')
		@validate(
			value =>
				value.?throughput == null || value.?autoscaleSettings == null,
			'throughput and autoscaleSettings cannot both be specified.'
		)
		options: DocumentDBDatabaseAccounts.ThroughputOptions?
		@sealed()
		resource: {
			@description('Analytical TTL.')
			analyticalStorageTtl: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.analyticalStorageTtl?
			@description('List of computed properties')
			computedProperties: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.computedProperties?
			@description('The conflict resolution policy for the container.')
			conflictResolutionPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.conflictResolutionPolicy?
			@description('Default time to live')
			defaultTtl: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.defaultTtl?
			@description('The FullText policy for the container.')
			fullTextPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.fullTextPolicy?
			@description('The configuration of the indexing policy. By default, the indexing is automatic for all document paths within the container')
			indexingPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.indexingPolicy?
			@description('The configuration of the partition key to be used for partitioning data into multiple partitions')
			@sealed()
			@validate(
				value =>
					value.kind != 'MultiHash'
						? sys.length(value.paths) == 1
						: sys.length(value.paths) <= 3,
				'Partition key must contain one path, or up to three paths for MultiHash.'
			)
			partitionKey: {
				@description('Indicates the kind of algorithm used for partitioning. For MultiHash, multiple partition keys (upto three maximum) are supported for container create')
				kind:
					| 'Hash'
					| 'Range'
					| 'MultiHash'
				@description('List of paths using which data within the container can be partitioned')
				@minLength(1)
				paths: string[]
				@description('Indicates the version of the partition key definition')
				@maxValue(2)
				@minValue(1)
				version: int?
			}
			@description('The unique key policy configuration for specifying uniqueness constraints on documents in the collection in the Azure Cosmos DB service.')
			uniqueKeyPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.uniqueKeyPolicy?
			@description('The vector embedding policy for the container.')
			vectorEmbeddingPolicy: resourceInput<'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview'>.properties.resource.vectorEmbeddingPolicy?
		}
	}
}

/* EXISTING RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2026-04-01-preview' existing = {
	name: parentDatabaseAccountName
	#disable-next-line use-recent-api-versions // to use new features, preview version is required
	resource sqlDatabases_ 'sqlDatabases@2026-04-01-preview' existing = {
		name: parentSqlDatabaseName
	}
}

/* RESOURCES */

#disable-next-line use-recent-api-versions // to use new features, preview version is required
resource DocumentDB_databaseAccounts_sqlDatabases_containers_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2026-04-01-preview' = {
	name: settings.name
	parent: DocumentDB_databaseAccounts_::sqlDatabases_
	properties: {
		options: settings.properties.?options
		resource: {
			analyticalStorageTtl: settings.properties.resource.?analyticalStorageTtl
			computedProperties: settings.properties.resource.?computedProperties
			conflictResolutionPolicy: settings.properties.resource.?conflictResolutionPolicy
			defaultTtl: settings.properties.resource.?defaultTtl
			fullTextPolicy: settings.properties.resource.?fullTextPolicy
			id: settings.name
			indexingPolicy: settings.properties.resource.?indexingPolicy
			partitionKey: settings.properties.resource.partitionKey
			uniqueKeyPolicy: settings.properties.resource.?uniqueKeyPolicy
			vectorEmbeddingPolicy: settings.properties.resource.?vectorEmbeddingPolicy
		}
	}
}
