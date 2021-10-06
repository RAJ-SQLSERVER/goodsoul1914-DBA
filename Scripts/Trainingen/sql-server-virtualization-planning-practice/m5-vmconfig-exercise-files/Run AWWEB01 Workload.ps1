[void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");

#Set the server to script from 
$ServerName = ".";

$Queries = Get-Content -Delimiter "------" -Path "AdventureWorks BOL Workload.sql"

WHILE(1 -eq 1)
{
	$Query = Get-Random -InputObject $Queries;

	#Get a server object which corresponds to the default instance 
	$srv = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Server $ServerName
	$srv.ConnectionContext.set_ConnectionString("Data Source=VM-SQL2K12-HV;Initial Catalog=AdventureWorks2012;User Id=aw_webuser;Password=12345;Application Name=AdventureWorks Online Ordering;Workstation ID=AWWEB01");
	
	[Void]$srv.ConnectionContext.ExecuteNonQuery($Query);
	$srv.ConnectionContext.Disconnect();
	
	Start-Sleep -Milliseconds 100 
}

# Set-executionpolicy unrestricted