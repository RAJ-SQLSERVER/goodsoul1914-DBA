<#
This include is where you will change defaults for your installation.

#>

#########################################################
#########################################################
################ Change This Code #######################
#########################################################
#########################################################

$JobOwner = 'sa';
$AutoThresholdValue = 100;
$HistRetDays = 60;
$DefaultSchema = 'dbo';
$ResultMode = 'FULL';
###########################################
#########BEGIN Reindex Data Values#########
###########################################
##Customize data for Reindex.
#CheckDB data
If ($currScript -eq 'Data.sql')
{
	#Set CheckDB Data
	$DataScript = Get-Content $BaseFolder\$currScript;
	
	$DataScript | Out-File "$BaseFolder\$currScript`TEMP";
	$currScript = "$currScript`TEMP";
	
} #Set CheckDB Data
###########################################
#########END CheckDB Data Values###########
###########################################

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
	$JobScript = $JobScript -replace "SET @ThresholdValue = 100;", "SET @ThresholdValue = $AutoThresholdValue;";
	$JobScript = $JobScript -replace "SET @HistRetDays = 60;", "SET @HistRetDays = $HistRetDays;";
	$JobScript = $JobScript -replace "SET @DefaultSchema = 'dbo';", "SET @DefaultSchema = '$DefaultSchema';";
	$JobScript = $JobScript -replace "SET @ResultMode = 'Full';", "SET @ResultMode = '$ResultMode';";
	
		
	$JobScript | Out-File "$BaseFolder\$currScript`TEMP";
	$currScript = "$currScript`TEMP";
	
} #Set job
###########################################
#########END Set Job DB Values#############
###########################################
