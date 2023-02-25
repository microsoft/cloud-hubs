param (
    [string]$ResourceGroup,
    [string][ValidateSet('Deploy', 'Test', 'Clean', 'All')]$Mode
)

Write-Host ("{0}    Mode = {1}" -f (Get-Date), $Mode)

If ([string]::IsNullOrEmpty($ResourceGroup)) {
    # For some reason, using variables directly does not get the value until we write them
    $c = $env:ComputerName
    $u = $env:USERNAME
    $c | Out-Null
    $u | Out-Null
    $ResourceGroup = "ftk-$u-$c".ToLower()
}

if ($Mode -eq 'Clean' -or $Mode -eq 'All') {
    $rg = Get-AzResourceGroup -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
    if ($null -eq $rg) {
        Write-Host ("{0}    Resource Group Not Found" -f (Get-Date))
    }
    else {
        Write-Host ("{0}    Remove Existing Deployment" -f (Get-Date))
        $kv = Get-AzKeyVault -ResourceGroupName $ResourceGroup
        Remove-AzResourceGroup -Name $ResourceGroup -Force
        Remove-AzKeyVault -InRemovedState -VaultName $kv.VaultName -Force
        # Get-AzKeyVault -InRemovedState | Remove-AzKeyVault -InRemovedState
    }

    Write-Host ("{0}    Cleanup Complete" -f (Get-Date))
}

if($Mode -eq 'Deploy' -or $Mode -eq 'All') {
    $df = Get-AzDataFactoryV2 -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
    $sa = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -ErrorAction SilentlyContinue
    if($null -ne $df -and $null -ne $sa) {
        Write-Host ("{0}    Stop Existing ADF Trigger" -f (Get-Date))
        Stop-AzDataFactoryV2Trigger `
            -ResourceGroupName $ResourceGroup `
            -DataFactoryName $df.DataFactoryName `
            -Name $sa.StorageAccountName -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Host ("{0}    Start Deployment" -f (Get-Date))
    $result = .\Deploy-Toolkit.ps1 -ResourceGroup $ResourceGroup
    Write-Host ("{0}    Deployment Complete" -f (Get-Date))
    Write-Host ''
    return $result
}

if ($Mode -eq 'Test' -or $Mode -eq 'All') {
    

    
}
