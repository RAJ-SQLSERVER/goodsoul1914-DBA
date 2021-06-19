#requires -Version 4.0
#requires -RunAsAdministrator

<#
.SYNOPSIS
    Registers the HiX Environments Service.
.DESCRIPTION
    Registers the HiX Environments Service as a Windows Service using a specific tcp/ip port 
    and ssl certifcate.
.PARAMETER Port
    Tcp/ip port used to connect to the HiX Environments Service.
.PARAMETER SslCertificateSubject
    Subject of the Ssl Certificate to be used by the connection. The certificate should exist 
    in the personal local machine certifcate store of the current user.
    
    The following PowerShell command can be used to lookup the subject:
    Get-ChildItem Cert:\LocalMachine\My -SSLServerAuthentication -DnsName *
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][int]$Port,
    [Parameter(Mandatory=$true)][string]$SslCertificateSubject
)

Set-StrictMode -Version Latest

$sslCertificates = @(Get-ChildItem Cert:\LocalMachine\My -SSLServerAuthentication -DnsName * | where {$_.Subject -eq $SslCertificateSubject})
if ($sslCertificates.Count -eq 0)
{
    Write-Error 'Ssl certificate not found'
}
elseif ($sslCertificates.Count -gt 1)
{
    Write-Error 'Multiple possible ssl certificates found'
}
else
{
    $sslCertificate = $sslCertificates[0]
}

New-Service -Name ChipSoft.HiX.Environments -BinaryPathName "$PSScriptRoot\ChipSoft.HiX.Environments.exe --server.urls https://+:$Port" -DisplayName 'ChipSoft HiX Environments'

netsh.exe http add urlacl url=https://+:$Port/ sddl=D:`(A`;`;GX`;`;`;S-1-1-0`) 

netsh.exe http add sslcert ipport=0.0.0.0:$Port certhash=$($sslCertificate.Thumbprint) appid=`{4e60d335-d5c7-4f6f-9588-4ebff4e7ccd9`}