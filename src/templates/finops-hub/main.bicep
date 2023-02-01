/**
 * Parameters
 */

targetScope = 'resourceGroup'

@description('Name of the hub. Used for the resource group and to guarrantee globally unique resource names.')
param hubName string

@description('Optional. Location of the resources. Default: Same as deployment. See https://aka.ms/azureregions.')
param location string = resourceGroup().location

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
])
@description('Optional. Storage account SKU. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage.')
param storageSku string = 'Premium_LRS'

@description('Optional. Tags for all resources.')
param tags object = {}

/**
 * Resources
 */

module hub '../../modules/hub.bicep' = {
  name: 'hub'
  params: {
    hubName: hubName
    location: location
    storageSku: storageSku
    tags: tags
  }
}

/**
 * Outputs
 */

@description('The name of the resource group.')
output name string = hubName

@description('The location the resources wer deployed to.')
output location string = location

@description('The resource ID of the deployed storage account.')
output storageAccountId string = hub.outputs.storageAccountId

@description('The primary blob endpoint reference if blob services are deployed.')
output primaryBlobEndpoint string = hub.outputs.primaryBlobEndpoint
