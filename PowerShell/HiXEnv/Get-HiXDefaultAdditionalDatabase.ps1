<#
.SYNOPSIS
    Get the HiX Environment Default Additional Databases.
.DESCRIPTION
    Get the HiX Environment Default Additional Databases. 

	These datbases are default for all environments. This can be used to setup 
	centralized environment settings, audit logging and uxip logging.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$false)][string]$Url
)

Set-StrictMode -Version Latest

if (-not $Url)
{
    $Url = &"$PSScriptRoot\Get-HiXEnvironmentUrl.ps1"
}

$uri = "$Url/api/v2/defaultadditionaldatabases"
(Invoke-RestMethod -Uri $uri -UseDefaultCredentials)