$managementServer = "DT-RSD-01"
$managentDatabase = "DBA"

# Retrieve all SQL Server instances from the management database
$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

# Deploy latest version of community tools
Install-DbaMaintenanceSolution -SqlInstance $SqlInstances -ReplaceExisting  # DO NOT deploy and overwrite Jobs!
Install-DbaFirstResponderKit -SqlInstance $SqlInstances -Force
Install-DbaWhoIsActive -SqlInstance $SqlInstances -Database master -Force
