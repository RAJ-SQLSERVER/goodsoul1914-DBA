<#
.SYNOPSIS
    Get the HiX Environment Security Groups.
.DESCRIPTION
    Get the HiX Environment Security Groups.
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

$uri = "$Url/api/v2/securitygroups"
(Invoke-RestMethod -Uri $uri -UseDefaultCredentials)