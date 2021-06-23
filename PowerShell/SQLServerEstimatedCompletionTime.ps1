$managementServer = "GTSQL01"
$managentDatabase = "DBA"

cls

#$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

## Alleen HiX
$SqlInstances = "BPHIXLS01", "GTHIXSQL03", "GPHIXDWHLS01", "GPHIXDWHSQL01", "GAHIXDWHLS01", "GAHIXDWHSQL01"

Get-DbaEstimatedCompletionTime -SqlInstance $SqlInstances -ErrorAction SilentlyContinue | 
    Where-Object { ($_.Command -like "BACKUP*") -or ($_.Command -like "RESTORE*")  } | 
    Select-Object ComputerName, InstanceName, Command, Database, Login, StartTime, RunningTime, EstimatedTimeToGo, PercentComplete | 
    Format-Table -AutoSize
