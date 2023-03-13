# FinOps hub template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/CredScanResult.svg)
![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.costmanagement/finops-hub/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.costmanagement/finops-hub%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.costmanagement/finops-hub%2FcreateUiDefinition.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.costmanagement/finops-hub%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.costmanagement/finops-hub%2FcreateUiDefinition.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts/microsoft.costmanagement/finops-hub%2Fazuredeploy.json)

This template creates a new **FinOps hub** instance. FinOps hubs are a foundation you can build use to build your own homegrown cost management and optimization solution.

FinOps hubs include Data Lake storage to host cost data and a Data Factory instance to clean up duplicated cost data after each export is processed.

To use FinOps hubs, you can either leverage the available Power BI reports or connect directly to the included storage account. To learn more, see [aka.ms/hubs/docs](https://aka.ms/hubs/docs).

<br>

## ℹ️ Important notes

1. This template is an early prerelease. Expect updates over the coming months to evolve the platform.
2. The cost data schema used in storage and Power BI will change more than once in upcoming releases.
3. This template does not include a Cost Management export. In order to ingest cost details, a Cost Management export must be created and configured to push data to the included storage account.

<br>

`Tags: Microsoft.CostManagement/exports, Microsoft.Storage/storageAccounts, Microsoft.DataFactory/factories`
