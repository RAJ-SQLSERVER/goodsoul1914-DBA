USE master;
GO

-------------------------------------------------------------------------------
-- 1. create a snapshot
-------------------------------------------------------------------------------
CREATE DATABASE Credit_Snap
ON
    (
        NAME = CreditData,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\CreditData.ss'
    ),
    (
        NAME = CreditCatalog,
        FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\CreditCatalog.ss'
    ) AS SNAPSHOT OF Credit;

-------------------------------------------------------------------------------
-- 2. restore database from a snapshot
-------------------------------------------------------------------------------
DECLARE @kill VARCHAR(8000) = '';
SELECT @kill = @kill + 'kill ' + CONVERT(VARCHAR(5), spid) + ';'
FROM master..sysprocesses
WHERE dbid = DB_ID('Credit')
      AND spid > 50;

EXEC (@kill);

RESTORE DATABASE Credit FROM DATABASE_SNAPSHOT = 'Credit_Snap';

-------------------------------------------------------------------------------
-- 3. delete snapshot
-------------------------------------------------------------------------------
DROP DATABASE Credit_Snap;

-------------------------------------------------------------------------------
-- 4. testing
-------------------------------------------------------------------------------
SELECT *
FROM [Credit].[dbo].[member]
WHERE member_no = 22;

BEGIN TRAN;
UPDATE [Credit].[dbo].[member]
SET firstname = 'DRY'
WHERE firstname = 'CRRY';
ROLLBACK TRAN;

SELECT aa.*
FROM [Credit].[dbo].[member] aa
    JOIN [Credit_Snap].[dbo].[member] bb
        ON aa.member_no = bb.member_no
WHERE aa.firstname <> bb.firstname;
