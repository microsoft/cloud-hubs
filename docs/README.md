# FinOps toolkit documentation

![Version: 0.0.1](https://img.shields.io/badge/version-0.0.1-blue) &nbsp; ![Status: In progress](https://img.shields.io/badge/status-in_progress-blue)

The **FinOps toolkit** seeks to provide a collection of customizable ARM templates that can be used to build homegrown cost management and optimization solutions. The project is in an early prerelease stage which establishes the foundation for what we call a **FinOps hub** – a reliable, trustworthy platform for cost analytics, insights, and optimization.

<!--
FinOps hubs aspire to be **virtual command centers** for leaders throughout the organization to report on, monitor, and optimize cost based on their organizational needs.

FinOps hubs are:

- Based on open standards.
- Built to scale for the largest organizations.
- Designed to support full extensibility.
-->

<br>

On this page:

- [Summary](#summary)
- [Create a new hub](#create-a-new-hub)
- [Get started with hubs](#get-started-with-hubs)
- [Roadmap](#roadmap)
- [Get involved](#get-involved)
- [Changelog](#changelog)

---

## Summary

The FinOps toolkit deploys a hub instance ([template](templates/finops-hub.md)), which includes the following resources:

- Storage account (Data Lake Storage Gen2) to hold all cost data.
- Data factory to manage data ingestion and cleanup.

Once deployed, you can create new exports in Cost Management and use out of the box Power BI reports to customize and share reports with your stakeholders.

<img alt="Screenshot of the cost summary report" style="max-width:200px" src="https://user-images.githubusercontent.com/399533/216882658-45f026f1-c895-48ca-81e2-35765af8e29e.png">
<img alt="Screenshot of the services cost report" style="max-width:200px" src="https://user-images.githubusercontent.com/399533/216882700-4e04b589-0580-4e49-9b40-9f5948792975.png">
<img alt="Screenshot of the commitment-based discounts coverage report" style="max-width:200px" src="https://user-images.githubusercontent.com/399533/216882916-bb7ecfa3-d092-4ae2-88e1-7a0425c14dca.png">

<br>

## Create a new hub

1. [Deploy the **finops-hub** template](./deploy).
2. [Create a new cost export](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal) using the following settings:
   - **Metric** = `Amortized cost`
   - **Export type** = `Daily export of month-to-date costs`
     > 💡 _**Tip:** Configuring a daily export starts in the current month. If you want to backfill historical data, create a one-time export and set the start/end dates to the desired date range._
   - **Storage account** = (Use subscription/resource from step 1)
   - **Container** = `ms-cm-exports`
   - **Directory** = (Use the resource ID of the scope you're exporting, but remove the first "/")
     > ℹ️ _You are welcome to use any directory name you want. Using the scope ID is how we plan to do it in order to avoid collisions. You will see this added in a future release._
3. Run your export.
   - Exports can take up to a day to show up after first created.
   - Use the **Run now** command at the top of the Cost Management Exports page.
   - Your data should be available within 15 minutes or so, depending on how big your account is.
4. Download one or more of the available Power BI starter templates:
   - [Cost summary](./reports/cost-summary.md) for standard cost roll-ups.
   - [Commitment discounts](./reports/commitment-discounts.md) for commitment-based savings utilization and coverage.
5. [Connect Power BI to your hub](./reports/README.md#setup-a-finops-toolkit-report)

> ![Version 0.0.2](https://img.shields.io/badge/version-0.0.2-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/60)](https://github.com/microsoft/cloud-hubs/issues/60)
>
> 🆕 _Remove steps 2 and 3 when we have self-managed exports._

<br>

## Get started with hubs

After deploying a hub instance, there are several ways for you to get started:

1. Customize the built-in Power BI reports.

   Our Power BI reports are starter templates and intended to be customized. We encourage you to customize as needed. [Learn more](./reports).

2. Create your own Power BI reports.

   If you'd like to create your own reports or add cost data to an existing report, you can either [copy queries from a toolkit report](./reports/README.md#setup-a-finops-toolkit-report) or [connect manually](./reports/README.md#connect-manually) using the Azure Data Lake Storage Gen2 connector.

   <!-- NOTE TO CONTRIBUTORS: Keep this info note in sync with the same one under #3 below. -->

   > ℹ️ _The schema may change multiple times before the 0.1 release. We will ensure Power BI reports have backwards compatibility, but if you access data directly, you may run into breaking changes with new releases. Familiarize yourself with [upcoming releases](https://aka.ms/finops/toolkit/roadmap) and review the [changelog](changelog.md) for breaking changes before you update._

3. Access the cost data from custom tools.

   Cost data is stored in an [Azure Data Lake Storage Gen2](https://learn.microsoft.com/azure/storage/blobs/data-lake-storage-introduction) account. You can use any tool that supports Azure Data Lake Storage Gen2 to access the data. Refer to the [data dictionary](./data-dictionary.md) for details about available columns.

   <!-- NOTE TO CONTRIBUTORS: Keep this info note in sync with the same one under #2 above. -->

   > ℹ️ _The schema may change multiple times before the 0.1 release. We will ensure Power BI reports have backwards compatibility, but if you access data directly, you may run into breaking changes with new releases. Familiarize yourself with [upcoming releases](https://aka.ms/finops/toolkit/roadmap) and review the [changelog](changelog.md) for breaking changes before you update._

4. Apply cost allocation logic, augment, or manipulate your cost data using Data Factory.

   [Data Factory](https://learn.microsoft.com/azure/data-factory/introduction) is used to ingest and transform data. We recommend using Data Factory as a cost-efficient solution to apply custom logic to your cost data. Use a consistent prefix for custom pipelines to ensure they don't overlap with new pipelines. Refer to [data processing](./data-processing.md) for details about how data is processed.

   > ⚠️ _Keep in mind this is the primary area we are planning to evolve in [upcoming FinOps toolkit releases](https://aka.ms/finops/toolkit/roadmap). Please familiarize yourself with our roadmap to avoid conflicts with future updates. Consider [contributing to the project](../CONTRIBUTING.md) to add support for new scenarios to avoid conflicts._
   >
   > ![Version 0.0.1](https://img.shields.io/badge/version-0.0.1-lightgrey) &nbsp; ![Status: In progress](https://img.shields.io/badge/status-in_progress-blue) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/59)](https://github.com/microsoft/cloud-hubs/issues/59)
   >
   > 🆕 _Add the following sentences to the description (before "Use a consistent prefix"):_
   >
   > Do not modify built-in pipelines or data in the **ms-cm-exports** container. Create a custom pipeline that monitors new data in the **ingestion** container.

5. Generate custom alerts using Power Automate.

   You have many options for generating custom alerts. [Power Automate](https://powerautomate.microsoft.com/connectors/details/shared_azureblob/azure-blob-storage) is a great option for people who are new to automation but you can also use [Data Factory](https://learn.microsoft.com/azure/data-factory/introduction), [Functions](https://learn.microsoft.com/azure/azure-functions/functions-overview), or any other service that supports custom code or direct access to data in Azure Data Lake Storage Gen2.

No matter what you choose to do, we recommend creating a new bicep module to support updating your solution. You can reference `finops-hub/main.bicep` or `hub.bicep` directly to ensure you can apply new updates as they're released.

If you need to change `hub.bicep`, be sure to track those changes and re-apply them when upgrading to the latest release. We generally don't recommend modifying the template or modules directly to avoid conflicts with future updates. Instead, consider contributing those changes back to the open source project. [Learn more](../CONTRIBUTING.md).

> ![Version 0.0.2](https://img.shields.io/badge/version-0.0.2-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/60)](https://github.com/microsoft/cloud-hubs/issues/60)
>
> 🆕 _Change the notes for storage to: Data is ingested into the `ms-cm-exports` container and transformed when moved into the `ingestion` container. Do not store use the `ms-cm-exports` container for anything other than Cost Management exports. If manipulating data, please do that in the `ingestion` container after the transform pipeline completes. Don't remove or rename columns, as that can break Power BI reports._

If you access data in storage or are creating or customizing Power BI reports, please refer to the [data dictionary](data-dictionary.md) for details about the available columns.

<br>

## Roadmap

We track the short-term roadmap for FinOps toolkit as [releases](https://github.com/microsoft/cloud-hubs/labels/Type%3A%20Release%20%F0%9F%9A%80). Each release includes overarching goals, tasks broken down into sub-releases, links to discussions for each sub-release, and tentative stretch tasks.

Please use discussions if you have questions, comments, or requests for any specific release. This will ensure everything gets triaged and not lost.

<br>

## Get involved

FinOps toolkit is an open source project. We have many ideas on the long-term vision, but are more interested in learning from you and seeing how the community drives the product. There are many ways you can contribute to the project from participating in discussions and requesting features to reviewing and submitting pull requests. To get started, refer to our [Contribution guide](../CONTRIBUTING.md).

<br>

## Changelog

All the main changes are tracked within the [Changelog](./changelog.md). For additional details, refer to the [commit history](https://github.com/microsoft/cloud-hubs/commits/main).
