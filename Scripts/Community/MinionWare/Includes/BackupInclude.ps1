<#
This include is where you will change Backup defaults for your installation.

These are the default settings.  MB is easy to customize and add your own settings.
Simply insert it into the table you're interested in.  For more information, see help.
#>

#########################################################
#########################################################
################ Change This Code #######################
#########################################################
#########################################################
#### BackupSettingsPath####

$BackupLocType = 'Local'; #BackupLocType. This is the location type.  Local, NAS, Remote, URL.  This setting is used for your benefit, so put whatever will remind you what type it is.  It only matters if it's 'URL', but that feature isn't live yet so you shouldn't worry about this.
$BackupDrive = 'C:\'; #BackupDrive. Drive letter or base UNC path like '\\MyNAS\'.
$BackupPath = '%SoSL%\%DBName%\'; #BackupPath. The folder structure you want under the base path. So in this case the backups will go to C:\SQLBackups.
$PathFileName = '%Ordinal%of%NumFiles%%DBName%%BackupType%%Date%%Hour%%Minute%%Second%'; #The name of the backup files. This is a dynamic value. See the help file for more details.
$PathFileExtension = '%BackupTypeExtension%'; ##The name of the backup file extensions. This is a dynamic value. See the help file for more details.
$PathServerLabel = 'NULL'; #ServerLabel. Unless you have a reason to change this, you can leave it NULL.  The vid discusses this setting.
$RetHrs = 168; #How long do you want to keep the backup files on disk?
$HistRetDays = 60; #How long do you want to keep the log data?
$JobOwner = 'sa'; #Who do you want to own the jobs the routine runs under.

#################################################################################################################################
#### DO NOT CHANGE CODE BELOW THIS LINE ####################################### DO NOT CHANGE CODE BELOW THIS LINE ##############
#################################################################################################################################
#################################################################################################################################
###################################### DO NOT CHANGE CODE BELOW THIS LINE #######################################################
#################################################################################################################################
#################################################################################################################################
## DO NOT CHANGE CODE BELOW THIS LINE ######################################### DO NOT CHANGE CODE BELOW THIS LINE ##############
###################################### DO NOT CHANGE CODE BELOW THIS LINE #######################################################
#################################################################################################################################

If ($PathServerLabel -eq 'NULL')
{
	$PathServerLabel = 'NULL'
}

If ($PathServerLabel -ne 'NULL')
{
	$PathServerLabel = "'$PathServerLabel'"
}
###########################################
#########BEGIN Backup Data Values##########
###########################################
##Customize data for backups.
	#Backup data
	If ($currScript -eq 'Data.sql')
	{
		#Set Backup Data
		$DataScript = Get-Content $BaseFolder\$currScript;
		
		$DataScript = $DataScript -replace "SET @BackupLocType = 'MinionBackupLocType';", "SET @BackupLocType = '$BackupLocType'";
		$DataScript = $DataScript -replace "SET @BackupDrive = 'MinionBackupDrive';", "SET @BackupDrive = '$BackupDrive';";
		$DataScript = $DataScript -replace "SET @BackupPath = 'MinionBackupPath';", "SET @BackupPath = '$BackupPath';";
		$DataScript = $DataScript -replace "SET @PathFileName = 'MinionPathFileName';", "SET @PathFileName = '$PathFileName';";
		$DataScript = $DataScript -replace "SET @PathFileExtension = 'MinionPathFileExtension';", "SET @PathFileExtension = '$PathFileExtension';";
		$DataScript = $DataScript -replace "SET @PathServerLabel = 'MinionPathServerLabel';", "SET @PathServerLabel = $PathServerLabel;";
		$DataScript = $DataScript -replace "SET @RetHrs = 168;", "SET @RetHrs = $RetHrs;";
		$DataScript = $DataScript -replace "SET $HistRetDays = 60;", "SET @HistRetDays = $HistRetDays;";
	
		$DataScript | Out-File "$BaseFolder\$currScript`TEMP";
		$currScript = "$currScript`TEMP";
	

	} #Set Backup Data
###########################################
#########END Backup Data Values############
###########################################

###########################################
#########BEGIN Set Job DB Values###########
###########################################
##You need to be able to install to the DB of your choice, so here we're changing the DB name the job will run in.
If ($currScript -eq 'Jobs.sql')
{
	#Set job
	$JobScript = Get-Content $BaseFolder\$currScript;
	
	$JobScript = $JobScript -replace "SET @MinionDBName = 'InstallLocation';", "SET @MinionDBName = '$DBName';";
	$JobScript = $JobScript -replace "SET @MinionJobOwner = 'MinionJobOwner';", "SET @MinionJobOwner = '$JobOwner';";
	
	$JobScript | Out-File "$BaseFolder\$currScript`TEMP";
	$currScript = "$currScript`TEMP";
		
	
} #Set job
###########################################
#########END Set Job DB Values#############
###########################################