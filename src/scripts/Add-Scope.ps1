param(
  [string]$Scope,
  [string]$ResourceGroupName,
  [string]$StorageAccountId,
  [string]$ContainerName = "export",
  [string]$FolderName = $Scope.Split("/")[-1],
  [string]$Metric = "amortizedcost",
  [bool]$Future = $false,
  [bool]$History = $false,
  [datetime]$StartDate = "2022-10-01",
  [datetime]$EndDate = "2022-12-31",
  [int]$TimeOutMinutes = 15,
  [int]$SleepInterval = 10
)

$ErrorActionPreference = "Stop"
function Write-DebugInfo {
  param (
    $DebugParams
  )

  Write-Host ("{0}    {1}    {2}" -f (Get-Date), $DebugParams.Name, $DebugParams.DefinitionTimeframe)
}
function Set-CostManagementApi {
  param (
    $ApiParams
  )

  $uri = "https://management.azure.com/{0}/providers/Microsoft.CostManagement/exports/{1}?api-version=2021-10-01" -f $ApiParams.Scope, $ApiParams.Name
  Remove-AzCostManagementExport -Name $ApiParams.Name -Scope $ApiParams.Scope -ErrorAction SilentlyContinue
  $payload = '{
    "properties": {
      "schedule": {
        "status": "Active",
        "recurrence": "{7}",
        "recurrencePeriod": {
          "from": "{6}",
          "to": "2099-10-31T00:00:00Z"
        }
      },
      "partitionData": "{5}",
      "format": "Csv",
      "deliveryInfo": {
        "destination": {
          "resourceId": "{0}",
          "container": "{1}",
          "rootFolderPath": "{2}"
        }
      },
      "definition": {
        "type": "{3}",
        "timeframe": "{4}",
        "dataSet": {
          "granularity": "Daily"
        }
      }
    }
  }' 
  
  $payload = $payload.Replace("{0}", $ApiParams.DestinationResourceId)
  $payload = $payload.Replace("{1}", $ApiParams.DestinationContainer)
  $payload = $payload.Replace("{2}", $ApiParams.DestinationRootFolderPath)
  $payload = $payload.Replace("{3}", $ApiParams.DefinitionType)
  $payload = $payload.Replace("{4}", $ApiParams.DefinitionTimeframe)
  $payload = $payload.Replace("{5}", $ApiParams.PartitionData)
  $payload = $payload.Replace("{6}", $ApiParams.RecurrencePeriodFrom)
  $payload = $payload.Replace("{7}", $ApiParams.ScheduleRecurrence)
  $apiResult = Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $payload
  if ($apiResult.StatusCode -ne "201") {
    $apiResult
    Throw "Cost Management API call failed"
  }
}

function Set-CostManagementExport {
  param (
    $ExportParams,
    [bool]$Start = $false
  )

  Write-DebugInfo $ExportParams
  Set-CostManagementApi -ApiParams $ExportParams
  if ($Start) {
    Start-Sleep -Seconds $SleepInterval
    Invoke-AzCostManagementExecuteExport -ExportName $ExportParams.Name -Scope $ExportParams.Scope
    Start-Sleep -Seconds $SleepInterval
    $currentStatus = $null
    $currentStatus = (Get-AzCostManagementExport -Name $ExportParams.Name -Scope $ExportParams.Scope -Expand runHistory).RunHistory.Value[0].Status
    [int]$loop = 0
    while ($currentStatus -eq "InProgress") {
      if ($loop -ge $TimeOutMinutes) {
        $currentStatus = "TimedOut"
      }
      else {
        Start-Sleep -Seconds 60
        $loop++
        $currentStatus = (Get-AzCostManagementExport -Name $ExportParams.Name -Scope $ExportParams.Scope -Expand runHistory).RunHistory.Value[0].Status
        Write-Host ("{0}    {1}    {2}" -f (get-date), $ExportParams.Name, $currentStatus)
      }
    }

    Write-Host ("{0}    {1}    {2}" -f (get-date), $ExportParams.Name, $currentStatus)
  }
}

