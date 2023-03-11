---
QuickstartPath: quickstarts/microsoft.costmanagement/finops-hub
---

# FinOps hub template

![Version 0.0.1](https://img.shields.io/badge/version-0.0.1-blue) &nbsp;
![Status: In progress](https://img.shields.io/badge/status-in_progress-blue) &nbsp;<sup>→</sup>&nbsp;
[![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/1)](https://github.com/microsoft/cloud-hubs/issues/1)
This template creates a new **FinOps hub** instance.

FinOps hubs include Data Lake storage to host cloud data and a Data Factory instance for data processing and orchestration.

To use this template, you will need to create a Cost Management export that publishes cost data to the `ms-cm-exports` container in the included storage account.

> ![Version 0.0.2](https://img.shields.io/badge/version-0.0.2-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/60)](https://github.com/microsoft/cloud-hubs/issues/60)
>
> 🆕 _Remove the comment about needing to setup Cost Management exports when exports are self-managed._

On this page:

- [Parameters](#parameters)
- [Modules](#modules)
- [Outputs](#outputs)

---

## Parameters

- **hubName** (string) – Optional. Name of the hub. Used to ensure unique resource names. Default: `"finops-hub"`.
- **location** (string) – Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).
- **storageSku** (string) – Optional. Storage SKU to use. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage. Allowed: `Premium_LRS`, `Premium_ZRS`. Default: `Premium_LRS`.
- **tags** (object) – Optional. Tags to apply to all resources. We will also add the `cm-resource-parent` tag for improved cost roll-ups in Cost Management.
- **exportScopes** (array) – Optional. List of scope IDs to create exports for.
- **exportRetentionInDays** (int) – Optional. Number of days of cost data to retain in the ms-cm-exports container. Default: 0.
- **ingestionRetentionInMonths** (int) – Optional. Number of months of cost data to retain in the ingestion container. Default: 13.

<br>

## Modules

- **[hub.bicep](./modules/hub.md)** – Create the FinOps hub instance first to ensure the storage account is in place.

  - **hubName** = `param:hubName`
  - **location** = `param:location`
  - **storageSku** = `param:storageSku`
  - **tags** = `param:tags`
  - **exportScopes** = `param:exportScopes`
  - **exportRetentionInDays** = `param:exportRetentionInDays`
  - **ingestionRetentionInMonths** = `param:ingestionRetentionInMonths`

<br>

## Outputs

- **name** (string) – Name of the deployed hub instance.
- **location** (string) – Azure resource location resources were deployed to.
- **storageAccountId** (string) – Resource ID of the storage account created for the hub instance. This must be used when creating the Cost Management export.
- **storageAccountName** (string) – Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.
- **storageUrlForPowerBI** (string) – URL to use when connecting custom Power BI reports to your data.

<br>
