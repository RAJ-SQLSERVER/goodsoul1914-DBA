<#
.SYNOPSIS
    Get the HiX Environment Security Group Roles.
.DESCRIPTION
	Get the HiX Environment Security Group Roles.
.PARAMETER SecurityGroupId
	Filter on the SecurityGroupId
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)][Alias('id')][int[]]$SecurityGroupId,
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

	$uri = "$Url/api/v2/securityroles"
	(Invoke-RestMethod -Uri $uri -UseDefaultCredentials) | Where-Object { $SecurityGroupId -eq $null -or $_.SecurityGroupId -in $SecurityGroupId }
}