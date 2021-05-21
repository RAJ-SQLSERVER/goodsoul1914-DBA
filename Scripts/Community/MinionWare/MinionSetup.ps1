param($ServerName = 'localhost', $DBName = 'master', $JobOwner = 'sa', $MaintType, $User = $null, $PWord = $null, $LogDate = (get-date))

<#

#>

$BaseFolder = (dir | ?{ $_.PsIsContainer -eq $true } | ?{ $_.Name -match "^$MaintType" } | sort -Property name -Descending | select -First 1 -Property FullName).FullName;
$BaseFolder
$ScriptBase = $PSScriptRoot;
$ScriptsToInstall = Get-Content $BaseFolder\InstallOrder.txt;

	"#########################################################" | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;
	"######################### $ServerName ###################" | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;
	"#########################################################" | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;

###########################################
#########BEGIN Shared Components###########
###########################################	

"Shared Components"
$SharedFolder = "$ScriptBase\Shared";
$SharedScriptsToInstall = Get-Content $SharedFolder\InstallOrder.txt;

$SharedScriptsToInstall | %{
	$currScript = $_;
	$currScript;
	"***** $currScript ***** $([Environment]::NewLine)" | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;
	If ($User -eq $null)
	{
		$a = SQLCMD -S $ServerName -d $DBName -i $SharedFolder\$currScript;
	}
	If ($User -ne $null)
	{
		$a = SQLCMD -S $ServerName -d $DBName -i $SharedFolder\$currScript -U $User -P $PWord;
	}
	$a | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;
}
###########################################
#########END Shared Components#############
###########################################	

$ScriptsToInstall | %{ #$ScriptsToInstall
	$currScript = $_;
	$currScriptORIG = $currScript;
	
	
	###########################################
	#########BEGIN Includes####################
	###########################################
	##We put the includes down here instead of at the top so we could have the script
	##replacements inside the includes instead of cluttering up this script with them.
	##This way when we want to change one of them for a specific module we don't have to
	##search through a lot of script and possibly introduce human error.
	##This section has to be below '$currScript = $_'.

	If ($MaintType -eq "Backup")
	{
		. $ScriptBase\Includes\BackupInclude.ps1
	}
	If ($MaintType -eq "Reindex")
	{
		. ./Includes/ReindexInclude.ps1
	}
	If ($MaintType -eq "CheckDB")
	{
		. ./Includes/CheckDBInclude.ps1
	}

	####################################
	#########BEGIN Run##################
	####################################

	If ($currScript -notin "BackupDB.sql", "BackupFileAction.sql", "BackupFilesDelete.sql")
	{
		$a = SQLCMD -S $ServerName -d $DBName -i $BaseFolder\$currScript;
	}
	#Invoke-Sqlcmd -ServerInstance $ServerName -Database $DBName -query "$currScript"##"$BaseFolder\$currScript";
		
	If ($currScriptORIG -in "BackupDB.sql", "BackupFileAction.sql", "BackupFilesDelete.sql")
	{ #Alternate Method
		##In the alternate method we have to drop the SP separately, and there's no reason
		##why we can't use sqlcmd.
		$currSP = $currScript.split(".");
		$DropSQL = "If exists (select 1 from sys.objects where name = '$($currSP[0])') DROP PROCEDURE Minion.$($currSP[0]);"
		$a = SQLCMD -S $ServerName -d $DBName -Q "$DropSQL;";
		
		$AltScript = [Io.File]::ReadAllText("$BaseFolder\$_");
		$con = New-Object System.Data.SqlClient.SqlConnection;
		If ($User -eq $null)
		{
			$con.ConnectionString = "Server=$ServerName; Database=$DBName; Integrated Security=true";
		}
		If ($User -ne $null)
		{
			$con.ConnectionString = "Server=$ServerName; Database=$DBName; UID=$User; PWD=$PWord;";
		}
		$con.open();
		$cmd = New-Object System.Data.SqlClient.SqlCommand;		
		$cmd.CommandText = $AltScript;
		$cmd.Connection = $con;
		$dr = $cmd.ExecuteNonQuery();
		#$dr.Close();
		$con.Close();
	} #Alternate Method
	"$BaseFolder\$currScript";
	"***** $currScript ***** $([Environment]::NewLine)" | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;
	$a | Out-File $ScriptBase\InstallLog\$LogDate.txt -Append;

	###Delete temp job file.
	If ($currScriptORIG -in 'Jobs.sql', 'Data.sql')
	{
		del "$BaseFolder\$currScriptORIG`TEMP";
	}
	####################################
	#########END Run####################
	####################################

} #$ScriptsToInstall