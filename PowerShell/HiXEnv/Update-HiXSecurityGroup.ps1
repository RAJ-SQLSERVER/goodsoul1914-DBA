<#
.SYNOPSIS
    Updates a HiX Environment Security Group.
.DESCRIPTION
	Updates a HiX Environment Security Group.
.PARAMETER Id
    The id of the HiX Environment Security Group to be updated.
.PARAMETER Name
    The name of the HiX Environment Security Group.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][int]$Id,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$Name,
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
		Name = $Name
		} | ConvertTo-Json

	$uri = "$Url/api/v2/securitygroups"
	Invoke-RestMethod -Uri $uri -Method Put -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
}