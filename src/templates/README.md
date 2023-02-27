# FinOps toolkit templates

- [finops-hub](./finops-hub)

Please refer to [Creating templates](#creating-templates) below for template requirements.

---

## Creating templates

Templates follow the [Azure Quickstart Templates guidelines](https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/README.md#contribution-guide):

1. Every template should be in its own folder.
   - Try to keep name lengths under 30 characters when possible.
   - Prefer consistent naming across related templates.
2. All files and folders should use kebab casing (lowercase with dashes between words), except README.md.
3. All templates must include the following:

   - `README.md`
     1. Start from the latest [sample README](https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/sample-README.md).
     2. Include the Bicep badge.
     3. Include a Deploy to Azure/AzureGov and Visualize buttons.
        - Sample URL: `https://portal.azure.com/#create/Microsoft.Template/uri/<url-encoded-azuredeploy-path>/createUIDefinitionUri/<url-encoded-createUiDef-path>`
     4. Include a description of what the template will deploy.
     5. Try to avoid having prerequisites. If needed, document them and include a prereq template in the `prereqs` folder and prefix template files with `prereq.`.
     6. Include a description of how to use the resources (or a link to help docs in this repo).
     7. Include any additional notes or considerations for people deploying and managing the template.
     8. Include a list of tags at the bottom of the file. Tags are enclosed in back-ticks.
   - `metadata.json`

     1. Be sure to indicate when features are not available in Azure Gov.
     2. Must adhere to the following structure:

        ```json
        {
          "$schema": "https://aka.ms/azure-quickstart-templates-metadata-schema#",
          "type": "QuickStart",
          "itemDisplayName": "60 char limit",
          "description": "1000 char limit",
          "summary": "200 char limit",
          "githubUsername": "...",
          "dateUpdated": "yyyy-MM-dd",
          "validationType": "Manual"
        }
        ```

   - `main.bicep`
     1. Do not include `azuredeploy.json`. This will be built automatically when merged.
   - `azuredeploy.parameters.json`
     1. Specify a `defaultValue` for all parameters when possible.
     2. Parameters must be camel-cased.
     3. Sort the root elements in this order: targetScope, parameters, variables, resources and modules references, outputs.
     4. Every parameter should have a `@description` or `@metadata` decorator first.
     5. Place a blank line between each parameter.
   - `azuredeploy.parameters.us.json` – Only required if parameters are specific to Azure Gov.
   - `createUiDefinition.json`
     - [CreateUiDef docs](https://learn.microsoft.com/azure/azure-resource-manager/managed-applications/create-uidefinition-overview)
     - [Test in portal](https://portal.azure.com/?feature.customPortal=false&#blade/Microsoft_Azure_CreateUIDef/SandboxBlade)

4. Validate templates using [arm-ttk](https://github.com/Azure/arm-ttk) and [Template Analyzer](https://github.com/Azure/template-analyzer).
5. Create a single PR per template.
