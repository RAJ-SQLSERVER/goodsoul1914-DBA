$managementServer = "GTSQL01"
$managentDatabase = "DBA"

# Retrieve all SQL Server instances from the management database
$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

$Today = (Get-Date -Format "yyyy-MM-dd")

## Alle instances
$SqlInstances | Get-GITCAuditDbRoleMembers | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-DatabaseRoleMembers.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6
$SqlInstances | Get-GITCAuditServerRoleMembers | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-ServerRoleMembers.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6
$SqlInstances | Get-GITCAuditGenericAccount | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GeneriekeAccounts.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6

## AX4Health
#Get-GITCAuditDbRoleMembers -SqlInstance GPAX4HSQL02 | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GPAX4HSQL02-DatabaseRoleMembers.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6
#Get-GITCAuditServerRoleMembers -SqlInstance GPAX4HSQL02 | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GPAX4HSQL02-ServerRoleMembers.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6
#Get-GITCAuditGenericAccount -SqlInstance GPAX4HSQL02 | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GPAX4HSQL02-GeneriekeAccounts.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6

## HiX
#Get-GITCAuditDbRoleMembers -SqlInstance GPHIXSQL02 | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GPHIXSQL02-DatabaseRoleMembers.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6
#Get-GITCAuditServerRoleMembers -SqlInstance GPHIXSQL02 | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GPHIXSQL02-ServerRoleMembers.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6
#Get-GITCAuditGenericAccount -SqlInstance GPHIXSQL02 | Export-Excel -Path "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\GITC\$Today-GPHIXSQL02-GeneriekeAccounts.xlsx" -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow -TableStyle Medium6

