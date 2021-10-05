SET NOCOUNT ON;
DECLARE @LSN NVARCHAR(64);

SET @LSN = N'CHANGEME';
-- To test : 
--      SELECT TOP 1 [Current LSN] FROM fn_dblog(NULL, NULL)

DECLARE @LSN_Decimal NVARCHAR(64); -- LSN expression to use with fn_dblog, db_dump_dblog
DECLARE @LSN_Decimal2 NVARCHAR(64); -- LSN expression to use with STOPBEFOREMARK
DECLARE @tsql NVARCHAR(MAX);

DECLARE @tbl TABLE (id INT IDENTITY(1, 1), val VARCHAR(16));


-- Extract first part
SET @tsql = N'SELECT CONVERT(VARCHAR(16),CAST(0x' + SUBSTRING (@LSN, 1, 8) + N' AS INT))';
INSERT INTO @tbl
EXEC (@tsql);

SELECT @LSN_Decimal = val,
       @LSN_Decimal2 = val
FROM @tbl;
-- table variable =&gt; SQL Server always thinks it only returns 1 row.
-- deleting content
DELETE FROM @tbl;

SET @tsql = N'SELECT CONVERT(VARCHAR(16),CAST(0x' + SUBSTRING (@LSN, 10, 8) + N' AS INT))';
INSERT INTO @tbl
EXEC (@tsql);

SELECT @LSN_Decimal = @LSN_Decimal + N':' + val,
       @LSN_Decimal2 = @LSN_Decimal2 + RIGHT('0000000000' + ISNULL (val, ''), 10)/*10 digits*/
FROM @tbl;
DELETE FROM @tbl;

SET @tsql = N'SELECT CONVERT(VARCHAR(16),CAST(0x' + SUBSTRING (@LSN, 19, 4) + N' AS INT))';
INSERT INTO @tbl
EXEC (@tsql);

SELECT @LSN_Decimal = @LSN_Decimal + N':' + val,
       @LSN_Decimal2 = @LSN_Decimal2 + RIGHT('00000' + ISNULL (val, ''), 5)/*5 digits*/
FROM @tbl;
DELETE FROM @tbl;


PRINT 'LSN Decimal translation for fn_db_log      :' + @LSN_Decimal;
PRINT 'LSN Decimal expression for STOPBEFOREMARK  :' + @LSN_Decimal2;

/*
Choose :
SELECT *
FROM ::fn_dblog(NULL, @LSN_Decimal); 
 
SELECT *
FROM ::fn_dblog(@LSN_Decimal, NULL); 
*/