if ($Future) {
  Write-Host ("{0}    {1}" -f (get-date), "Set Recurring Exports")
  $today = Get-Date
  $nextMonth = $today.AddDays(-$today.Day + 5).AddMonths(1)
  [string]$dateFrom = "{0}-{1}-{2}T10:00:00Z" -f $nextMonth.Year, $nextMonth.Month, $nextMonth.Day

  # Last Billing Month
  $Params = @{
    Name                      = ("{0}-closed-{1}" -f $ContainerName, $Metric)
    DefinitionType            = $Metric
    DataSetGranularity        = 'Daily'
    Scope                     = $Scope
    DestinationResourceId     = $StorageAccountId
    DestinationContainer      = $ContainerName
    DefinitionTimeframe       = 'TheLastBillingMonth'
    ScheduleRecurrence        = 'Monthly'
    RecurrencePeriodFrom      = $dateFrom
    RecurrencePeriodTo        = "2099-12-31T00:00:00Z"
    ScheduleStatus            = 'Active'
    DestinationRootFolderPath = $FolderName
    Format                    = 'Csv'
    PartitionData             = $true
  }
  Set-CostManagementExport -ExportParams $Params -Start $true

  # Billing Month To Date
  $tomorrow = (Get-Date).AddDays(1)
  [string]$dateFrom = "{0}-{1}-{2}T10:00:00Z" -f $tomorrow.Year, $tomorrow.Month, $tomorrow.Day
  $Params = @{
    Name                      =  ("{0}-open-{1}" -f $ContainerName, $Metric)
    DefinitionType            = $Metric
    DataSetGranularity        = 'Daily'
    Scope                     = $Scope
    DestinationResourceId     = $StorageAccountId
    DestinationContainer      = $ContainerName
    DefinitionTimeframe       = 'BillingMonthToDate'
    ScheduleRecurrence        = 'Daily'
    RecurrencePeriodFrom      = $dateFrom
    RecurrencePeriodTo        = "2099-12-31T00:00:00Z"
    ScheduleStatus            = 'Active'
    DestinationRootFolderPath = $FolderName
    Format                    = 'Csv'
    PartitionData             = $true
  }
  Set-CostManagementExport -ExportParams $Params -Start $true  
}

if ($History) {
  [string]$dateFrom = "{0}-{1}-{2}T00:00:00Z" -f $StartDate.Year, $StartDate.Month, $StartDate.Day
  [string]$dateTo = "{0}-{1}-{2}T23:59:59Z" -f $EndDate.Year, $EndDate.Month, $EndDate.Day
  [datetime]$currentDate = $StartDate
  while ($currentDate -le $EndDate) {
    [datetime]$nextDate = $currentDate.AddDays(-$currentDate.Day + 1).AddMonths(1).AddDays(-1)
    [string]$dateFrom = "{0}-{1}-{2}T00:00:00Z" -f $currentDate.Year, $currentDate.Month, $currentDate.Day
    [string]$dateTo = "{0}-{1}-{2}T23:59:59Z" -f $nextDate.Year, $nextDate.Month, $nextDate.Day

    $Params = @{
      Name                      =  ("{0}-history-{1}" -f $ContainerName, $Metric)
      DefinitionType            = $Metric
      DataSetGranularity        = 'Daily'
      Scope                     = $Scope
      DestinationResourceId     = $StorageAccountId
      DestinationContainer      = $ContainerName
      DefinitionTimeframe       = 'Custom'
      ScheduleRecurrence        = 'Daily'
      TimePeriodFrom            = $dateFrom
      TimePeriodTo              = $dateTo
      RecurrencePeriodFrom      = "2099-12-31T00:00:00Z"
      RecurrencePeriodTo        = "2099-12-31T00:00:00Z"
      ScheduleStatus            = 'Inactive'
      DestinationRootFolderPath = $FolderName
      Format                    = 'Csv'
      PartitionData             = $true
    }

    Set-CostManagementExport -ExportParams $Params -Start $true
    $currentDate = $currentDate.AddDays(-$currentDate.Day + 1).AddMonths(1)
  }
}