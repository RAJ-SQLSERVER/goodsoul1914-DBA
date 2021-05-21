SELECT a.name,
	b.name
FROM sys.sysobjects a,
	sys.syscolumns b
WHERE a.id = b.id
	AND b.name LIKE '%bsn%'
ORDER BY a.name
