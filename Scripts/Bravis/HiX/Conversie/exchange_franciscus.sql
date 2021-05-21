/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [FirstName]
      ,[LastName]
      ,[DisplayName]
      ,[TotalItemSize]
      ,[ItemCount]
      ,[PrimarySmtpAddress]
      ,[Alias]
  FROM [exchange].[dbo].[MailboxReport_Franciscus]
  WHERE [DisplayName] LIKE 'okso%'

-- TRUNCATE TABLE
[exchange].[dbo].[MailboxReport_Lievensberg]

BULK INSERT [exchange].[dbo].[MailboxReport_Franciscus] 
FROM 'D:\Exchange\MailboxReport_Franciscus.csv' 
WITH (
	FIELDTERMINATOR = '","'
)

-- Strip first "
UPDATE [exchange].[dbo].[MailboxReport_Franciscus]
SET [FirstName] = RIGHT([FirstName], LEN([FirstName]) - 1)

-- Strip last "
UPDATE [exchange].[dbo].[MailboxReport_Franciscus]
SET [Alias] = LEFT([Alias], LEN([Alias]) - 1)
WHERE LEN([Alias]) > 0

-- Update new lastname where lastname contains ,
UPDATE [exchange].[dbo].[MailboxReport_Franciscus]
SET [LastNameNew] = 
WHERE [LastName] LIKE '%,%'

-- Update wird items
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksokno',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksokno@fzr.nl',[Alias]='oksokno' WHERE [FirstName] = 'okso' AND [LastName] = 'kno'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksoplastischechirurgie',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksoplastischechirur@fzr.nl',[Alias]='oksoplastischechirur' WHERE [FirstName] = 'okso' AND [LastName] = 'plastischechirurgie'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksochirurgie',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksochirurgie@fzr.nl',[Alias]='oksochirurgie' WHERE [FirstName] = 'okso' AND [LastName] = 'chirurgie'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksoorthopedie',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksoorthopedie@fzr.nl',[Alias]='oksoorthopedie' WHERE [FirstName] = 'okso' AND [LastName] = 'orthopedie'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksopijn',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksopijn@fzr.nl',[Alias]='oksopijn' WHERE [FirstName] = 'okso' AND [LastName] = 'pijn'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksogynaecologie',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksogynaecologie@fzr.nl',[Alias]='oksogynaecologie' WHERE [FirstName] = 'okso' AND [LastName] = 'gynaecologie'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksourologie',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksourologie@fzr.nl',[Alias]='oksourologie' WHERE [FirstName] = 'okso' AND [LastName] = 'urologie'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksotrauma',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksotrauma@fzr.nl',[Alias]='oksotrauma' WHERE [FirstName] = 'okso' AND [LastName] = 'trauma'
UPDATE [exchange].[dbo].[MailboxReport_Franciscus] SET [DisplayName]='oksoneuro',[TotalItemSize]='0',[ItemCount]='0',[PrimarySmtpAddress]='oksoneuro@fzr.nl',[Alias]='oksokno' WHERE [FirstName] = 'okso' AND [LastName] = 'neuro'

-- Set item checked op 0
update [MailboxReport_Franciscus] set Gecontroleerd = 0