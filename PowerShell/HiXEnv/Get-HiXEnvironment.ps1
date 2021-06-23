<#
.SYNOPSIS
    Get the HiX Environments for administrative purposes.
.DESCRIPTION
    Get the HiX Environments for administrative purposes. This list unfilterd so an administrator
    can adminster all the HiX Environments. This in contrast to the list of environments which
	is available to a specific end user.

	The current user must have administrative rights for the HiX Environment Service.
	
	HiX Environments are a central store of HiX Environments which can be used by ChipSoft 
	products to get the connection details used for setting up database connections.
.PARAMETER Id
    Filter on the id of the HiX Environment. Wildcards can be used.
.PARAMETER Name
    Filter on the name of the HiX Environment. Wildcards can be used.
.PARAMETER Type
	Filter on the type of the HiX Environment. 
	Possible values are:
		* DEV  - Development
		* TEST - Test
		* ACC  - Acceptance
		* PROD - Production
.PARAMETER Version
	Filter on the version of the HiX Environment. Wildcards can be used.
.PARAMETER ConnectionString
	Filter on the ConnectionString of the HiX Environment. Wildcards can be used.
.PARAMETER Category
    Filter on the category of the HiX Environment. Wildcards can be used.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $false)][string]$Id = '*',
	[Parameter(Mandatory = $false)][string]$Name = '*',
	[Parameter(Mandatory = $false)][ValidateSet('DEV', 'TEST', 'ACC', 'PROD')][string]$Type = '*',
	[Parameter(Mandatory = $false)][string]$Version = '*',
	[Parameter(Mandatory = $false)][string]$ConnectionString = '*',
	[Parameter(Mandatory = $false)][string]$Category = '*',
	[Parameter(Mandatory = $false)][string]$Url
)

Set-StrictMode -Version Latest

if (-not $Url) {
	$Url = &"$PSScriptRoot\Get-HiXEnvironmentUrl.ps1"
}

$uri = "$Url/api/v2/administerenvironments"
(Invoke-RestMethod -Uri $uri -UseDefaultCredentials) | Where-Object { $_.Id -like $Id -and $_.Name -like $Name -and $_.Type -like $Type -and $_.Version -like $Version -and $_.ConnectionString -like $ConnectionString -and $_.Category -like $Category}