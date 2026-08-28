metadata author = {
	fullName: 'Stas Sultanov'
	profiles: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}
metadata description = 'Provisions a Microsoft.Insights/autoscaleSettings resource.'

/* IMPORTS */

import * as InsightsDiagnosticSettings from '../../../library/Insights/diagnosticSettings.bicep'

/* TYPES */

type AutoscaleProfile = {
	@description('the number of instances that can be used during this profile.')
	capacity: {
		@description('The maximum number of instances for the resource. The actual maximum number of instances is limited by the cores that are available in the subscription.')
		maximum: int
		@description('The minimum number of instances for the resource.')
		minimum: int
	}
	@description('The name of the profile.')
	name: string
	@description('The collection of rules that provide the triggers and parameters for the scaling action. A maximum of 10 rules can be specified.')
	rules: ScaleRule[]
}

type ScaleRule = {
	metricTrigger: {
		@description('A value indicating whether metric should divide per instance.')
		dividePerInstance: bool
		@description('The name of the metric that defines what the rule monitors.')
		metricName: string
		@description('The operator that is used to compare the metric data and the threshold.')
		operator:
			| 'Equals'
			| 'GreaterThan'
			| 'GreaterThanOrEqual'
			| 'LessThan'
			| 'LessThanOrEqual'
			| 'NotEquals'
		@description('The metric statistic type. How the metrics from multiple instances are combined.')
		statistic:
			| 'Average'
			| 'Count'
			| 'Max'
			| 'Min'
			| 'Sum'
		@description('The threshold of the metric that triggers the scale action.')
		threshold: int
		@description('Time aggregation type. How the data that is collected should be combined over time.')
		timeAggregation:
			| 'Average'
			| 'Count'
			| 'Last'
			| 'Maximum'
			| 'Minimum'
			| 'Total'
		@description('The granularity of metrics the rule monitors. Must be one of the predefined values returned from metric definitions for the metric. Must be between 12 hours and 1 minute in ISO 8601 format.')
		timeGrain: string
		@description('The range of time in which instance data is collected. This value must be greater than the delay in metric collection, which can vary from resource-to-resource. Must be between 12 hours and 5 minutes in ISO 8601 format.')
		timeWindow: string
	}
	scaleAction: {
		@description('The amount of time to wait since the last scaling action before this action occurs. It must be between 1 week and 1 minute in ISO 8601 format.')
		cooldown: string
		@description('The scale direction. Whether the scaling action increases or decreases the number of instances.')
		direction:
			| 'Decrease'
			| 'Increase'
			| 'None'
		@description('The type of action that should occur when the scale rule fires.')
		type:
			| 'ChangeCount'
			| 'ExactCount'
			| 'PercentChangeCount'
			| 'ServiceAllowedNextValue'
		@description('The number of instances that are involved in the scaling action. This value must be 1 or greater. The default value is 1.')
		value: string
	}
}

/* PARAMETERS */

@description('The extensions settings.')
@sealed()
param extensions {
	Insights: {
		diagnosticSettings: InsightsDiagnosticSettings.Resource[]
	}
}

@description('The geo-location.')
param location string

@description('The name.')
param name resourceInput<'Microsoft.Insights/autoscaleSettings@2022-10-01'>.name

@description('The configurable properties.')
param properties {
	@description('The enabled flag. Specifies whether automatic scaling is enabled for the resource.')
	enabled: bool
	@description('The collection of notifications.')
	notifications: resourceInput<'Microsoft.Insights/autoscaleSettings@2022-10-01'>.properties.notifications
	@description('The predictive autoscale policy mode.')
	predictiveAutoscalePolicy: resourceInput<'Microsoft.Insights/autoscaleSettings@2022-10-01'>.properties.predictiveAutoscalePolicy
	@description('The collection of automatic scaling profiles that specify different scaling parameters for different time periods. A maximum of 20 profiles can be specified.')
	profiles: AutoscaleProfile[]
	@description('The identifier of the Virtual Machine Scale Set resource.')
	virtualMachineScaleSetId: {
		name: string
		resourceGroupName: string
		subscriptionId: string
	}
}

@description('The tags.')
param tags resourceInput<'Microsoft.Insights/autoscaleSettings@2022-10-01'>.tags

/* EXISTING RESOURCES */

resource Compute_virtualMachineScaleSets_ 'Microsoft.Compute/virtualMachineScaleSets@2026-03-01' existing = {
	name: properties.virtualMachineScaleSetId.name
	scope: resourceGroup(
		properties.virtualMachineScaleSetId.subscriptionId,
		properties.virtualMachineScaleSetId.resourceGroupName
	)
}

/* RESOURCES */

resource Insights_autoscaleSettings_ 'Microsoft.Insights/autoscaleSettings@2022-10-01' = {
	location: location
	name: name
	properties: {
		enabled: properties.enabled
		notifications: properties.notifications
		predictiveAutoscalePolicy: properties.predictiveAutoscalePolicy
		profiles: [
			for item in properties.profiles: {
				capacity: {
					default: sys.string(Compute_virtualMachineScaleSets_.sku.capacity)
					maximum: sys.string(item.capacity.maximum)
					minimum: sys.string(item.capacity.minimum)
				}
				name: item.name
				rules: sys.map(
					item.rules,
					rule => {
						metricTrigger: {
								...rule.metricTrigger
							metricNamespace: 'Microsoft.Compute/virtualMachineScaleSets'
							metricResourceUri: Compute_virtualMachineScaleSets_.id
						}
						scaleAction: rule.scaleAction
					}
				)
			}
		]
		targetResourceLocation: Compute_virtualMachineScaleSets_.location
		targetResourceUri: Compute_virtualMachineScaleSets_.id
	}
	tags: tags
}

/* EXTENSIONS */

#disable-next-line use-recent-api-versions // to use new features, preview version of resource is required
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
	for item in extensions.Insights.diagnosticSettings: {
		name: item.name
		properties: item.properties
		scope: Insights_autoscaleSettings_
	}
]
