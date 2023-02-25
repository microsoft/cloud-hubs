/**
 * Parameters
 */

 @description('')
param storageAccountName string

param secretName string

param keyVaultName string

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).')
param location string = resourceGroup().location

@description('Optional. Enable telemetry to track anonymous module usage trends, monitor for bugs, and improve future releases.')
param enableDefaultTelemetry bool = true
// The last segment of the telemetryId is used to identify this module
var telemetryId = '00f120b5-2007-6120-0000-40b000000000'
var finOpsToolkitVersion = '0.0.1'

/**
 * Resources
 */

// Telemetry used anonymously to count the number of times the template has been deployed.
// No information about you or your cost data is collected.
resource defaultTelemetry 'Microsoft.Resources/deployments@2022-09-01' = if (enableDefaultTelemetry) {
  name: 'pid-${telemetryId}-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      metadata: {
        _generator: {
          name: 'FinOps toolkit'
          version: finOpsToolkitVersion
        }
      }
      resources: []
    }
  }
}

resource storageAccountRef 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
  scope: resourceGroup(resourceGroup().name)
}

module storageAccountSecret '../../Microsoft.KeyVault/vaults/secrets/deploy.bicep' = {
  name: secretName
  dependsOn: [
    storageAccountRef
  ]
  params: {
    name: storageAccountRef.name
    keyVaultName: keyVaultName
    value: storageAccountRef.listKeys().keys[0].value
    attributesExp: 1702648632
    attributesNbf: 10000
  }
}
