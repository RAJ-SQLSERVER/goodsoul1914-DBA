<#
.SYNOPSIS
    Removes a HiX Environment Personal Additional Database.
.DESCRIPTION
	Removes a HiX Environment Personal Additional Database.
.PARAMETER PersonalEnvironmentId
    The unique id of the HiX Personal Environment to which this Personal Additional Database belongs.
.PARAMETER Type
	The type of the HiX Environment Personal Additional Database to be removed.
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
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][Alias('id')][string]$PersonalEnvironmentId,
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
			PersonalEnvironmentId = $PersonalEnvironmentId;
			Type = $t;
			} | ConvertTo-Json

		$uri = "$Url/api/v2/personaladditionaldatabases"
		Invoke-RestMethod -Uri $uri -Method Delete -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
	}
}