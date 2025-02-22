/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [FirstName]
      ,[LastName]
      ,[DisplayName]
      ,[TotalItemSize]
      ,[ItemCount]
      ,[PrimarySmtpAddress]
      ,[Alias]
  FROM [exchange].[dbo].[MailboxReport_Lievensberg]
  WHERE [LastName] LIKE '% %' OR [LastName] LIKE '%,%'

-- TRUNCATE TABLE
[exchange].[dbo].[MailboxReport_Lievensberg]

BULK INSERT [exchange].[dbo].[MailboxReport_Lievensberg] 
FROM 'D:\Exchange\MailboxReport_Lievensberg.csv' 
WITH (
	FIELDTERMINATOR = '","'
)

-- Strip first "
UPDATE [exchange].[dbo].[MailboxReport_Lievensberg]
SET [FirstName] = RIGHT([FirstName], LEN([FirstName]) - 1)

-- Strip last "
UPDATE [exchange].[dbo].[MailboxReport_Lievensberg]
SET [Alias] = LEFT([Alias], LEN([Alias]) - 1)
WHERE LEN([Alias]) > 0

-- Update new lastname where lastname contains ,
UPDATE [exchange].[dbo].[MailboxReport_Lievensberg]
SET [LastNameNew] = 
WHERE [LastName] LIKE '%,%'

-- Set item checked op 0
update [MailboxReport_Lievensberg] set Gecontroleerd = 0