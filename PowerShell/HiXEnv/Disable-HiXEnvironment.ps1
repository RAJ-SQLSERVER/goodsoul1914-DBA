<#
.SYNOPSIS
    Disables a HiX Environment.
.DESCRIPTION
    Disables a HiX Environment in which case it is not available for users.
.PARAMETER Id
	The id of the HiX Environment to be disabled. 
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)][string[]]$Id,
	[Parameter(Mandatory = $false)][string]$Url
)
begin {
	Set-StrictMode -Version Latest

	if (-not $Url) {
		$Url = &"$PSScriptRoot\Get-HiXEnvironmentUrl.ps1"
	}
}
process {
	Set-StrictMode -Version Latest

	foreach ($i in $Id) {
		$body = $i | ConvertTo-Json

		$uri = "$Url/api/v2/administerenvironments/disable"
		Invoke-RestMethod -Uri $uri -Method Put -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
	}
}