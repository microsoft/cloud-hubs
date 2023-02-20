/**
 * Parameters
 */

@description('Optional. Name of the hub. Used to ensure unique resource names. Default: "finops-hub".')
param hubName string

// Generate unique storage account name
var storageAccountSuffix = 'store'
var storageAccountName = '${substring(replace(toLower(hubName), '-', ''), 0, 24 - length(storageAccountSuffix))}${storageAccountSuffix}'

var exportContainerName  = 'ms-cm-exports'
var dataContainerName  = 'ms-cm-data'

// Generate unique sKeyVault name
var keyVaultSuffixSuffix = 'vault'
var keyVaultName = '${substring(replace(toLower(hubName), '-', ''), 0, 24 - length(keyVaultSuffixSuffix))}${keyVaultSuffixSuffix}'

// Data factory naming requirements: Min 3, Max 63, can only contain letters, numbers and non-repeating dashes 
var dataFactorySuffix = '-engine'
var dataFactoryName = '${take(hubName, 63 - length(dataFactorySuffix))}${dataFactorySuffix}'

@description('Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).')
param location string = resourceGroup().location

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Optional. Storage account SKU. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage. Default: Premium_LRS.')
param storageSku string = 'Premium_LRS'

@description('Optional. Tags to apply to all resources. We will also add the cm-resource-parent tag for improved cost roll-ups in Cost Management.')
param tags object = {}
var resourceTags = union(tags, {
    'cm-resource-parent': '${resourceGroup().id}/providers/Microsoft.Cloud/hubs/${hubName}'
  })

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

// ADLSv2 storage account for staging and archive
module storageAccount 'Microsoft.Storage/storageAccounts/deploy.bicep' = {
  name: storageAccountName
  params: {
    name: storageAccountName
    location: location
    storageAccountSku: storageSku
    tags: resourceTags
    allowBlobPublicAccess: true
    blobServices: {
      containers: [
        {
          name: exportContainerName
          publicAccess: 'None'
        }
        {
          name: dataContainerName
          publicAccess: 'None'
        }
      ]
    }
  }
}

module dataFactory 'Microsoft.DataFactory/factories/deploy.bicep' = {
  name: dataFactoryName
  params: {
    name: dataFactoryName
    systemAssignedIdentity: true
    location: location
    tags: resourceTags
  }
}

