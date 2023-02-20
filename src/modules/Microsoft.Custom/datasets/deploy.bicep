// Source: 
// Date: 2023-02-02
// Version: 

@description('Conditional. The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.')
param dataFactoryName string

@description('Required. The name of the dataset.')
param datasetName string

@description('Required. The name of the dataset linked service.')
param linkedServiceName string

@description('Required. The type of dataset.')
param datasetType string

@description('Required. The type of dataset.')
param locationType string = 'AzureBlobFSLocation'

@description('Optional. The type of dataset.')
param compressionCodec string = 'none'

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource dataFactoryRef 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource dataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' =  {
  name: datasetName
  parent: dataFactoryRef
  properties: {
    description: 'string'
    annotations: []
    parameters: {
      fileName: {
        type: 'String'
      }
      folderName: {
        type: 'String'
      }
    }
    type: datasetType
    typeProperties: {
      columnDelimiter: ','
      compressionCodec: compressionCodec
      compressionLevel: 'Optimal'
      escapeChar: '\\'
      firstRowAsHeader: true
      quoteChar: '"'
      location: {
        type: locationType
        fileName: {
          value: '@{dataset().fileName}'
          type: 'Expression'
        }
        folderPath: {
          value: '@{dataset().folderName}'
          type: 'Expression'
        }
      }
    }
    linkedServiceName: {
      parameters: {}
      referenceName: linkedServiceName
      type: 'LinkedServiceReference'
    }
  }
}

@description('The name of the Resource Group the linked service was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the linked service.')
output name string = dataset.name

@description('The resource ID of the linked service.')
output resourceId string = dataset.id
