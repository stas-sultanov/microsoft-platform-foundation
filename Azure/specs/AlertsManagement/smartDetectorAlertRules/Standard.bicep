metadata author = {
	fullName: 'Stas Sultanov'
	profile: 'https://github.com/stas-sultanov'
}
metadata description = 'Provisions standard set of Microsoft.AlertsManagement/smartDetectorAlertRules for Application Insights components.'

/* SCOPE */

targetScope = 'resourceGroup'

/* TYPES */

@description('The configuration of a smart detector alert rule.')
@sealed()
type ResourceInput = {
	@description('The name.')
	name: string
	@description('The tags.')
	tags: resourceInput<'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01'>.tags
}

/* PARAMETERS */

@description('The detector settings.')
@sealed()
param alertRules {
	@description('The Dependency Performance Degradation detector settings.')
	dependencyPerformanceDegradation: ResourceInput
	@description('The Exception Volume Changed detector settings.')
	exceptionVolumeChanged: ResourceInput
	@description('The Failure Anomalies detector settings.')
	failureAnomalies: ResourceInput
	@description('The Memory Leak detector settings.')
	memoryLeak: ResourceInput
	@description('The Request Performance Degradation detector settings.')
	requestPerformanceDegradation: ResourceInput
	@description('The Trace Severity detector settings.')
	traceSeverity: ResourceInput
}

@description('The Microsoft.Insights/actionGroups resource id.')
param commonActionGroups resourceInput<'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01'>.properties.actionGroups

@description('The Microsoft.Insights/components resource name.')
param componentName string

/* EXISTING RESOURCES */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: componentName
}

/* RESOURCES */

@description('Failure Anomalies')
resource alertsManagement_smartDetectorAlertRules__Anomalies 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: alertRules.failureAnomalies.name
	properties: {
		actionGroups: commonActionGroups
		description: 'Detects an unusual rise in the rate in failed HTTP requests or dependency calls.'
		detector: {
			id: 'FailureAnomaliesDetector'
		}
		frequency: 'PT1M'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: alertRules.failureAnomalies.tags
}

@description('Dependency Performance Degradation')
resource alertsManagement_smartDetectorAlertRules__DependencyPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: alertRules.dependencyPerformanceDegradation.name
	properties: {
		actionGroups: commonActionGroups
		description: 'Detects an unusual increase in dependencies requests processing time.'
		detector: {
			id: 'DependencyPerformanceDegradationDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: alertRules.dependencyPerformanceDegradation.tags
}

@description('Exception Volume Changed')
resource alertsManagement_smartDetectorAlertRules__ExceptionVolumeChangedDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: alertRules.exceptionVolumeChanged.name
	properties: {
		actionGroups: commonActionGroups
		description: 'Detects an unusual increase in the rate of exceptions.'
		detector: {
			id: 'ExceptionVolumeChangedDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: alertRules.exceptionVolumeChanged.tags
}

@description('Memory Leak')
resource alertsManagement_smartDetectorAlertRules__MemoryLeakDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: alertRules.memoryLeak.name
	properties: {
		actionGroups: commonActionGroups
		description: 'Detects an unusual increase in memory consumption pattern.'
		detector: {
			id: 'MemoryLeakDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: alertRules.memoryLeak.tags
}

@description('Request Performance Degradation')
resource alertsManagement_smartDetectorAlertRules__RequestPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: alertRules.requestPerformanceDegradation.name
	properties: {
		actionGroups: commonActionGroups
		description: 'Detects an unusual increase in requests processing time.'
		detector: {
			id: 'RequestPerformanceDegradationDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: alertRules.requestPerformanceDegradation.tags
}

@description('Trace Severity')
resource alertsManagement_smartDetectorAlertRules__TraceSeverityDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: alertRules.traceSeverity.name
	properties: {
		actionGroups: commonActionGroups
		description: 'Detects an unusual increase in the severity of the traces.'
		detector: {
			id: 'TraceSeverityDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: alertRules.traceSeverity.tags
}

#disable-next-line use-recent-api-versions
resource Insights_components_ProactiveDetectionConfig__MigrationToAlertRulesCompleted 'Microsoft.Insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
	dependsOn: [
		alertsManagement_smartDetectorAlertRules__Anomalies
		alertsManagement_smartDetectorAlertRules__DependencyPerformanceDegradation
		alertsManagement_smartDetectorAlertRules__ExceptionVolumeChangedDetector
		alertsManagement_smartDetectorAlertRules__MemoryLeakDetector
		alertsManagement_smartDetectorAlertRules__RequestPerformanceDegradation
		alertsManagement_smartDetectorAlertRules__TraceSeverityDetector
	]
	name: 'migrationToAlertRulesCompleted'
	parent: Insights_components_
	properties: {
		customEmails: []
		enabled: true
		ruleDefinitions: null
		sendEmailsToSubscriptionOwners: false
	}
}
