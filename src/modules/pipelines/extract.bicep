// Source: 
// Date: 2023-02-02
// Version: 

@description('Required. The name of the parent Azure Data Factory..')
param dataFactoryName string

@description('Required. The name of the parent Azure Data Factory..')
param pipelineName string

@description('Required. The name of the parent Azure Data Factory..')
param pipelineToExecute string

resource dataFactoryRef 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' =  {
  name: pipelineName
  parent: dataFactoryRef
  properties: {
    activities: [
      {
        name: 'Execute'
        type: 'ExecutePipeline'
        dependsOn: []
        userProperties: []
        typeProperties: {
          pipeline: {
            referenceName: pipelineToExecute
            type: 'PipelineReference'
          }
          waitOnCompletion: false
          parameters: {
            folderName: {
              value: '@pipeline().parameters.folderName'
              type: 'Expression'
            }
            fileName: {
              value: '@pipeline().parameters.fileName'
              type: 'Expression'
            }
          }
        }
      }
    ]
    parameters: {
      folderName: {
        type: 'string'
      }
      fileName: {
        type: 'string'
      }
    }
    annotations: []
  }
}

@description('The name of the Resource Group the linked service was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the linked service.')
output name string = pipeline.name

@description('The resource ID of the linked service.')
output resourceId string = pipeline.id
