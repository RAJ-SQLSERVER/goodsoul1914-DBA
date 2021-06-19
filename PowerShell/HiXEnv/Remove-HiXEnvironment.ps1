<#
.SYNOPSIS
    Removes a HiX Environment.
.DESCRIPTION
	Removes a HiX Environment.
.PARAMETER Id
    The id of the HiX Environment to be removed.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)][string[]]$Id,
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

	foreach ($i in $Id)
	{
		$body = $i | ConvertTo-Json

		$uri = "$Url/api/v2/administerenvironments"
		Invoke-RestMethod -Uri $uri -Method Delete -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
	}
}