<#
.SYNOPSIS
    Get the HiX Personal Environments for the current user.
.DESCRIPTION
    Get the HiX Personal Environments for the current user. A HiX Personal Environment is only 
    available for the user adding the environment and is used for advanced development or test 
    scenarios.
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

$uri = "$Url/api/v2/personalenvironments"
(Invoke-RestMethod -Uri $uri -UseDefaultCredentials)