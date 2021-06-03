$managementServer = "GTSQL01"
$managentDatabase = "DBA"

# Retrieve all SQL Server instances from the management database
$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

# Retrieve CPU ringbuffer
Get-DbaCpuRingBuffer -SqlInstance $SqlInstances -CollectionMinutes 240 | 
    Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table CPURingBuffers -AutoCreateTable
