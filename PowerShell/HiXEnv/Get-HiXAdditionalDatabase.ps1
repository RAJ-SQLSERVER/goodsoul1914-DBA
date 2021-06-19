<#
.SYNOPSIS
    Get the HiX Environment Additional Databases.
.DESCRIPTION
    Get the HiX Environment Additional Databases. 

	These databases are specific for an environment.
.PARAMETER EnvironmentId
    Filter on the id of the HiX Environment. Wildcards can be used.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)][Alias('id')][string]$EnvironmentId = '*',
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
	$uri = "$Url/api/v2/additionaldatabases"
	(Invoke-RestMethod -Uri $uri -UseDefaultCredentials) | Where-Object { $_.EnvironmentId -like $EnvironmentId}
}