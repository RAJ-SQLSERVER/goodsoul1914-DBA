<#
.SYNOPSIS
    Removes a HiX Environment Security Group Role.
.DESCRIPTION
	Removes a HiX Environment Security Group Role.
.PARAMETER SecurityGroupId
    The id of the HiX Environment Security Group to move the role from.
.PARAMETER SecurityRole
    The role to be removed from the HiX Environment Security Group.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)][int]$SecurityGroupId,
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)][string[]]$SecurityRole,
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

	foreach ($role in $SecurityRole)
	{
		$body = @{
			SecurityGroupId = $SecurityGroupId;
			Role = $role
			} | ConvertTo-Json


		$uri = "$Url/api/v2/securityroles"
		Invoke-RestMethod -Uri $uri -Method Delete -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
	}
}