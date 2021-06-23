<#
.SYNOPSIS
    Adds a HiX Environment Security Group.
.DESCRIPTION
    Adds a HiX Environment Security Group used to retrict the availability of HiX Environments to certain users.
.PARAMETER Name
    The name of the HiX Environment Security Group.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)][string[]]$Name,
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

	foreach ($n in $Name) {
		$body = @{
			Name = $n
		} | ConvertTo-Json

		$uri = "$Url/api/v2/securitygroups"
		(Invoke-RestMethod -Uri $uri -Method Post -UseDefaultCredentials -ContentType 'application/json' -Body $body)
	}
}