$managementServer = "GTSQL01"
$managentDatabase = "DBA"

$today = (Get-Date).Date.tostring("yyyy-MM-dd")

$head = @"
<style>
body {
    font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
	line-height: 1;
}

ol, ul {
	list-style: none;
}

table {
    /*font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;*/
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 2em;
}

td, th {
    border: 1px solid #ddd;
    padding: 8px;
    vertical-align: top;
}

tr:nth-child(even){
    background-color: #f2f2f2;
}

tr:hover {
    background-color: #ddd;
}

th {
    padding-top: 12px;
    padding-bottom: 12px;
    text-align: left;
    background-color: #e23f44;
    color: white;
}

ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
    overflow: hidden;
    background-color: #333;
    position: -webkit-sticky; /* Safari */
    position: sticky;
    top: 0;
}

li {
    float: left;
}

li a {
    display: block;
    color: white;
    text-align: center;
    padding: 14px 16px;
    text-decoration: none;
}

li a:hover {
    background-color: #111;
}

#content {
    padding: 2em;
}
</style>
<title>Bravis SQL Server Report</title>
"@

$instances = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM vwSqlInstances ORDER BY SqlInstance;" | 
    SELECT SqlInstance, SqlEdition, SqlVersion, ProcessorInfo, PhysicalMemory, Scan, Owner, UpdatedAt | 
    ConvertTo-Html -Fragment

$errors = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM vwErrorLogLatest ORDER BY SqlInstance, Count DESC;" | 
    SELECT SqlInstance, Text, Count | 
    ConvertTo-Html -Fragment

$jobs = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT Server,RunDate,JobName,StepID,StepName,RunDuration,SqlMessageID,SqlSeverity,Message FROM vwFailedAgentJobsLatest;" | 
    SELECT Server, RunDate, JobName, StepID, StepName, RunDuration, Message | 
    ConvertTo-Html -Fragment

$cpu = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM vwHighCPUUtilizationLatestGrouped ORDER BY Count DESC" | 
    SELECT SqlInstance, Count | 
    ConvertTo-Html -Fragment

$diskspace = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM vwDiskSpaceLatest" | 
    SELECT ComputerName, Name, Capacity, Free, PercentFree, DriveType, SizeInKB, FreeInKB, SizeInMB, FreeInMB, SizeInGB, FreeInGB, SizeInTB, FreeInTB | 
    ConvertTo-Html -Fragment

$newLogins = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM vwNewServerLoginsLatest ORDER BY SqlInstance" | 
    SELECT SqlInstance, Name, Type, DefaultDatabase, DenyWindowsLogin, IsDisabled, IsLocked, IsPasswordExpired, MustChangePassword, PasswordExpirationEnabled, PasswordPolicyEnforced | 
    ConvertTo-Html -Fragment

$growEvents = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM DBA.dbo.vwDatabaseGrowEventsLatestGrouped ORDER BY GrowEvents DESC" | 
    SELECT SqlInstance, DatabaseName, GrowEvents | 
    ConvertTo-Html -Fragment

$backupInfo = Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT * FROM DBA.dbo.vwDatabaseBackupInfoLatest ORDER BY SqlInstance, Name;" | 
    SELECT SqlInstance, Name, RecoveryModel, LogReuseWaitStatus, LastBackup, BackupType | 
    ConvertTo-Html -Fragment

$body = @"
<h1>Bravis SQL Server rapportage van $today</h1>
<ul>
    <li><a href="#instances">SQL Server overzicht</a></li>
    <li><a href="#errors">Errorlogs</a></li>
    <li><a href="#jobs">Agentlogs</a></li>
    <li><a href="#cpu">CPU</a></li>
    <li><a href="#diskspace">Schijfruimte</a></li>
    <li><a href="#newlogins">Logins</a></li>
    <li><a href="#growEvents">Groei</a></li>
    <li><a href="#backupInfo">Backups</a></li>
</ul>

<div id="content">
    <h2 id="instances">SQL Server overzicht</h2>
    $instances

    <h2 id="errors">Errorlogs</h2>
    $errors

    <h2 id="jobs">Agentlogs</h2>
    $jobs 

    <h2 id="cpu">Hoge CPU belasting</h2>
    $cpu

    <h2 id="diskspace">Schijfruimte</h2>
    $diskspace

    <h2 id="newlogins">Nieuwe Server Logins</h2>
    $newLogins

    <h2 id="growEvents">Database Groei</h2>
    $growEvents

     <h2 id="backupInfo">Te Controleren Backups</h2>
    $backupInfo
</div>
"@

ConvertTo-Html -Body $body -Head $head | Out-File "\\zkh.local\zkh\Automatisering\TAB\MarkT\SQL Server\Reports\DBA\$today.html"