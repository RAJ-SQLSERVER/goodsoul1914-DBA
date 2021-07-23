param ($hostname, $spname)

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Generate Excel file using provided query on HiX database
$p = @{
    Show         = $false
    AutoSize     = $true
    AutoFilter   = $true
    BoldTopRow   = $true
    FreezeTopRow = $true
}

$today = $(Get-Date -format "yyyMMdd")

Write-Host "Uitvoeren $($spname) op instance $hostname"
Invoke-DbaQuery -SqlInstance $hostname -Database "DBA" -Query "EXEC dbo.$($spname)" | 
    Export-Excel -Path "C:\Temp\$($today)_$($hostname)_$($spname).xlsx" @p

# Send email to recipient with output as attachment
Write-Host "Verzenden e-mail met Excel bijlage naar TAB@bravis.nl"
Send-MailMessage -From "$($hostname)@bravis.nl" -To 'TAB@bravis.nl' -Subject "$($hostname) - $($spname) d.d. $($today)" -Body "Zie bijlage" -Attachments "C:\Temp\$($today)_$($hostname)_$($spname).xlsx" -SmtpServer 'mail.zkh.local'

# Remove generated Excel file
Write-Host "Verwijderen bestand C:\Temp\$($today)_$($hostname)_$($spname).xlsx uit C:\Temp"
Remove-Item "C:\Temp\$($today)_$($hostname)_$($spname).xlsx" -Force
