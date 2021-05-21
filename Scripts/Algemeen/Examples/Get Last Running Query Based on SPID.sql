-- Execute the following code in another window
SELECT @@SPID
GO
SELECT GETDATE(), CURRENT_TIMESTAMP


-- Change the SPIDs in the following code
-- #1
DBCC INPUTBUFFER(71)
GO

-- #2
DECLARE @sqltext VARBINARY(128);
SELECT @sqltext = sql_handle
FROM sys.sysprocesses
WHERE spid = 71;
SELECT text
FROM sys.dm_exec_sql_text(@sqltext);
GO

-- #3
DECLARE @sqltext VARBINARY(128);
SELECT @sqltext = sql_handle
FROM sys.sysprocesses
WHERE spid = 71;
SELECT TEXT
FROM ::fn_get_sql(@sqltext)
GO