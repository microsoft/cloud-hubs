// Source: 
// Date: 2023-02-02
// Version: 

@description('Conditional. The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.')
param dataFactoryName string

@description('The name of the service to link to.')
param linkedServiceName string

@allowed([
  'AzureBlobFS'
  'AzureKeyVault'
])
@description('Required. The type of Linked Service.')
param linkedServiceType string

@description('The name of the service to link to.')
param storageAccountName string

@description('The name of the service to link to.')
param keyVaultName string

resource dataFactoryRef 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource linkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: linkedServiceName
  parent: dataFactoryRef
  properties: {
    description: 'string'
    annotations: []
    parameters: {}
    type: linkedServiceType
    typeProperties: linkedServiceType == 'AzureKeyVault' ? {
        baseurl: reference('Microsoft.KeyVault/vaults/${keyVaultName}', '2022-11-01').vaultUri
      } : linkedServiceType == 'AzureBlobFS' ? {
        url: reference('Microsoft.Storage/storageAccounts/${storageAccountName}', '2019-04-01').primaryEndpoints.dfs
        accountKey: {
          type: 'AzureKeyVaultSecret'
          store: {
            referenceName: keyVaultName
            type: 'LinkedServiceReference'
          }
          secretName: storageAccountName
        }
      } : {}
    
  }
}

@description('The name of the Resource Group the linked service was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the linked service.')
output name string = linkedService.name

@description('The resource ID of the linked service.')
output resourceId string = linkedService.id
