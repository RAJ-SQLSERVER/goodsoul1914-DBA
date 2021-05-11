Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Generate Excel file using provided query on HiX database
$p=@{
    Title = "Query missende receptregels IAB d.d. $(Get-Date)"
    TitleSize = 18
    TitleBold = $true
	Path  = "C:\Temp\IAB.xlsx"
    Show = $false
    #AutoSize = $true
    #AutoFilter = $true
    BoldTopRow = $true
    FreezeTopRow = $false
}
Invoke-DbaQuery -SqlInstance gphixsql02 -Database "HIX_PRODUCTIE" -Query "SELECT * FROM MEDICAT_RECDEEL R, MEDICAT_RECEPT re WHERE R.RECPTCODE = re.RECEPTNR AND re.SourceCode <> '' AND R.MUTGEBR = 'CHIPSOFT' AND R.MUTDAT = DATEADD(DAY, -1, CONVERT(DATE, GETDATE())) AND re.ProcessedByPharmacy = 1 AND NOT EXISTS (SELECT * FROM APOTHEEK_ISSUE I WHERE I.RecipeID = R.RECPTCODE AND R.IDENTIF = I.OriginalPrescriptionId) ORDER BY R.MUTDAT DESC;" | 
Export-Excel @p

# Send email to Selina with output as attachment
Send-MailMessage -From 'gphixsql02@bravis.nl' -To 'sa.stolk@bravis.nl' -Subject "Query missende receptregels IAB d.d. $(Get-Date)" -Body "Zie bijlage" -Attachments "C:\Temp\IAB.xlsx" -SmtpServer 'mail.zkh.local'

# Remove generated Excel file
Remove-Item "C:\Temp\IAB.xlsx" -Force
