<#
.SYNOPSIS
    Adds a HiX Environment Security Group Role to a HiX Environment Security Group.
.DESCRIPTION
    Adds a HiX Environment Security Group Role to a HiX Environment Security Group.
.PARAMETER SecurityGroupId
	The id of the HiX Environment Security Group where the role is to be added. 
.PARAMETER SecurityRole
	The Active Directory name of the role to be added to the HiX Environment Security Group. This
	can be single users, but Active Directory Groups are preferable.
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][int]$SecurityGroupId,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][string[]]$SecurityRole,
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
		Invoke-RestMethod -Uri $uri -Method Post -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
	}
}