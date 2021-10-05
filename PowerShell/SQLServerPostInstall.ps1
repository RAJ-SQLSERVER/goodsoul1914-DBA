###############################################################################
#               Bravis SQL Server Post-Install Script                         #
###############################################################################

# Replace with new server name
$SqlInstance = 'GTSQL01'

# DO NOT CHANGE ANYTHING BENEATH THIS LINE !!!

New-DbaLogin -SqlInstance $SqlInstance -Login ZKH\sec_DBA
Set-DbaLogin -SqlInstance $SqlInstance -Login ZKH\sec_DBA -AddRole sysadmin

New-DbaLogin -SqlInstance $SqlInstance -Login ZKH\sec_TAB
New-DbaDbUser -SqlInstance $SqlInstance -Login ZKH\sec_TAB -ExcludeDatabase master,model,tempdb
Add-DbaDbRoleMember -SqlInstance $SqlInstance -Role db_datareader -User ZKH\sec_TAB

$master = Get-DbaDatabase -SqlInstance $SqlInstance -Database master
$msdb = Get-DbaDatabase -SqlInstance $SqlInstance -Database msdb
$userdbs = Get-DbaDatabase -SqlInstance $SqlInstance -ExcludeDatabase master,model,msdb,tempdb

$master | Invoke-DbaQuery -Query "CREATE SERVER ROLE tab;"
$master | Invoke-DbaQuery -Query "ALTER SERVER ROLE tab ADD MEMBER [ZKH\sec_TAB];"
$master | Invoke-DbaQuery -Query "GRANT VIEW SERVER STATE TO tab;"
$master | Invoke-DbaQuery -Query "GRANT VIEW ANY DEFINITION TO tab;"

$msdb | Invoke-DbaQuery -Query "CREATE USER [ZKH\sec_TAB] FOR LOGIN [ZKH\sec_TAB];"
$msdb | Invoke-DbaQuery -Query "ALTER ROLE SQLAgentReaderRole ADD MEMBER [ZKH\sec_TAB];"

$userdbs | Invoke-DbaQuery -Query "GRANT BACKUP DATABASE TO [ZKH\sec_TAB];"
$userdbs | Invoke-DbaQuery -Query "EXEC sys.sp_addextendedproperty @name=N'Contact', @value=N'';"
$userdbs | Invoke-DbaQuery -Query "EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'';"
$userdbs | Invoke-DbaQuery -Query "EXEC sys.sp_addextendedproperty @name=N'Owner', @value=N'';"
$userdbs | Invoke-DbaQuery -Query "EXEC sys.sp_addextendedproperty @name=N'Supplier', @value=N'';"
$userdbs | Invoke-DbaQuery -Query "EXEC sys.sp_addextendedproperty @name=N'Telephone', @value=N'';"
