<#
.SYNOPSIS
    Deploys toolkit templates for local testing purposes.
.DESCRIPTION
    Run this from the /src/scripts folder.
.EXAMPLE
    ./Deploy-Toolkit "finops-hub"
    Deploys a new FinOps hub instance.
.EXAMPLE
    ./Deploy-Toolkit -WhatIf
    Validates the deployment template without changing resources.
.PARAMETER Template
    Name of the FinOps toolkit template to deploy. Default = finops-hub.
.PARAMETER ResourceGroup
    Optional. Name of the resource group to deploy to. Will be created if it doesn't exist. Default = ftk-<username>-<computername>.
.PARAMETER Location
    Optional. Azure location to deploy the resource group from. Not used for resources. Resources use the resource group location. Default = westus.
.PARAMETER WhatIf
    Optional. Displays a message that describes the effect of the command, instead of executing the command.
#>
Param(
    [Parameter(Position = 0)][string]$Template = "finops-hub",
    [string]$ResourceGroup,
    [string]$Location = "westus",
    [switch]$WhatIf
)

# Set default RG name to "ftk-<username>-<computername>"
If ([string]::IsNullOrEmpty($ResourceGroup)) {
    # For some reason, using variables directly does not get the value until we write them
    $c = $env:ComputerName
    $u = $env:USERNAME
    $c | Out-Null
    $u | Out-Null
    $ResourceGroup = "ftk-$u-$c".ToLower()
}

# Create resource group if it doesn't exist
$rg = Get-AzResourceGroup $ResourceGroup -ErrorAction SilentlyContinue
If ($null -eq $rg) {
    New-AzResourceGroup `
        -Name $ResourceGroup `
        -Location $Location `
    | Out-Null
}

# Start deployment
$params = @{ hubName = $ResourceGroup };
$hub = New-AzResourceGroupDeployment `
    -TemplateFile "../templates/$Template/main.bicep" `
    -TemplateParameterObject $params `
    -ResourceGroupName $ResourceGroup `
    -WhatIf:$WhatIf

Start-AzDataFactoryV2Trigger `
    -ResourceGroupName $ResourceGroup `
    -DataFactoryName $hub.Outputs.dataFactorytName.Value `
    -Name $hub.Outputs.storageAccountTriggerName.Value -Force -ErrorAction SilentlyContinue

return $hub