module keyVault 'Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: keyVaultName
  params: {
    name: keyVaultName
    location: location
    tags: resourceTags
    enablePurgeProtection: false
    accessPolicies: [
      {
        objectId: dataFactory.outputs.systemAssignedPrincipalId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

module keyvayltSecret_storageAccount 'Microsoft.Custom/secrets/deploy.bicep' = {
  name: '${storageAccountName}_secret'
  params: {
    keyVaultName: keyVault.name
    secretName: storageAccountName
    storageAccountName: storageAccount.name
    location: location
  }
}

module linkedService_keyvault 'Microsoft.Custom/linkedservices/deploy.bicep' = {
  name: '${keyVault.name}_link'
  dependsOn: [
    dataFactory
    keyVault
  ]
  params: {
    linkedServiceName: keyVault.name
    dataFactoryName: dataFactory.name
    keyVaultName: keyVault.name
    linkedServiceType: 'AzureKeyVault'
  }
}

module linkedService_storage 'Microsoft.Custom/linkedservices/deploy.bicep' = {
  name: '${storageAccount.name}_link'
  dependsOn: [
    dataFactory
    keyVault
    storageAccount
    linkedService_keyvault
    keyvayltSecret_storageAccount
  ]
  params: {
    linkedServiceName: storageAccount.name
    dataFactoryName: dataFactory.name
    keyVaultName: keyVault.name
    storageAccountName: storageAccount.name
    linkedServiceType: 'AzureBlobFS'
  }
}

module dataset_mscmexport 'Microsoft.Custom/datasets/deploy.bicep' = {
  name: replace(exportContainerName, '-', '_')
  dependsOn: [
    linkedService_storage
    linkedService_keyvault
  ]
  params: {
    dataFactoryName: dataFactory.name
    datasetName: replace(exportContainerName, '-', '_')
    linkedServiceName: storageAccount.name
    datasetType: 'DelimitedText'
  }
}

module dataset_mscmdata_csv 'Microsoft.Custom/datasets/deploy.bicep' = {
  name: '${replace(dataContainerName, '-', '_')}_csv'
  dependsOn: [
    linkedService_storage
    linkedService_keyvault
  ]
  params: {
    dataFactoryName: dataFactory.name
    datasetName: '${replace(dataContainerName, '-', '_')}_csv'
    linkedServiceName: storageAccount.name
    compressionCodec: 'gzip'
    datasetType: 'DelimitedText'
  }
}

module dataset_mscmdata_parquet 'Microsoft.Custom/datasets/deploy.bicep' = {
  name: '${replace(dataContainerName, '-', '_')}_parquet'
  dependsOn: [
    linkedService_storage
    linkedService_keyvault
  ]
  params: {
    dataFactoryName: dataFactory.name
    datasetName: '${replace(dataContainerName, '-', '_')}_parquet'
    linkedServiceName: storageAccount.name
    compressionCodec: 'gzip'
    datasetType: 'Parquet'
  }
}

module pipeline_transform_parquet 'Microsoft.Custom/pipelines/transform.bicep' = {
  name: '${replace(dataContainerName, '-', '_')}_transform_parquet'
  dependsOn: [
    dataset_mscmexport
    dataset_mscmdata_parquet
  ]
  params: {
    dataFactoryName: dataFactoryName
    pipelineName: '${replace(dataContainerName, '-', '_')}_transform_parquet'
    sourceDataset: dataset_mscmexport.name
    sinkDataset: dataset_mscmdata_parquet.name
    fileExtension: '.parquet'
    containerName: dataContainerName
  }
}

module pipeline_transform_csv 'Microsoft.Custom/pipelines/transform.bicep' = {
  name: '${replace(dataContainerName, '-', '_')}_transform_csv'
  dependsOn: [
    dataset_mscmexport
    dataset_mscmdata_csv
  ]
  params: {
    dataFactoryName: dataFactoryName
    pipelineName: '${replace(dataContainerName, '-', '_')}_transform_csv'
    sourceDataset: dataset_mscmexport.name
    sinkDataset: dataset_mscmdata_csv.name
    fileExtension: '.csv.gz'
    containerName: dataContainerName
  }
}

module pipeline_extract_parquet 'Microsoft.Custom/pipelines/extract.bicep' = {
  name: '${replace(exportContainerName, '-', '_')}_extract_parquet'
  dependsOn: [
    pipeline_transform_parquet
  ]
  params: {
    dataFactoryName: dataFactoryName
    pipelineName: '${replace(exportContainerName, '-', '_')}_extract_parquet'
    pipelineToExecute: pipeline_transform_parquet.name
  }
}

module pipeline_extract_csv 'Microsoft.Custom/pipelines/extract.bicep' = {
  name: '${replace(exportContainerName, '-', '_')}_extract_csv'
  dependsOn: [
    pipeline_transform_csv
  ]
  params: {
    dataFactoryName: dataFactoryName
    pipelineName: '${replace(exportContainerName, '-', '_')}_extract_csv'
    pipelineToExecute: pipeline_transform_csv.name
  }
}

module trigger_storageAccount 'Microsoft.Custom/triggers/deploy.bicep' = {
  name: '${storageAccount.name}_trigger'
  dependsOn: [
    pipeline_extract_csv
  ]
  params: {
    BlobContainerName: exportContainerName
    PipelineName: pipeline_extract_csv.name
    dataFactoryName: dataFactory.name
    storageAccountId: storageAccount.outputs.resourceId
    triggerName: storageAccount.name
  }
}

//
//  Outputs
//

@description('Name of the deployed hub instance.')
output name string = hubName

@description('Azure resource location resources were deployed to.')
output location string = location

@description('Name of the Data Factory.')
output dataFactorytName string = dataFactory.outputs.name

@description('Resource ID of the storage account created for the hub instance. This must be used when creating the Cost Management export.')
output storageAccountId string = storageAccount.outputs.resourceId

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = storageAccount.outputs.name

@description('Resource name of the storage account trigger.')
output storageAccountTriggerName string = trigger_storageAccount.outputs.name

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = 'https://${storageAccount.outputs.name}.dfs.${environment().suffixes.storage}/${dataContainerName}'
