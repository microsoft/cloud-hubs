<#
.SYNOPSIS
    Builds all toolkit templates for publishing to Azure Quickstart Templates.
.DESCRIPTION
    Run this from the /src/scripts folder.
.EXAMPLE
    ./Build-Toolkit
    Builds all FinOps toolkit templates.
#>
Param(
)

# Create output directory
$outdir = "../../release"
If ((Test-Path $outdir) -eq $false) {
    New-Item $outdir -ItemType Directory | Out-Null
}

# Generate JSON parameters
Get-ChildItem ..\templates\*\main.bicep `
| ForEach-Object {
    $bicep = $_
    $tmpName = $bicep.Directory.Name
    $tmpDir = "$outdir/$tmpName"
    If ((Test-Path $tmpDir) -eq $false) {
        New-Item $tmpDir -ItemType Directory | Out-Null
    }
    
    Write-Host 'Generating template...'
    bicep build $bicep --outfile "$tmpDir/azuredeploy.json"
    Write-Host ''    
    Write-Host 'Generating parameters...'
    bicep generate-params $bicep --outfile "$tmpDir/azuredeploy.json"
    Write-Host ''    
}


