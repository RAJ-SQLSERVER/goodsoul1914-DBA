$managementServer = "GTSQL01"
$managentDatabase = "DBA"

cls

#$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

## Alleen HiX
$SqlInstances = "GPHIXDWHLS01","GAHIXDWHLS01","BPHIXLS01", "GPHIXDWHSQL01", "GAHIXDWHSQL01", "GPHIXSQL02", "GPHIXLS03", "GPHIXDWH02"

Get-DbaEstimatedCompletionTime -SqlInstance $SqlInstances -ErrorAction SilentlyContinue | 
    Where-Object { ($_.Command -like "BACKUP*") -or ($_.Command -like "RESTORE*")  } | 
        Select-Object ComputerName,InstanceName,Command,Database,Login,StartTime,RunningTime,EstimatedTimeToGo,PercentComplete | ft -AutoSize

