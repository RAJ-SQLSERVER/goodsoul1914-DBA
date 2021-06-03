$hostName = "LT-RSD-01"

Get-DbaHelpIndex -SqlInstance $hostName -ExcludeDatabase master, tempdb, model, msdb -IncludeFragmentation -IncludeStats | 
    Export-Excel -Path "C:\Temp\$hostName.xlsx" -TitleBold -AutoSize -FreezeTopRow -BoldTopRow -AutoFilter -TableStyle Medium2