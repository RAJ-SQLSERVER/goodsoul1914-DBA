<#
.SYNOPSIS
    Removes a HiX Environment Additional Database.
.DESCRIPTION
	Removes a HiX Environment Additional Database.
.PARAMETER EnvironmentId
    The unique id of the HiX Environment to which this Additional Database belongs.
.PARAMETER Type
	The type of the HiX Environment Additional Database to be removed.
	Possible values are:
		* CONF    - Environment Settings
		* AUDIT   - Audit logging
		* AUDITFB - Audit logging fallback
		* LOG     - General logging
		* BLOB    - Blob file storage
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][Alias('id')][string]$EnvironmentId,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)][ValidateSet('CONF', 'AUDIT', 'AUDITFB', 'LOG', 'BLOB')][string[]]$Type,
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

	foreach ($t in $Type)
	{
		$body = @{
			EnvironmentId = $EnvironmentId;
			Type = $t;
			} | ConvertTo-Json

		$uri = "$Url/api/v2/additionaldatabases"
		Invoke-RestMethod -Uri $uri -Method Delete -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
	}
}