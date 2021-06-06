function Get-GITCAuditGenericAccount {
    <#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER SqlInstance
    

    .EXAMPLE
    
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValuefromPipeline = $True)]
        [String[]]
        $SqlInstance   
    )

    begin {       
        $Out = @()
    }

    process {
        try {  
            foreach ($Instance in $SqlInstance) {
                $Rows = Invoke-DbaQuery -SqlInstance $Instance -Database master -Query "SELECT @@ServerName ServerName, a.name AS SQL_Login, b.sysadmin AS IsSysAdmin, a.is_disabled AS IsDisabled, a.is_policy_checked AS IsPolicyChecked, a.is_expiration_checked AS IsExpirationChecked, CAST(LOGINPROPERTY(a.[name], 'PasswordLastSetTime') AS DATETIME) AS [PwdLastUpdate] FROM sys.sql_logins a LEFT JOIN master..syslogins b ON a.sid = b.sid WHERE a.name NOT LIKE '##%'"
                Write-Verbose "Querying generic account information on instance $Instance."

                foreach ($Row in $Rows) {
                    $Out += $Row | Select-Object ServerName, SQL_Login, IsSysAdmin, IsDisabled, IsExpirationChecked, PwdLastUpdate
                }
            }
        }
        catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }

    end {
        $Out
    }
}

function Get-GITCAuditDbRoleMembers {
    <#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER SqlInstance
    

    .EXAMPLE

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValuefromPipeline = $True)]
        [String[]]
        $SqlInstance   
    )

    begin {       
        $Out = @()
    }

    process {
        try {  
            foreach ($Instance in $SqlInstance) {
                $Rows = Get-DbaDbRoleMember -SqlInstance $Instance -ExcludeDatabase tempdb, model
                Write-Verbose "Querying database role member information on instance $Instance."

                foreach ($Row in $Rows) {
                    $Out += $Row | Select-Object SqlInstance, Database, Role, UserName, Login, LoginType
                }
            }
        }
        catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }

    end {
        $Out
    }
}

function Get-GITCAuditServerRoleMembers {
    <#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER SqlInstance
    

    .EXAMPLE
    
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValuefromPipeline = $True)]
        [String[]]
        $SqlInstance   
    )

    begin {       
        $Out = @()
    }

    process {
        try {  
            foreach ($Instance in $SqlInstance) {
                $Rows = Get-DbaServerRoleMember -SqlInstance $Instance
                Write-Verbose "Querying server role member information on instance $Instance."

                foreach ($Row in $Rows) {
                    $Out += $Row | Select-Object SqlInstance, Role, Name
                }
            }
        }
        catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }

    end {
        $Out
    }
}

function Get-GITCAuditPriviligedActions {
    <#
    .SYNOPSIS
    

    .DESCRIPTION
    

    .PARAMETER SqlInstance
    

    .PARAMETER Days


    .EXAMPLE
    
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValuefromPipeline = $True)]
        [String[]]
        $SqlInstance,
        
        [Parameter(Mandatory = $False)]
        [int]
        $Days = 1,

        [Parameter(Mandatory = $False)]
        [String[]]
        $ExcludeServerPrincipals
    )

    begin {       
        $Out = @()

        # Create a nice comma-separated list of principals to be excluded, surrounded by single quotes
        $_ExcludeServerPrincipals = "'$($ExcludeServerPrincipals -join "','")'"
    }

    process {
        try {  
            foreach ($Instance in $SqlInstance) {
                $Query = "DECLARE @log_dir NVARCHAR(260); 
                
                SELECT @log_dir = log_file_path + N'*.sqlaudit' 
                FROM sys.server_file_audits 
                WHERE name LIKE 'GITC_%'; 
                
                SELECT * 
                FROM sys.fn_get_audit_file (@log_dir, DEFAULT, DEFAULT) 
                WHERE event_time >= DATEADD (DAY, -$Days, GETDATE ()) 
                    AND action_id NOT IN ( 'LGIS' ) 
                    AND server_principal_name NOT IN ( $_ExcludeServerPrincipals );"

                Write-Debug $Query

                Write-Verbose "Querying the audit log files. This may take a while."
                $Rows = Invoke-DbaQuery -SqlInstance $Instance -Database master -Query $Query                
                
                foreach ($Row in $Rows) {
                    $Out += $Row
                }
            }
        }
        catch {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }

    end {
        $Out
    }
}