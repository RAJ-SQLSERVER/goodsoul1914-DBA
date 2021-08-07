# today's date in unambiguous d/MMM/yyyy format (because, Aussie here)
$date = Get-Date -Format "d/MMM/yyyy"

# get collection of events from Windows "Application" event log, with source "MSSQLSERVER",
# that occured today between 7:00AM and 6:00PM (business hours),
# with event ID 18264 SQL Server backup
# this will take some time (e.g. minutes) depending on size of event log
# important: pass "AsBaseObject" to get event log entry with necessary properties
# note: backup success messages will not be written to Windows event log if trace flag 3226 is enabled - see https://docs.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-traceon-trace-flags-transact-sql?view=sql-server-ver15
$events = Get-EventLog -AsBaseObject -Log "Application" -Source "MSSQLSERVER" -After ([datetime](($date) + ' 7:00:00 AM')) -Before ([datetime](($date) + ' 6:00:00 PM')) | Where-Object { $_.EventID -eq 18264 }

# did we get any events? If not, leave
If ($null -eq $events -or $events.Count -eq 0) {
  Return
}

# set up e-mail body
$body = "<body><p>The following backups were run in SQL Server during business hours and should be followed up:</p>"

# add to body - output events as HTML table, will include pre- and post-HTML tags
$body += $events |
  Select-Object Message, TimeGenerated, UserName |
  ConvertTo-Html -Fragment -As Table

# append footer and close body
$body += "<p><em>This e-mail was sent by an automated process. Do not reply to this e-mail.</em></p></body>"

# create anonymous credentials for the SMTP server with blank password
# from http://community.idera.com/powershell/ask_the_experts/f/learn_powershell_from_don_jones-24/11843/send-mailmessage-without-authentication
$blank_password = New-Object System.Security.SecureString
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "NT AUTHORITY\ANONYMOUS LOGON", $blank_password

# send e-mail from this server
# pass anonymous credentials
Send-MailMessage -Credential $creds -From "server@domain.com" -To "dba@domain.com" -Subject "** SQL Server Backups during business hours **" -BodyAsHTML -Body $body -SmtpServer "smtp_server.domain.com"