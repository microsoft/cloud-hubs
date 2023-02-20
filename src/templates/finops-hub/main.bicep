/**
 * Parameters
 */

targetScope = 'resourceGroup'

@description('Name of the hub. Used for the resource group and to guarantee globally unique resource names.')
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

@description('Name of the Data Factory.')
output dataFactorytName string = hub.outputs.dataFactorytName

@description('The resource ID of the deployed storage account.')
output storageAccountId string = hub.outputs.storageAccountId

@description('Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.')
output storageAccountName string = hub.outputs.storageAccountName

@description('Resource name of the storage account trigger.')
output storageAccountTriggerName string = hub.outputs.storageAccountTriggerName

@description('URL to use when connecting custom Power BI reports to your data.')
output storageUrlForPowerBI string = hub.outputs.storageUrlForPowerBI
