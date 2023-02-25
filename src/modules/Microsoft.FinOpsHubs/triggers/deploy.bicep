// Source: 
// Date: 2023-02-02
// Version: 

@description('Conditional. The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.')
param dataFactoryName string

@description('Required. The name of the dataset.')
param PipelineName string

@description('Required. The name of the dataset.')
param storageAccountId string

@description('Required. The name of the dataset.')
param BlobContainerName string

@description('Required. The name of the dataset.')
param triggerName string

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

resource trigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' =  {
  name: triggerName
  parent: dataFactoryRef
  properties: {
    annotations: []
    pipelines: [
      {
        pipelineReference: {
          referenceName: PipelineName
          type: 'PipelineReference'
        }
        parameters: {
          folderName: '@triggerBody().folderPath'
          fileName: '@triggerBody().fileName'
        }
      }
    ]
    type: 'BlobEventsTrigger'
    typeProperties: {
      blobPathBeginsWith: '/${BlobContainerName}/blobs/'
      blobPathEndsWith: '.csv'
      ignoreEmptyBlobs: true
      scope: storageAccountId
      events: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
  }

}

@description('The name of the Resource Group the linked service was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the linked service.')
output name string = trigger.name

@description('The resource ID of the linked service.')
output resourceId string = trigger.id
