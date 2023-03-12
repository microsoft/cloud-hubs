// Source: 
// Date: 2023-02-27
// Version: 

 @description('The KeyVault to store the secret in.')
param keyVaultName string

@description('The name of the storage account to create the secret for.')
param storageAccountName string

@description('The name of the secret to be created')
param secretName string

resource storageAccountRef 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
  scope: resourceGroup(resourceGroup().name)
}

module storageAccountSecret '../Microsoft.KeyVault/vaults/secrets/deploy.bicep' = {
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
