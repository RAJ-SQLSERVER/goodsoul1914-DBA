$computers = "GACL02","GPCL02","GAHIXCOMEZ01","GAHIXCOMEZ02","GAHIXCOMEZ03","GAHIXCOMEZ04","GPHIXCOMEZ01","GPHIXCOMEZ02","GPHIXCOMEZ03","GPHIXCOMEZ04"

# To database
Invoke-Command -ComputerName $computers -ScriptBlock { Get-ChildItem -Path cert:\LocalMachine\My -Recurse -ExpiringInDays 365 } | 
    Select-Object PSComputerName, NotAfter, NotBefore, HasPrivateKey, SerialNumber, Version, Issuer, Subject | 
        Write-DbaDbTableData -SqlInstance GTSQL01 -Database DBA -Table Certificates -AutoCreateTable

# To Excel sheet
Invoke-Command -ComputerName $computers -ScriptBlock { Get-ChildItem -Path cert:\LocalMachine\My -Recurse } | 
    Select-Object PSComputerName, NotAfter, NotBefore, HasPrivateKey, SerialNumber, Version, Subject, Issuer | 
        Export-Excel -Path "c:\temp\certs.xlsx" -FreezeTopRow -BoldTopRow -AutoSize -TableStyle Medium6

