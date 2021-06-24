<#
.SYNOPSIS
    Adds a HiX Environment.
.DESCRIPTION
	Adds a HiX Environment. HiX Environments are a central store of HiX Environments which can be 
	used by ChipSoft products to get the connection details used for setting up database connections.

	The current user must have administrative rights for the HiX Environment Service.
.PARAMETER Id
    The unique id of the HiX Environment used for identification.
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
.PARAMETER Disabled
	Disabled HiX Environments are not available for users.
.PARAMETER ReadOnly
	Readonly HiX Environments can be used, but are read only. The preferred option is to set 
	the SQL database to read only (ALTER DATABASE [DATABASE] SET READ_ONLY WITH NO_WAIT), 
	instead of using this option.
.PARAMETER Category
	The category to which the HiX Environment belongs. This is used to filter different 
	groups of HiX Environments, like Education or DataWarehouse.
.PARAMETER SecurityGroupId
	The id of the HiX Environment Security Group. Only users belonging to this group are 
	offered this HiX Environment. See Add-HiXSecurityGroup.ps1
.PARAMETER Url
	The url of the HiX Environment host. This can be used in case the host can not be found
	the usual way.
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Id,
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Name,
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][ValidateSet('DEV', 'TEST', 'ACC', 'PROD')][string]$Type,
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Version,
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ConnectionString,
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Switch]$Disabled,
	[Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][Switch]$ReadOnly,
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Category,
	[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][int]$SecurityGroupId,
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

	$body = @{
		Id               = $Id;
		Name             = $Name;
		Type             = $Type;
		Version          = $Version;
		ConnectionString = $ConnectionString;
		Disabled         = $Disabled.IsPresent;
		ReadOnly         = $ReadOnly.IsPresent;
		Category         = $Category;
		SecurityGroupId  = $SecurityGroupId
	} | ConvertTo-Json

	$uri = "$Url/api/v2/administerenvironments"
	Invoke-RestMethod -Uri $uri -Method Post -UseDefaultCredentials -ContentType 'application/json' -Body $body | Out-Null
}