<#
.SYNOPSIS
    Get the HiX Environment Host url.
.DESCRIPTION
    Used internally to get the HiX Environment Host url which is used to contact the HiX Environment 
    Host. The url is discoverd in the following order:
        * Environment
        * Current User Registry
        * Local Machine Registry
        * Autodiscover using domain
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest

function AutodiscoverHost
{
    $domain = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
    if (-not $domain)
    {
    	$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Name
    }

    $uri = "https://hixenvironments.$domain/autodiscover/autodiscover.json"
    
    $result = Invoke-RestMethod -Uri $uri 
    
    if($result | Get-Member 'url')
    {
        $json = $result
    }
    else
    { 
        try
        {
            $json = $result.SubString($result.IndexOf('{')) | ConvertFrom-Json
        }
        catch
        {
            $json = ''
		}
    }

    if($json | Get-Member 'url')
    {
        $json.url
    }
    else
    {
        Write-Error "$uri is not in the right json format"
    }
}

$hostUrl = $env:HiXEnvironmentsHost
if (-not $hostUrl)
{
    $reg = Get-ItemProperty -Path HKCU:\ChipSoft\ZIS2000 -Name HiXEnvironmentsHost -ErrorAction Ignore
    if ($reg)
    {
        $hostUrl = $reg.HiXEnvironmentsHost
    }
}
if (-not $hostUrl)
{
    $reg = Get-ItemProperty -Path HKLM:\Software\ChipSoft\ZIS2000 -Name HiXEnvironmentsHost -ErrorAction Ignore
    if ($reg)
    {
        $hostUrl = $reg.HiXEnvironmentsHost
    }
}
if (-not $hostUrl)
{
    $hostUrl = AutodiscoverHost
}
$hostUrl
