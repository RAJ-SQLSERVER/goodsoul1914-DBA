param ($ServerName = 'localhost',
	$DBName = 'CheckDBInstallTest',
	$MaintType = "Backup|CheckDB",
	$User = $null,
	$PWord = $null)

<#
Minion Install Instructions:
Read the Install.docx for details on all important aspects of this installer.
Do not proceed with the install until you have read the doc and understand the impact
on your servers.

#>

#####################################
######### BEGIN PS Version Check#####
#####################################
$PSInstallVersion = $PSVersionTable.PSVersion.Major;

If ($PSInstallVersion -lt 3)
{
	"Powershell 3.0 or higher is required for this installer.";
	"The currently installed Powershell information is below:";
	$PSVersionTable.PSVersion;
	exit;
}
#####################################
######### END PS Version Check#######
#####################################

$ScriptBase = $PSScriptRoot;
$LogDate = Get-Date -format "yyyyMMddHHmmss";
cd $ScriptBase;
. $ScriptBase\Includes\Banner.ps1;
###########################################
#########BEGIN Set ServerList##############
###########################################

If ($ServerName -eq $null)
{
	$ServerList = "Your server query here"
}

If ($ServerName -ne $null)
{
	$ServerList = $ServerName.split("|")
}

###########################################
#########END Set ServerList################
###########################################


###########################################
#########BEGIN Set MaintType###############
###########################################
If ($MaintType -match "All") { $MaintType = "Backup|Reindex|CheckDB" };
$MaintTypeList = $MaintType.split("|")
###########################################
#########END Set MaintType#################
###########################################

$ServerList | %{ #ServerList
	$currServer = $_;
	"#########################################################"
	"#########################################################"
	"######################### $currServer ###################"
	"#########################################################"
	"#########################################################"
	$MaintTypeList | %{
		#MaintTypeList
		
		$currMaintType = $_;
		
		"##########################################"
		"################ $currMaintType #############"
		"##########################################"
		./MinionSetup.ps1 $currServer $DBName $JobOwner $currMaintType $User $PWord $LogDate;
		
	} #MaintTypeList
} #ServerList



