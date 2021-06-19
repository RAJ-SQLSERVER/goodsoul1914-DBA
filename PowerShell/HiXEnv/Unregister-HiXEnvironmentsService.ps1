#requires -Version 4.0
#requires -RunAsAdministrator

<#
.SYNOPSIS
    Unregisters the HiX Environments Service.
.DESCRIPTION
    Unregisters the HiX Environments Service.
.PARAMETER Port
    Tcp/ip port used to connect to the HiX Environment Service to be unregistered.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][int]$Port
)

Set-StrictMode -Version Latest

sc.exe delete "ChipSoft.HiX.Environments"

netsh.exe http delete urlacl url=https://+:$Port/ 

netsh.exe http delete sslcert ipport=0.0.0.0:$Port 