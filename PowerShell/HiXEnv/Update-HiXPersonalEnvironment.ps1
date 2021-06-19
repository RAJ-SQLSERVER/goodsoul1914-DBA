<#
.SYNOPSIS
    Updates a HiX Personal Environment.
.DESCRIPTION
	Updates a HiX Personal Environment. 
.PARAMETER Id
    The id of the HiX Personal Environment to be updated.
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
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$Id,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$Name,
	[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][ValidateSet('DEV', 'TEST', 'ACC', 'PROD')][string]$Type,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$Version,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$ConnectionString,
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
	Set-StrictMode -Version Latest

	$body = @{
		Id = $Id;
		Name = $Name;
		Type = $Type;
		Version = $Version;
		ConnectionString = $ConnectionString;
		} | ConvertTo-Json

	$uri = "$Url/api/v2/personalenvironments"
	Invoke-RestMethod -Uri $uri -Method Put -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
}