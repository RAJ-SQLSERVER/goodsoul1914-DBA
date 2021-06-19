<#
.SYNOPSIS
    Get the HiX Environment Personal Additional Databases.
.DESCRIPTION
    Get the HiX Environment Personal Additional Databases. 

	These databases are specific for a personal environment.
.PARAMETER PersonalEnvironmentId
    Filter on the id of the HiX Personal Environment. Wildcards can be used.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)][Alias('id')][string]$PersonalEnvironmentId = '*',
	[Parameter(Mandatory=$false)][string]$Url
)
begin
{
	Set-StrictMode -Version Latest

	if (-not $Url)
	{
		$Url = &"$PSScriptRoot\Get-HiXEnvironmentUrl.ps1"
	}
}
process
{
	$uri = "$Url/api/v2/personaladditionaldatabases"
	(Invoke-RestMethod -Uri $uri -UseDefaultCredentials) | Where-Object { $_.PersonalEnvironmentId -like $PersonalEnvironmentId}
}