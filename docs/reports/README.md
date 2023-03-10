# FinOps toolkit reports

The FinOps toolkit hosts data in [Azure Data Lake Storage](https://learn.microsoft.com/azure/storage/blobs/data-lake-storage-introduction). You can use any tool to query and report on your cost data in storage. As an example, we've included the following Power BI reports to get you started. We recommend customizing them to keep what works, edit and augment reports with your own data, and remove anything that isn't needed.

> ℹ️ _The Power BI reports (PBIX files) are starter templates. Keep in mind you won't be able to upgrade a customized report as the toolkit evolves._

- [Cost summary](./cost-summary.md)
- [Commitment discounts](./commitment-discounts.md)

<br>

On this page:

- [How to setup Power BI](#how-to-setup-power-bi)
- [Queries and datasets](#queries-and-datasets)
- [Tips for customizing Power BI reports](#tips-for-customizing-power-bi-reports)

---

## How to setup Power BI

The following sections explain how to connect Power BI reports to your data depending on where you're starting from:

- [Setup a FinOps toolkit report](#setup-a-finops-toolkit-report)
- [Copy queries from a toolkit report](#copy-queries-from-a-toolkit-report)
- [Connect manually](#connect-manually)
- [Migrate from the Cost Management template app](#migrate-from-the-cost-management-template-app)
- [Migrate from the Cost Management connector](#migrate-from-the-cost-management-connector)
- [Migrate from the Consumption Insights connector](#migrate-from-the-consumption-insights-connector)

### Setup a FinOps toolkit report

The FinOps toolkit Power BI reports include pre-configured visuals, but are not connected to your data. Use the following steps to connect them to your data:

1. Download and open the desired report in Power BI Desktop.
2. Select the **Transform data** button in the toolbar.

   ![Screenshot of the Transform data button in the Power BI Desktop toolbar.](https://user-images.githubusercontent.com/399533/216573265-fa76828f-c9a2-497d-ae1e-19b55fef412c.png)

3. In the **Queries** pane on the left, update the following parameters by selecting each and updating the value as appropriate:

   - **StorageAccountName** is the name of your FinOps toolkit storage account. You can copy this from your deployment outputs.
   - **BillingProfileIdOrEnrollmentNumber** is your EA enrollment number or MCA billing profile ID. This is only included for some reports that pull data from the Cost Management Power BI connector. See [Create visuals and reports with the Azure Cost Management connector in Power BI Desktop](https://learn.microsoft.com/power-bi/connect-data/desktop-connect-azure-cost-management) for details.
   - **Scope** must be either `EnrollmentNumber` for an EA billing account or `BillingProfileId` for an MCA billing profile.

4. Select the **Close & Apply** to save your settings.

### Copy queries from a toolkit report

FinOps toolkit reports manipulate the raw export data to facilitate specific types of reports. If you need to connect your data to a new or existing Power BI report that doesn't currently use FinOps hub or Cost Management data source, the best option is to copy queries, columns, and measures from a FinOps toolkit report.

1. Download one of the FinOps toolkit reports.
2. Open the report in Power BI Desktop.
3. Select **Transform data** in the toolbar.
4. In the Queries list on the left, right-click **CMExports** and select **Copy**.
5. Open your report in Power BI Desktop.
6. Select **Transform data** in the toolbar.
7. Right-click the empty space in the bottom of the **Queries** pane and select **New group...**.
8. Set the name to `FinOps toolkit` and select **OK**.
9. Right-click the **FinOps toolkit** folder and select **Paste**.
10. Select **Close & Apply** in the toolbar for both reports.

At this point, you have the core data from the FinOps toolkit reports, extended to support Azure Hybrid Benefit reports. In addition to these, you may also be interested in the custom columns and measures that summarize savings, utilization, cost over time, and more. Unfortunately, Power BI doesn't provide a simple way to copy columns and measures. Perform the following for each column and measure you'd like to copy:

1. In the FinOps toolkit report, expand the **CMExports** table in the **Data** pane on the right.
2. Select a custom column or measure, then copy the formula from the editor at the top of the window, under the toolbar.
   > ℹ️ _Be sure to make note if this is a column or a measure. Columns have a table icon with a sigma or "fx" symbol and measures have a calculator icon._ > ![Screenshot of the calculated column and measure icons in Power BI](https://user-images.githubusercontent.com/399533/216805396-96abae2d-473a-4136-8943-cac4ddd74dce.png)
3. In your report, right click the **CMExports** table and select **New measure** or **New column** based on what you just copied.
4. When the formula editor is shown, paste the formula using <kbd>Ctrl+V</kbd> or <kbd>Cmd+V</kbd>.
5. Repeat steps 2-4 for each desired column and measure.

Note that some columns and measures depend on one another. You can ignore these errors as you copy each formula. Each will resolve itself when the dependent column or measure is added.

For details about the columns available in Power BI, refer to the [data dictionary](../data-dictionary.md).

### Connect manually

If you don't need any of the custom columns and measures provided by the FinOps toolkit reports, you can also connect directly to your data using the Azure Data Lake Storage Gen2 connector:

1. Open your desired report in Power BI Desktop.
2. Select **Get data** in the toolbar.
3. Search for `lake` and select **Azure Data Lake Storage Gen2**
4. Set the URL to `https://<storage-name>.dfs.core.windows.net/ms-cm-exports` and select the **OK** button.

   - You can copy this value from the deployment outputs.

   > ℹ️ _If you receive an "Access to the resource is forbidden" error, grant the account loading data in Power BI the [Storage Blob Data Reader role](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-reader)._

5. Select the **Combine** button.
6. Select the **OK** button.

For more details about connecting to Azure Data Lake Storage Gen2, see [Connect to ADLS Gen2](https://learn.microsoft.com/power-query/connectors/data-lake-storage#connect-to-azure-data-lake-storage-gen2-from-power-query-desktop). For details about the columns available in storage, refer to the [data dictionary](../data-dictionary.md).

### Migrate from the Cost Management template app

The Cost Management template app does not support customization in Power BI Desktop. We recommend [starting from a FinOps toolkit report](#setup-a-finops-toolkit-report).

### Migrate from the Cost Management connector

If using the Cost Management connector, you can copy queries from a FinOps toolkit report without breaking your report.

1. Download one of the FinOps toolkit reports.
2. Open the report in Power BI Desktop.
3. Select **Transform data** in the toolbar.
4. In the Queries list on the left, right-click **CMConnector** and select **Copy**.
5. Before you change your report, make a copy first to ensure you can rollback if needed.
6. Open your report in Power BI Desktop.
7. Select **Transform data** in the toolbar.
8. Right-click the empty space in the bottom of the **Queries** pane and select **New group...**.
9. Set the name to `FinOps toolkit` and select **OK**.
10. Right-click the **FinOps toolkit** folder and select **Paste**.
11. Right-click the **CMConnector** query and select **Advanced Editor**.
12. Copy all text and close the editor dialog.
13. Right-click the **Usage details** query and select **Advanced Editor**.
14. Replace all text with the copied text from CMConnector and select the **Done** button.
15. Select **Close & Apply** in the toolbar for both reports.

If interested in custom columns and measures, see [Copy queries from a toolkit report](#copy-queries-from-a-toolkit-report) for required steps.

This approach ensures your existing reports can switch to your FinOps hub data without breaking the visuals you already have configured, however this is only intended as a short-term migration helper. We recommend switching all visuals to the latest dataset. See [Queries and datasets](#queries-and-datasets) below for additional details.

### Migrate from the Consumption Insights connector

The Consumption Insights connector is not currently supported. If you'd like to see support added, please [submit a feature request](https://github.com/microsoft/cloud-hubs/issues/new/choose).

<br>

## Queries and datasets

FinOps toolkit offers multiple versions of cost details to align to different schemas for backwards compatibility. These schemas are only provided to assist in migrating from older versions. We recommend updating visuals to use CostDetails or the newest underlying dataset. If you do not need legacy datasets, you can remove them from the Power Query Editor (Transform data) window.

> ℹ️ _FinOps toolkit will eventually adopt the [FOCUS standard](https://aka.ms/finops/focus) when available._

### CostDetails

The **CostDetails** dataset is a reference to the latest version of the schema. All visuals in FinOps toolkit reports are connected to this latest version. If you do not want to point to the latest version, you can edit the CostDetails query in the Power Query editor and change it to reference a different schema version.

### CMExports

The CMExports dataset uses the raw column names from Cost Management exports. This mostly aligns to the CMConnector schema, but with a few small differences. See [CMConnector](#cmconnector) for details.

This dataset is hidden from the list of tables. To see it, right-click any table and select **Unhide all**.

### CMConnector

The CMConnector dataset uses the original schema from the "Azure Cost Management" Power BI connector. This dataset is only provided for backwards compatibility.

Internally, the CMConnector dataset starts with CMExports data and reverses the schema changes:

- **BillingCurrencyCode** renamed to **BillingCurrency**.
- **CostInBilling** renamed to **Cost**.
- **InvoiceSectionName** renamed to **InvoiceSection**.
- **IsAzureCreditEligible** renamed to **IsCreditEligible** and changed from a boolean to a string (`True` or `False`).
- **ProductName** renamed to **Product**.

Note the following columns are new in this release. These columns were not previously present in the Cost Management connector:

- **CostAllocationRuleName**
- **benefitId**
- **benefitName**
- **Month**
- **CPUHours**
- **CommitmentNameUnique**
- **ResourceNameUnique**
- **ResourceGroupNameUnique**
- **SubscriptionNameUnique**
- **CommitmentType**
- **CommitmentUtilizationAmount**
- **CommitmentUtilizationPotential**
- **RetailPrice**
- **RetailCost**
- **OnDemandCost**
- **CommitmentSavings**
- **DiscountSavings**
- **NegotiatedSavings**

<br>

## Tips for customizing Power BI reports

FinOps toolkit Power BI reports are starter templates that we encourage you to customize. Changing visuals, columns, and measures should not break in future releases outside of potential schema changes, which are usually easy to fix by changing column names. The main issue to be careful of is changing the out-of-the-box queries. Out-of-the-box queries can change in future releases, which will make it harder for you to upgrade. If you need to modify a query, we recommend confining updates to the **CostDetails** dataset, which references the internal datasets we use for schema versioning. We will keep our updates to those internal datasets to avoid conflicting with your customizations.

If you run into any issues, please let us know in [Discussions](https://github.com/microsoft/cloud-hubs/discussions).
