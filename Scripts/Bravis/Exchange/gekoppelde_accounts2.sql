SELECT 
	a.[NewSmtpAddress] as 'Primary', 
	a.[mailboxsize] as 'Size',
	b.[NewSmtpAddress] as 'Secondary',
	b.[mailboxsize] as 'Size'
FROM 
	[MailboxReport_Bravis_20150313] a, 
	[MailboxReport_Bravis_20150313] b
WHERE 
	(a.[leidend] ='ja'  or a.[leidend] ='Ja')
	AND a.[migratiegroep] is not null 
	AND (b.[leidend] ='nee'  or b.[leidend] ='Nee')
	AND b.[gekoppeldaccount] = a.[PrimarySmtpAddress]
	AND a.[migratiegroep] != 'FZR'
ORDER BY 
	b.[mailboxsize]  DESC



SELECT 
	a.[NewSmtpAddress] as 'Primary', 
	a.[mailboxsize] as 'Size',
	b.[NewSmtpAddress] as 'Secondary',
	b.[mailboxsize] as 'Size'
FROM 
	[MailboxReport_Bravis_20150313] a, 
	[MailboxReport_Bravis_20150313] b
WHERE 
	a.[leidend] ='ja' 
	AND a.[migratiegroep] is not null 
	AND (a.[migratiegroep] = 'FZR' OR a.[migratiegroep] is NULL)
	AND b.[leidend] ='nee' 
	AND b.[gekoppeldaccount] = a.[PrimarySmtpAddress]
ORDER BY 
	b.[mailboxsize]  DESC

SELECT 
	a.[NewSmtpAddress] as 'Primary', 
	a.[mailboxsize] as 'Size',
	b.[NewSmtpAddress] as 'Secondary',
	b.[mailboxsize] as 'Size'
FROM 
	[MailboxReport_Bravis_20150313] a, 
	[MailboxReport_Bravis_20150313] b
WHERE 
	(a.[leidend] ='ja'  or a.[leidend] ='Ja')
	AND a.[migratiegroep] is not null 
	AND (b.[leidend] ='nee'  or b.[leidend] ='Nee')
	AND b.[gekoppeldaccount] = a.[PrimarySmtpAddress]
ORDER BY 
	b.[mailboxsize]  DESC


SELECT
*
FROM 
[MailboxReport_Bravis_20150313]
WHERE
[NewSmtpAddress] LIKE '%[_]%'
OR [NewSmtpAddress] LIKE '%[_]%'