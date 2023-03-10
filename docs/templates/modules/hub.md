# hub.bicep

![Version 0.0.1](https://img.shields.io/badge/version-0.0.1-blue) &nbsp;
![Status: In progress](https://img.shields.io/badge/status-in_progress-blue) &nbsp;<sup>→</sup>&nbsp;
[![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/1)](https://github.com/microsoft/cloud-hubs/issues/1)

This module deploys a **FinOps hub** instance into a resource group.

On this page:

- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

---

## Parameters

- **hubName** (string) – Optional. Name of the hub. Used to ensure unique resource names. Default: `"finops-hub"`.
- **location** (string) – Optional. Azure location where all resources should be created. See https://aka.ms/azureregions. Default: (resource group location).
- **storageSku** (string) – Optional. Storage SKU to use. LRS = Lowest cost, ZRS = High availability. Note Standard SKUs are not available for Data Lake gen2 storage. Allowed: `Premium_LRS`, `Premium_ZRS`. Default: `Premium_LRS`.
- **tags** (object) – Optional. Tags to apply to all resources. We will also add the `cm-resource-parent` tag for improved cost roll-ups in Cost Management.
- **exportScopes** (array) – Optional. List of scope IDs to create exports for.

<br>

## Resources

- Storage account (Data Lake Storage v2) – Used for data storage.
  - **name** = `param:hubName + "store"`
  - **sku** = `param:storageSku`
  - **tags** = `param:tags`
  - containers – Create the following nested containers:
    - **config** – Used for configuration settings. Include the following files within the template:
      - [settings.json](#settingsjson)
    - **ms-cm-exports** – Used for Cost Management exports that have not been transformed.
    - **ingestion** – Used for Cost Management exports that have not been transformed.
- Data factory – Used for data ingestion and processing. Depends on: Storage account.
  - **dataFactoryName** = `param:hubName + "-engine"`

### settings.json

The **settings.json** file is used to store any configuration settings for the hub instance.

```json
{
  "$schema": "https://aka.ms/finops/toolkit/settings-schema",
  "type": "HubInstance",
  "version": "0.0.1",
  "learnMore": "https://aka.ms/finops/toolkit",
  "exportScopes": <param:exportScopes>,
  "dataRetentionInMonths": 3
}
```

> ![Version 0.0.1](https://img.shields.io/badge/version-0.0.1-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/59)](https://github.com/microsoft/cloud-hubs/issues/59)
>
> 🆕 _Add the following to the ADF instance:_
>
> - pipelines – Create the following nested pipelines:
>   - **ms-cm-exports_Transform** – Converts the CSV export to parquet and moves it to the **ingestion** container (same path), overwriting the existing contents for that month. [Learn more](../../src/modules/pipelines/README.md#ms-cm-exports_Transform).
>
> ![Version 0.0.2](https://img.shields.io/badge/version-0.0.2-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/60)](https://github.com/microsoft/cloud-hubs/issues/60)
>
> 🆕 _Add the following ADF pipelines:_
>
> - **ms-cm-exports_Setup** – Monitors the **config/settings.json** file for changes and creates, updates, or deletes exports based on changes. Also handles data backfill when needed for new scopes based on the data retention setting. Exports are created with a `FinOpsHubs_` prefix to be easily identifiable. [Learn more](../../src/modules/pipelines/README.md#ms-cm-exports_Setup).
>
> ![Version 0.0.3](https://img.shields.io/badge/version-0.0.3-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/81)](https://github.com/microsoft/cloud-hubs/issues/81)
>
> 🆕 _Update the transform pipeline description to the following:_
>
> Transforms the raw export to a normalized schema and saves it in parquet format in the **ingestion** container (same path), overwriting the existing contents for that month.

<br>

## Outputs

- **name** (string) – Name of the deployed hub instance.
- **location** (string) – Azure resource location resources were deployed to.
- **storageAccountId** (string) – Resource ID of the storage account created for the hub instance. This must be used when creating the Cost Management export.
- **storageAccountName** (string) – Name of the storage account created for the hub instance. This must be used when connecting FinOps toolkit Power BI reports to your data.
- **storageUrlForPowerBI** (string) – URL to use when connecting custom Power BI reports to your data.

<br>
