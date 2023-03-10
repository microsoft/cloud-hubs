# Data processing

1. Cost Management exports raw cost details to the **ms-cm-exports** container.
2. Power BI reads cost data from the **ms-cm-exports** container.

> ![Version 0.0.1](https://img.shields.io/badge/version-0.0.1-lightgrey) &nbsp; ![Status: In progress](https://img.shields.io/badge/status-in_progress-blue) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/59)](https://github.com/microsoft/cloud-hubs/issues/59)
>
> 🆕 _Replace step 2 with the following:_
>
> 1. The **ms-cm-exports_Transform** pipeline saves the raw data in parquet format to the **ingestion** container.
> 2. Power BI reads cost data from the **ingestion** container.
>
> ![Version 0.0.3](https://img.shields.io/badge/version-0.0.3-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/81)](https://github.com/microsoft/cloud-hubs/issues/81)
>
> 🆕 _Add the following intro above the data processing steps:_
>
> FinOps hubs perform a number of data processing activities to clean up, normalize, and optimize data. The following diagram shows how data flows from Cost Management into a hub instance:
>
> ```mermaid
> sequenceDiagram
>     Cost Management->>ms-cm-exports: ① Export amortized costs
>     ms-cm-exports->>ingestion: ② ms-cm-exports_Transform
>     Power BI-->>ingestion: ③ Read data
> ```
>
> 🆕 _Replace step 2 with the following:_
>
> 1. The **ms-cm-exports_Transform** pipeline transforms the raw data to the normalized schema and saves it in parquet format to the **ingestion** container. For details about the transformation, see the [dev docs](../src/modules/pipelines).

<br>
