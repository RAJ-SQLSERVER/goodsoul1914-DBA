<#
.SYNOPSIS
    Get the effective HiX Environments as applications would do.
.DESCRIPTION
    Get the effective HiX Environments as applications would do.
.PARAMETER Version
	Specify the version of the HiX Environment. 
.PARAMETER Category
    Specify the category of the HiX Environment.
.PARAMETER Credential
    Specify the credential to use. Otherwise de default credential is used. See Get-Credential.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)][string]$Version,
    [Parameter(Mandatory=$true)][string]$Category,
	[Parameter(Mandatory=$false)][PSCredential]$Credential,
	[Parameter(Mandatory=$false)][string]$Url
)

Set-StrictMode -Version Latest

if (-not $Url)
{
    $Url = &"$PSScriptRoot\Get-HiXEnvironmentUrl.ps1"
}

$uri = "$Url/api/v2/environments/$Version/$Category"
if ($Credential)
{
	(Invoke-RestMethod -Uri $uri -Credential $Credential)
}
else
{
	(Invoke-RestMethod -Uri $uri -UseDefaultCredentials)
}