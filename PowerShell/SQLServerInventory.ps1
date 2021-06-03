$managementServer = "GTSQL01"
$managentDatabase = "DBA"

# Retrieve all SQL Server instances from the management database
$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

# Retrieve all unique computernames from the management database
$ComputerNames = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT DISTINCT ComputerName FROM dbo.SqlInstances ORDER BY ComputerName;").ComputerName

# Retrieve diskspace info
Get-DbaDiskSpace -ComputerName $ComputerNames | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DiskSpace -AutoCreateTable

# Update some fields of instance records
foreach ($instance in $SqlInstances) {    
    $infoObj = Get-DbaInstanceProperty -SqlInstance $instance

    $version = ($infoObj | Where-Object { $_.Name -eq "VersionString" }).Value
    $edition = ($infoObj | Where-Object { $_.Name -eq "Edition" }).Value

    Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "UPDATE dbo.SqlInstances SET Timestamp = GETDATE(), SqlVersion = '$version', SqlEdition = '$edition' WHERE SqlInstance = '$instance';"
}

# Update some fields of computer records
foreach ($computer in $ComputerNames) {    
    $infoObj = Get-DbaComputerSystem -ComputerName $computer

    $cpuPhysicalCount = $infoObj.NumberProcessors
    $cpuLogicalCount = $infoObj.NumberLogicalProcessors
    $memPhysical = $infoObj.TotalPhysicalMemory

    Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "UPDATE dbo.SqlInstances SET Timestamp = GETDATE(), ProcessorInfo = '$cpuPhysicalCount / $cpuLogicalCount', PhysicalMemory = '$memPhysical' WHERE ComputerName = '$computer';"
}

# Update version field of instance records
(Get-DbaInstanceProperty -SqlInstance gpsql01 | Where-Object { $_.Name -eq "VersionString" }).Value

# Retrieve errorlog info
Get-DbaErrorLog -SqlInstance $SqlInstances -After (Get-Date).AddDays(-1) | Select-Object ComputerName, InstanceName, SqlInstance, LogDate, Source, Text | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table ErrorLogs -AutoCreateTable

# Retrieve failed agent jobs from all instances and store them in DBA.dbo.FailedJobHistory
Get-DbaAgentJobHistory -SqlInstance $SqlInstances -StartDate (Get-Date).AddDays(-1) -OutcomeType Failed | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table FailedJobHistory -AutoCreateTable

# Retrieve database info
Get-DbaDatabase -SqlInstance $SqlInstances | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table Databases -AutoCreateTable

# Retrieve disk speed
Test-DbaDiskSpeed -SqlInstance $SqlInstances | Select-Object SqlInstance, Database, SizeGB, FileName, FileID, FileType, DiskLocation, Reads, AverageReadStall, ReadPerformance, Writes, AverageWriteStall, WritePerformance, "Avg Overall Latency", "Avg Bytes/Read", "Avg Bytes/Write", "Avg Bytes/Transfer" | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DiskSpeedTests -AutoCreateTable

# Retrieve default trace info
$dt = (Get-Date).AddDays(-1)
$where = "DatabaseName is not NULL
and DatabaseName != 'tempdb'
and TextData is not NULL
and SERVERPROPERTY('MachineName') != HostName
and StartTime >= '$dt'
and ApplicationName not like 'SQLAgent - TSQL JobStep %' ESCAPE '\'"
$SqlInstances | Get-DbaTrace -Id 1 | Read-DbaTraceFile -Where $where | Select-Object SqlInstance, LoginName, HostName, DatabaseName, ApplicationName, StartTime, TextData | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DefaultTraceEntries -AutoCreateTable

# Retrieve all logins
Get-DbaLogin -SqlInstance $SqlInstances | Select-Object ComputerName, InstanceName, SqlInstance, LastLogin, AsymmetricKey, Certificate, CreateDate, Credential, DateLastModified, DefaultDatabase, DenyWindowsLogin, HasAccess, ID, IsDisabled, IsLocked, IsPasswordExpired, IsSystemObject, LoginType, MustChangePassword, PasswordExpirationEnabled, PasswordHashAlgorithm, PasswordPolicyEnforced, Sid, WindowsLoginAccessType, Name | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table ServerLogins -AutoCreateTable

# Retrieve all database users
Get-DbaDbUser -SqlInstance $SqlInstances | Select-Object ComputerName, InstanceName, SqlInstance, Database, Parent, AsymmetricKey, AuthenticationType, Certificate, CreateDate, DateLastModified, DefaultSchema, HasDBAccess, ID, IsSystemObject, Login, LoginType, Sid, UserType, Name | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DatabaseUsers -AutoCreateTable

#Export-DbaLogin -SqlInstance $SqlInstances -Path \\gohixsql02\migration\Logins