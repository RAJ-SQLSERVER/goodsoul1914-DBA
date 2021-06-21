# SERVICES
Get-Service -ComputerName GAHIXRT01 | Where {$_.Name -like 'CS*'} | Start-Service
Get-Service -ComputerName GAHIXRT01 | Where {$_.Name -like 'CS*'} | Stop-Service

######################################################################################
#   DBA Toolkit 
######################################################################################

## GENERAL
Start-Process https://dbatools.io/builds


## DATABASE PROPERTIES
'GABEAUFORT01' | Get-DbaBuildReference

Get-DbaSpConfigure -SqlInstance 'GABEAUFORT01' | Out-GridView


## STORAGE
Get-DbaDbSpace -SqlInstance 'GABEAUFORT01' | Out-GridView

Get-DbaDbSpace -SqlInstance 'GABEAUFORT01' -IncludeSystemDB | 
    ConvertTo-DbaDataTable | 
    Write-DbaDataTable -SqlInstance 'GABEAUFORT01' -Database tempdb -Table DiskSpaceExample -AutoCreateTable

Invoke-DbaQuery -ServerInstance 'GABEAUFORT01' -Database tempdb -Query 'SELECT * FROM dbo.DiskSpaceExample' | Out-GridView

Get-DbaFile -SqlInstance 'GABEAUFORT01'


## MEMORY
'GABEAUFORT01' | Get-DbaMaxMemory

'GABEAUFORT01' | Test-DbaMaxMemory | Format-Table


## TRANSACTION LOG
Get-DbaDbVirtualLogFile -SqlInstance 'GABEAUFORT01' -Database Beaufort | 
    Out-GridView

Get-DbaDbVirtualLogFile -SqlInstance 'GABEAUFORT01' -Database Beaufort | 
    Measure-Object

## JOBS
"GAENDOBASE01" | Get-DbaAgentJob | Out-GridView

Get-DbaAgentJobHistory -SqlInstance 'GABEAUFORT01' | Out-GridView


## To generate the timeline for agent job history and save as html file:
Get-DbaAgentJobHistory -SqlInstance gpsql01, gpsql02 -StartDate '2018-08-18 00:00' -ExcludeJobSteps | 
    ConvertTo-DbaTimeline | 
    Out-File C:\temp\DbaAgentJobHistory.html -Encoding ASCII


## Backup history timeline:
Get-DbaDbBackupHistory -SqlInstance gpsql01, gpsql02 -Since '2018-08-18 00:00' | 
    ConvertTo-DbaTimeline | 
        Out-File C:\temp\Get-DbaDbBackupHistory.html -Encoding ascii


## OLA, BRENT and WIA
'GABEAUFORT01' | Install-DbaMaintenanceSolution -ReplaceExisting -BackupLocation d:\SQLBackup -InstallJobs -Database master
'GABEAUFORT01' | Install-DbaWhoIsActive -Database ZKH_Maintenance

Invoke-DbaDiagnosticQuery -SqlInstance 'GABEAUFORT01' | 
    Export-DbaDiagnosticQuery -ConvertTo Excel -Path c:\temp -NoPlanExport -NoQueryExport


## Logshipping
Test-DbaDbLogShipStatus -SqlInstance "GPAX4HSQL01"

Test-DbaDbLogShipStatus -SqlInstance "GPWOSQL01" | Out-GridView

Get-DbaDbLogShipError -SqlInstance "GPAX4HSQL01"
Get-DbaDbLogShipError -SqlInstance "GPAX4HSQL01" -DateTimeFrom "11/05/2020"
