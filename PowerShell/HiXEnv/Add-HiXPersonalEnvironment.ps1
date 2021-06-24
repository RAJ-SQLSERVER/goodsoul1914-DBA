<#
.SYNOPSIS
    Adds a HiX Personal Environment.
.DESCRIPTION
	Adds a HiX Personal Environment. A HiX Personal Environment is only available for the user 
	adding the environment and is used for advanced development or test scenarios.
.PARAMETER Name
    The name of the HiX Environment used for display to the user.
.PARAMETER Type
	The type of the HiX Environment which is used to change the behavoir of the HiX Environment.
	Possible values are:
		* DEV  - Development
		* TEST - Test
		* ACC  - Acceptance
		* PROD - Production
.PARAMETER Version
	The HiX version (e.g. 6.2) used for filtering
.PARAMETER ConnectionString
	The connection string used to connect to the HiX database. 
	Examples are:
		* Data Source=SERVER;Initial Catalog=DATABASE;User ID=chipsoftwinzis
		* Data Source=SERVER;Initial Catalog=DATABASE;Integrated Security=SSPI
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)][string]$Name,
	[Parameter(Mandatory = $true)][ValidateSet('DEV', 'TEST', 'ACC', 'PROD')][string]$Type,
	[Parameter(Mandatory = $true)][string]$Version,
	[Parameter(Mandatory = $true)][AllowEmptyString()][string]$ConnectionString,
	[Parameter(Mandatory = $false)][string]$Url
)

Set-StrictMode -Version Latest

if (-not $Url) {
	$Url = &"$PSScriptRoot\Get-HiXEnvironmentUrl.ps1"
}

$body = @{
	Name             = $Name;
	Type             = $Type;
	Version          = $Version;
	ConnectionString = $ConnectionString;
} | ConvertTo-Json

$uri = "$Url/api/v2/personalenvironments"
(Invoke-RestMethod -Uri $uri -Method Post -UseDefaultCredentials -ContentType 'application/json' -Body $body)