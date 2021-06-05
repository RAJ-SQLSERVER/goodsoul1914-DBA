# Retrieve all SQL Server instances from the management database
$SqlInstances = (Invoke-DbaQuery -SqlInstance GTSQL01 -Database DBA -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

# Deploy latest version of community tools
#Install-DbaMaintenanceSolution -SqlInstance $SqlInstances -ReplaceExisting  # DO NOT deploy and overwrite Jobs!
Install-DbaFirstResponderKit -SqlInstance $SqlInstances -Database master -Force
Install-DbaWhoIsActive -SqlInstance $SqlInstances -Database master -Force
