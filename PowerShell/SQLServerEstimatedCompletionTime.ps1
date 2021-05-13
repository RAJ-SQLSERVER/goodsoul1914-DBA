$managementServer = "LT-RSD-01"
$managentDatabase = "DBA"

Clear-Host
Write-Host "Inventariseren SQL Server servers, een ogenblik geduld..."

# Retrieve all SQL Server instances from the management database
$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

# Retrieve active BACKUP jobs
Get-DbaEstimatedCompletionTime -SqlInstance $SqlInstances | 
    Where-Object { $_.Command -like "BACKUP*" } | 
    Select-Object ComputerName,InstanceName,Command,Database,Login,StartTime,RunningTime,EstimatedTimeToGo,PercentComplete | 
    Format-Table -AutoSize
