# FinOps hub pipelines

On this page:

- [ms-cm-exports_Setup](#ms-cm-exports_setup)
- [ms-cm-exports_Transform](#ms-cm-exports_transform)

---

## ms-cm-exports_Setup

> ![Version 0.0.2](https://img.shields.io/badge/version-0.0.2-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/60)](https://github.com/microsoft/cloud-hubs/issues/60)
>
> 🆕 _This pipeline is new in v0.0.2_

**Trigger**: Changes to the **config/settings.json** file.

- Create new exports when scopes are added to `exportScopes` using the following settings:
  - **name** = `"FinOpsHubs_" + hubName + "_" + subscriptionId`
  - **amortize** = `true`
  - **storageAccountId** = (use the `storageAccountId` output from hub.bicep)
  - **storageAccountContainer** = `ms-cm-exports`
  - **storageAccountPath** = (scope ID from `exportScopes` without the first "/")
- Back-fills data based on the data retention setting when scopes are added to `exportScopes`.
- Deletes exports when scopes are removed from `exportScopes`.

<br>

## ms-cm-exports_Transform

> ![Version 0.0.1](https://img.shields.io/badge/version-0.0.1-lightgrey) &nbsp; ![Status: In progress](https://img.shields.io/badge/status-in_progress-blue) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/59)](https://github.com/microsoft/cloud-hubs/issues/59)
>
> 🆕 _This pipeline is new in v0.0.1_

**Trigger**: New files added to the **ms-cm-exports** container.

**Steps**:

- Overwrite data in the **ingestion** container for the specified month.
- If the data retention policy for the **ms-cm-exports** container is set to 0, delete export CSV files from **ms-cm-exports**.

> ![Version 0.0.3](https://img.shields.io/badge/version-0.0.3-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/81)](https://github.com/microsoft/cloud-hubs/issues/81)
>
> 🆕 _Add the following step:_
>
> - Transform raw cost data exported from Cost Management to a [normalized schema](#normalized-schema).

### Normalized schema

> ![Version 0.0.3](https://img.shields.io/badge/version-0.0.3-lightgrey) &nbsp; ![Status: Proposed](https://img.shields.io/badge/status-proposed-lightgrey) &nbsp;<sup>→</sup>&nbsp; [![Go to issue](https://img.shields.io/github/issues/detail/state/microsoft/cloud-hubs/81)](https://github.com/microsoft/cloud-hubs/issues/81)
>
> 🆕 _This section is new in v0.0.3_

The following table includes all the columns that should be available in the normalized schema. The **Value** indicates what the value should be if it's not a pass-through value from raw cost details.

> ⚠️ _This schema is a temporary normalized schema that attempts to align to the latest version of the Cost Management connector in Power BI. The schema will be updated in a future release when the official FinOps Open Cost & Usage Specification (FOCUS) schema is finalized._

For details about the columns supported by Cost Management, see [Understand cost details fields](https://learn.microsoft.com/azure/cost-management-billing/automate/understand-usage-details-fields).

<!--
MOSA (Sep 2022):
    SubscriptionGuid, ResourceGroup, ResourceLocation, UsageDateTime, MeterCategory, MeterSubcategory, MeterId, MeterName, MeterRegion, UsageQuantity, ResourceRate, PreTaxCost, ConsumedService, ResourceType, InstanceId, Tags, OfferId, AdditionalInfo, ServiceInfo1, ServiceInfo2, ServiceName, ServiceTier, Currency, UnitOfMeasure
EA (Aug 2022):
    InvoiceSectionName, AccountName, AccountOwnerId, SubscriptionId, SubscriptionName, ResourceGroup, ResourceLocation, Date, ProductName, MeterCategory, MeterSubCategory, MeterId, MeterName, MeterRegion, UnitOfMeasure, Quantity, EffectivePrice, CostInBillingCurrency, CostCenter, ConsumedService, ResourceId, Tags, OfferId, AdditionalInfo, ServiceInfo1, ServiceInfo2, ResourceName, ReservationId, ReservationName, UnitPrice, ProductOrderId, ProductOrderName, Term, PublisherType, PublisherName, ChargeType, Frequency, PricingModel, AvailabilityZone, BillingAccountId, BillingAccountName, BillingCurrencyCode, BillingPeriodStartDate, BillingPeriodEndDate, BillingProfileId, BillingProfileName, InvoiceSectionId, IsAzureCreditEligible, PartNumber, PayGPrice, PlanName, ServiceFamily, CostAllocationRuleName, benefitId, benefitName
MCA (Sep 2022):
    invoiceId, previousInvoiceId, billingAccountId, billingAccountName, billingProfileId, billingProfileName, invoiceSectionId, invoiceSectionName, resellerName, resellerMpnId, costCenter, billingPeriodEndDate, billingPeriodStartDate, servicePeriodEndDate, servicePeriodStartDate, date, serviceFamily, productOrderId, productOrderName, consumedService, meterId, meterName, meterCategory, meterSubCategory, meterRegion, ProductId, ProductName, SubscriptionId, subscriptionName, publisherType, publisherId, publisherName, resourceGroupName, ResourceId, resourceLocation, location, effectivePrice, quantity, unitOfMeasure, chargeType, billingCurrency, pricingCurrency, costInBillingCurrency, costInPricingCurrency, costInUsd, paygCostInBillingCurrency, paygCostInUsd, exchangeRatePricingToBilling, exchangeRateDate, isAzureCreditEligible, serviceInfo1, serviceInfo2, additionalInfo, tags, PayGPrice, frequency, term, reservationId, reservationName, pricingModel, unitPrice, costAllocationRuleName, benefitId, benefitName, provider
CSP (Sep 2022):
    invoiceId, billingAccountId, billingAccountName, previousInvoiceId, billingProfileId, billingProfileName, invoiceSectionId, invoiceSectionName, partnerTenantId, partnerName, resellerName, resellerMpnId, customerTenantId, customerName, costCenter, billingPeriodStartDate, billingPeriodEndDate, servicePeriodStartDate, servicePeriodEndDate, date, serviceFamily, productOrderId, productOrderName, consumedService, meterId, meterName, meterCategory, meterSubCategory, meterRegion, productId, product, subscriptionId, subscriptionName, publisherType, publisherId, publisherName, resourceGroupName, resourceId, resourceLocation, location, effectivePrice, quantity, unitOfMeasure, chargeType, billingCurrency, pricingCurrency, costInBillingCurrency, costInPricingCurrency, costInUsd, paygCostInBillingCurrency, paygCostInUsd, exchangeRatePricingToBilling, exchangeRateDate, isAzureCreditEligible, serviceInfo1, serviceInfo2, additionalInfo, tags, partnerEarnedCreditRate, partnerEarnedCreditApplied, payGPrice, frequency, term, reservationId, reservationName, pricingModel, unitPrice, costAllocationRuleName, provider, benefitId, benefitName
Internal (Sep 2022):
    SubscriptionGuid, ResourceGroup, ResourceLocation, UsageDateTime, MeterCategory, MeterSubcategory, MeterId, MeterName, MeterRegion, UsageQuantity, ResourceRate, PreTaxCost, ConsumedService, ResourceType, InstanceId, Tags, OfferId, AdditionalInfo, ServiceInfo1, ServiceInfo2, ServiceName, ServiceTier, Currency, UnitOfMeasure
MG (Aug 2022):
    DepartmentName, AccountName, AccountOwnerId, SubscriptionGuid, SubscriptionName, ResourceGroup, ResourceLocation, AvailabilityZone, UsageDateTime, ProductName, MeterCategory, MeterSubcategory, MeterId, MeterName, MeterRegion, UnitOfMeasure, UsageQuantity, ResourceRate, PreTaxCost, CostCenter, ConsumedService, ResourceType, InstanceId, Tags, OfferId, AdditionalInfo, ServiceInfo1, ServiceInfo2, Currency
-->

> ℹ️ _The table assumes all fields are Pascal-cased (first letter of each word capitalized)._

| Column                     | Type   | Value                                                                                                       | Notes                                                   |
| -------------------------- | ------ | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Date                       | Date   | Date \|\| UsageDateTime                                                                                     |
| Provider                   | String | Provider == null<br>or Provider == "Azure"<br>? "Microsoft" : Provider                                      | Default to "Microsoft" for classic accounts.            |
| BillingAccountId           | String | BillingAccountId \|\| null                                                                                  |
| BillingAccountName         | String | BillingAccountName \|\| null                                                                                |
| ResourceId                 | String | ResourceId \|\| InstanceId                                                                                  |
| ResourceName               | String | ([parse](#how-to-parse-resourceid))                                                                         | Do not use value from exports since it is not accurate. |
| ResourceType               | String | ([parse](#how-to-parse-resourceid))                                                                         | Do not use value from exports since it is not accurate. |
| ConsumedService            | String |
| ResourceLocation           | String | ResourceLocation \|\| Location                                                                              |
| Tags                       | Object | Tags startswith "{"<br>? parsejson("\{{Tags}\}") : parsejson(Tags)                                          |
| ResourceGroup              | String | ResourceGroup == "$system"<br>? ([parse])(#how-to-parse-resourceid)<br>: ResourceGroup                      |
| SubscriptionId             | String | SubscriptionId \|\| SubscriptionGuid                                                                        |
| SubscriptionName           | String |
| ProductOrderId             | String | ProductOrderId \|\| OfferId                                                                                 |
| ProductOrderName           | String | ProductOrderName \|\| OfferName                                                                             |
| CostCenter                 | String |
| AccountOwnerId             | String |
| AccountName                | String |
| InvoiceSectionId           | String |
| InvoiceSectionName         | String | InvoiceSectionName \|\| InvoiceSection \|\| DepartmentName                                                  |
| BillingProfileId           | String |
| BillingProfileName         | String |
| CustomerTenantId           | String |
| CustomerName               | String |
| ResellerMpnId              | String |
| ResellerName               | String |
| PartnerTenantId            | String |
| PartnerName                | String |
| PartnerEarnedCreditRate    | Number |
| PartnerEarnedCreditApplied | Bool   | tolower(tostring(PartnerEarnedCreditApplied)) == "true"                                                     | Handle both string and boolean values.                  |
| PublisherType              | String | PublisherType \|\| "Azure"                                                                                  | Default to "Azure" for classic accounts.                |
| PublisherId                | String |
| PublisherName              | String | PublisherName \|\| "Microsoft"                                                                              | Default to "Microsoft" for classic accounts.            |
| PlanName                   | String |
| ServiceFamily              | String |
| MeterCategory              | String | ServiceName \|\| MeterCategory                                                                              | Prefer ServiceName for EA.                              |
| MeterSubCategory           | String | ServiceTier \|\| MeterSubCategory \|\| MeterSubcategory                                                     | Prefer ServiceTier for EA.                              |
| ProductId                  | String |
| ProductName                | String | ProductName \|\| Product                                                                                    |
| MeterId                    | String | MeterId \|\| ResourceGuid                                                                                   |
| MeterName                  | String |
| PartNumber                 | String |
| MeterRegion                | String |
| AdditionalInfo             | Object | AdditionalInfo startswith "{"<br>? parsejson("\{{AdditionalInfo}\}")<br>: parsejson(AdditionalInfo)         |
| ServiceInfo1               | String |
| ServiceInfo2               | String |
| IsAzureCreditEligible      | Bool   | tolower(tostring(IsAzureCreditEligible \|\| IsCreditEligible)) == "true"                                    | Handle both string and boolean values.                  |
| ChargeType                 | String | ChargeType \|\| "Usage"                                                                                     | Default to "Usage" for classic accounts.                |
| PricingModel               | String | PricingModel \|\| "OnDemand"                                                                                | Default to "OnDemand" for classic accounts.             |
| BenefitId                  | String | BenefitId == null<br>? ReservationId : BenefitId                                                            |
| BenefitName                | String | BenefitName == null<br>? ReservationName : BenefitName                                                      |
| Term                       | String |
| Frequency                  | String |
| CostAllocationRuleName     | String |
| InvoiceId                  | String |
| PreviousInvoiceId          | String |
| BillingPeriodStartDate     | Date   |
| BillingPeriodEndDate       | Date   |
| ServicePeriodStartDate     | Date   |
| ServicePeriodEndDate       | Date   |
| Quantity                   | Number | Quantity \|\| UsageQuantity                                                                                 |
| UnitPrice                  | Number | UnitPrice \|\| ResourceRate                                                                                 |
| EffectivePrice             | Number | EffectivePrice \|\| UnitPrice                                                                               |
| PayGPrice                  | Number | PayGPrice \|\| UnitPrice                                                                                    |
| UnitOfMeasure              | String |
| BillingCurrency            | String | BillingCurrency \|\| BillingCurrencyCode \|\| Currency                                                      |
| Cost                       | Number | Cost \|\| CostInBillingCurrency \|\| PreTaxCost                                                             |
| CostUSD                    | Number | Currency == "USD"<br>? Cost<br>: (CostUSD \|\| CostInUsd \|\| CostInPricingCurrency)                        |
| RetailCost                 | Number | RetailCost == null<br>and PayGPrice == UnitPrice<br>? Cost<br>: (RetailCost \|\| PaygCostInBillingCurrency) |
| RetailCostUSD              | Number | Currency == "USD"<br>? RetailCost : (RetailCostUSD \|\| PaygCostInUsd)                                      |
| ExchangeRate               | Number | Currency == "USD"<br>? 1<br>: ExchangeRate \|\| ExchangeRatePricingToBilling                                |
| ExchangeRateDate           | Date   | ExchangeRateDate \|\| startofmonth(Date)                                                                    |

Note the following fields have been removed:

- `AvailabilityZone` is N/A for Microsoft Cloud.
- `PricingCurrency` is always USD for MCA and N/A for other account types.
- `ReservationId` is replaced by `BenefitId`.
- `ReservationName` is replaced by `BenefitName`.

### How to parse ResourceId

To get the resource type:

| Example                                                                                   | Step                                                                                |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| /subscriptions/###/resourceGroups/foo/providers/Microsoft.SQL/servers/bar/databases/baz   | Start with the ResourceId                                                           |
| ~/subscriptions/###/resourceGroups/foo/providers/~Microsoft.SQL/servers/bar/databases/baz | Remove everything up to and including the last "/providers/"                        |
| Microsoft.SQL/servers~/bar~/databases~/baz~                                               | Split the string by "/" and remove even-numbered segments starting at an index of 2 |
| Microsoft.SQL/servers/databases                                                           | This is the resource type                                                           |

To get the resource provider:

| Example                         | Step                                      |
| ------------------------------- | ----------------------------------------- |
| Microsoft.SQL/servers/databases | Start with the ResourceType               |
| Microsoft.SQL                   | Trim everything starting at the first "/" |

To get the resource name:

| Example                                                                                   | Step                                                                                   |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| /subscriptions/###/resourceGroups/foo/providers/Microsoft.SQL/servers/bar/databases/baz   | Start with the ResourceId                                                              |
| ~/subscriptions/###/resourceGroups/foo/providers/~Microsoft.SQL/servers/bar/databases/baz | Remove everything up to and including the last "/providers/"                           |
| Microsoft.SQL/servers~/bar~/databases~/baz~                                               | Split the string by "/" and only keep even-numbered segments starting at an index of 2 |
| bar/baz                                                                                   | This is the resource name                                                              |

<br>
