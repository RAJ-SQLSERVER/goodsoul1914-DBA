$managementServer = "GTSQL01"
$managentDatabase = "DBA"

## Retrieve all SQL Server instances from the management database
Try {
    $SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -ErrorAction Stop -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve all SQL Server instances from the management database failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve all unique computernames from the management database
Try {
    $ComputerNames = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -ErrorAction Stop -Query "SELECT DISTINCT ComputerName FROM dbo.SqlInstances WHERE Scan = 1 ORDER BY ComputerName;").ComputerName
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve all unique computernames from the management database failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Update some fields of instance records
Try {
    foreach ($instance in $SqlInstances) {    
        $infoObj = Get-DbaInstanceProperty -SqlInstance $instance -ErrorAction Stop

        $version = ($infoObj | where {$_.Name -eq "VersionString"}).Value
        $edition = ($infoObj | where {$_.Name -eq "Edition"}).Value

        Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "UPDATE dbo.SqlInstances SET Timestamp = GETDATE(), SqlVersion = '$version', SqlEdition = '$edition' WHERE SqlInstance = '$instance';" -ErrorAction Stop
    }
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Update some fields of instance records failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Update some fields of computer records
Try {
    foreach ($computer in $ComputerNames) {    
        $infoObj = Get-DbaComputerSystem -ComputerName $computer

        $cpuPhysicalCount = $infoObj.NumberProcessors
        $cpuLogicalCount = $infoObj.NumberLogicalProcessors
        $memPhysical = $infoObj.TotalPhysicalMemory

        Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "UPDATE dbo.SqlInstances SET Timestamp = GETDATE(), ProcessorInfo = '$cpuPhysicalCount / $cpuLogicalCount', PhysicalMemory = '$memPhysical' WHERE ComputerName = '$computer';"
    }
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Update some fields of computer records failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve errorlog info
Try {
    Get-DbaErrorLog -SqlInstance $SqlInstances -After (Get-Date).AddDays(-1) -ErrorAction Stop | 
        Select-Object ComputerName,InstanceName,SqlInstance,LogDate,Source,Text | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table ErrorLogs -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve errorlog info failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve failed agent jobs from all instances
Try {
    Get-DbaAgentJobHistory -SqlInstance $SqlInstances -StartDate (Get-Date).AddDays(-1) -OutcomeType Failed -ErrorAction Stop | 
        Select-Object SqlMessageID,Message,StepID,StepName,SqlSeverity,JobID,JobName,RunStatus,RunDate,RunDuration,RetriesAttempted,Server | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table FailedJobHistory -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve failed agent jobs from all instances failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve database info
Try {
    Get-DbaDatabase -SqlInstance $SqlInstances -ErrorAction Stop | 
        Select SqlInstance,Name,SizeMB,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup,ActiveConnections,Collation,ContainmentType,CreateDate,DataSpaceUsage,FilestreamDirectoryName,IndexSpaceUsage,LogReuseWaitStatus,PageVerify,PrimaryFilePath,ReadOnly,RecoveryModel,Size,SnapshotIsolationState,SpaceAvailable,MaxDop,ServerVersion | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table Databases -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve database info failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve diskspace info
Try {
    Get-DbaDiskSpace -ComputerName $ComputerNames -ErrorAction Stop | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DiskSpace -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve diskspace info failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve disk speed
Try {
    Test-DbaDiskSpeed -SqlInstance $SqlInstances -ErrorAction Stop | 
        Select-Object SqlInstance,Database,SizeGB,FileName,FileID,FileType,DiskLocation,Reads,AverageReadStall,ReadPerformance,Writes,AverageWriteStall,WritePerformance,"Avg Overall Latency","Avg Bytes/Read","Avg Bytes/Write","Avg Bytes/Transfer" | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DiskSpeedTests -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve errorlog info failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve all logins
Try {
    Get-DbaLogin -SqlInstance $SqlInstances -ErrorAction Stop | 
        Select-Object ComputerName,InstanceName,SqlInstance,LastLogin,AsymmetricKey,Certificate,CreateDate,Credential,DateLastModified,DefaultDatabase,DenyWindowsLogin,HasAccess,ID,IsDisabled,IsLocked,IsPasswordExpired,IsSystemObject,LoginType,MustChangePassword,PasswordExpirationEnabled,PasswordHashAlgorithm,PasswordPolicyEnforced,Sid,WindowsLoginAccessType,Name | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table ServerLogins -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve all logins failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve all database role members
Try {
    Get-DbaDbRoleMember -SqlInstance $SqlInstances -ExcludeDatabase tempdb,model -ErrorAction Stop | 
        Select-Object ComputerName,InstanceName,SqlInstance,Database,Role,UserName,Login,IsSystemObject,LoginType | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DatabaseRoleMembers -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve all database role members failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve all server role members
Try {
    Get-DbaServerRoleMember -SqlInstance $SqlInstances -ErrorAction Stop | 
        Select-Object ComputerName,InstanceName,SqlInstance,Role,Name | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table ServerRoleMembers -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve all server role members failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve database space info
Try {
    Get-DbaDbSpace -SqlInstance $SqlInstances -ErrorAction Stop | 
        Select-Object ComputerName,InstanceName,SqlInstance,Database,FileName,FileGroup,PhysicalName,FileType,UsedSpace,FreeSpace,FileSize,PercentUsed,AutoGrowth,AutoGrowType,SpaceUntilMaxSize,AutoGrowthPossible,UnusableSpace | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DatabaseSpace -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve database space info failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve all growth events
Try {
    Find-DbaDbGrowthEvent -SqlInstance $SqlInstances -UseLocalTime -ErrorAction Stop | 
        Where-Object {$_.StartTime -ge (Get-Date).AddDays(-1)} | 
        Select-Object SqlInstance,DatabaseName,FileName,Duration,StartTime,EndTime,ChangeInSize,ApplicationName,HostName,SessionLoginName |
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DatabaseGrowthEvents -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve all growth events failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve index information on Sundays
#if ((Get-Date).DayOfWeek -eq "Sunday") {
#    Get-DbaHelpIndex -SqlInstance $SqlIndexInstances -IncludeDataTypes -IncludeFragmentation -ExcludeDatabase master,model,msdb,tempdb,HIX_PRODUCTIE,HIX_ACCEPTATIE,HIX_ONTWIKKEL,HIX_TEST,HiX_Bravis61,HiX_Bravis62,HiX_Acc,HiX_Prod -ErrorAction Stop | 
#        Select-Object ComputerName,InstanceName,SqlInstance,Database,Object,Index,IndexType,Statistics,KeyColumns,IncludeColumns,FilterDefinition,DataCompression,IndexReads,IndexUpdates,Size,IndexRows,IndexLookups,MostRecentlyUsed,StatsSampleRows,StatsRowMods,HistogramSteps,StatsLastUpdated,IndexFragInPercent | 
#        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DatabaseIndexes -AutoCreateTable
#}

## Retrieve suspect page information
Try {
Get-DbaSuspectPage -SqlInstance $SqlInstances -ErrorAction Stop | 
    Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table SuspectPages -AutoCreateTable -ErrorAction Stop
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve suspect page information failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Retrieve default trace info
Try {
    $dt = (Get-Date).AddDays(-1)
    $where = "DatabaseName is not NULL
    and DatabaseName != 'tempdb'
    and StartTime >= '$dt'
    and ApplicationName not like 'SQLAgent - TSQL JobStep %'
    AND ApplicationName NOT LIKE 'oversight'
    AND TextData NOT LIKE '%DBCC %'
    AND TextData NOT LIKE 'No STATS:%'
    AND TextData NOT LIKE 'Login failed%'
    AND TextData NOT LIKE 'dbcc show_stat%'
    AND TextData NOT LIKE 'RESTORE DATABASE%' ESCAPE '\'"
    $SqlInstances | 
        Get-DbaTrace -Id 1 -ErrorAction Stop | 
        Read-DbaTraceFile -Where $where -ErrorAction Stop | 
        Select-Object SqlInstance, LoginName, HostName, DatabaseName, ApplicationName, StartTime, TextData | 
        Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DefaultTraceEntries -AutoCreateTable
    $SqlInstances | Get-DbaTrace -Id 1 | Read-DbaTraceFile -Where $where | Select-Object SqlInstance, LoginName, HostName, DatabaseName, ApplicationName, StartTime, TextData | Write-DbaDataTable -SqlInstance $managementServer -Database $managentDatabase -Table DefaultTraceEntries -AutoCreateTable
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Send-MailMessage -From GPMSTS01@bravis.nl -To DBA@bravis.nl -Subject "Retrieve default trace info failed!" -SmtpServer mail.zkh.local -Body "We failed to read file $FailedItem. The error message was $ErrorMessage"
    Break
}

## Generate a report
powershell.exe -File "C:\temp\SQLServerReport.ps1"