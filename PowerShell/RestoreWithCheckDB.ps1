# Backup the database
Backup-DbaDatabase -SqlInstance GPHIXSQL02 -Path "\\GOHIXSQL02\migration" -Database HIX_PRODUCTIE -Type Full -FileCount 4 -CompressBackup

# Restore the database
#Restore-DbaDatabase -SqlInstance GOHIXSQL02 -Path "\\gahixsql01\Share" -Database HIX_PRODUCTIE -RestoredDatabaseNamePrefix "dba-" `
#    -DestinationDataDirectory N:\SQLData -DestinationLogDirectory L:\SQLLogs

# Restore the database, perform a CHECKDB and store the result
Test-DbaLastBackup -SqlInstance GPHIXSQL02 -Database HIX_PRODUCTIE -Destination GOHIXSQL02 -DataDirectory N:\SQLData -LogDirectory L:\SQLLogs -Prefix "dba-" -MaxDop 4 | 
    ConvertTo-DbaDataTable | 
    Write-DbaDataTable -SqlInstance GTSQL01 -Table DBA.dbo.LastBackupTests -AutoCreateTable
