/******************************************************************************
	Statistics are used by the Optimizer in the Planning Phase 
	Indexes are used by the Optimizer in the Execution Phase
******************************************************************************/

RAISERROR(N'Run statements one at a time', 20, 1) WITH LOG

USE AdventureWorks2017
GO

--DROP TABLE Person.Person2

CREATE OR ALTER PROC usp_GetTableStats
(@table_name NVARCHAR(100))
AS
BEGIN
    SELECT OBJECT_NAME(sp.object_id) AS [Table],
           sp.stats_id AS "Statistic ID",
           s.name AS "Statistic",
           sp.last_updated AS "Last Updated",
           sp.rows AS "Rows",
           sp.rows_sampled AS "Rows Sampled",
           sp.unfiltered_rows AS "Rows Unfiltered",
           sp.modification_counter AS "Modifications"
    FROM sys.stats s
        OUTER APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
    WHERE s.object_id = OBJECT_ID(@table_name);
END;
GO


SELECT *
INTO Person.Person2
FROM Person.Person;
GO

SELECT *
FROM Person.Person2

EXEC sp_helpstats @objname = N'Person.Person2', @results = 'ALL'
GO

SELECT *
FROM Person.Person2
WHERE LastName = 'Wood'

EXEC sp_helpstats @objname = N'Person.Person2', @results = 'ALL'
GO

EXEC dbo.usp_GetTableStats @table_name = N'Person.Person2';
GO

/*
 _WA_Sys_00000007_1D9B5BB6

 _Washington_System_7th Column_Hexadecimal value of object_id
*/


ALTER DATABASE AdventureWorks2017
SET AUTO_UPDATE_STATISTICS ON


SELECT * FROM Person.Person2
WHERE FirstName = 'Terri' AND MiddleName = 'Lee' AND LastName = 'Duffy'
GO

EXEC sp_helpstats @objname = N'Person.Person2', @results = 'ALL'
GO

/*
 SQL Server can only createsingle-column stats automaticalli by default !
*/


SELECT *
FROM Person.Person2;

SELECT OBJECT_ID(N'Person.Person2'); -- 496720822

SELECT COUNT(*)
FROM Person.Person2; -- 19972

SELECT ((20.0 / 100) * 19972) + 500; -- 4494.400000


EXEC dbo.usp_GetTableStats @table_name = N'Person.Person2';
GO

UPDATE Person.Person2
SET FirstName = 'Mark'
WHERE BusinessEntityID <= 4490
GO

EXEC dbo.usp_GetTableStats @table_name = N'Person.Person2';
GO

UPDATE Person.Person2
SET FirstName = 'Marc'
WHERE BusinessEntityID <= 1000
GO

EXEC dbo.usp_GetTableStats @table_name = N'Person.Person2';
GO

UPDATE Person.Person2
SET FirstName = 'Marck'
WHERE BusinessEntityID <= 2000
GO

EXEC dbo.usp_GetTableStats @table_name = N'Person.Person2';
GO

SELECT *
FROM Person.Person2
WHERE FirstName = 'Terri'; -- Stats will only update on single-column select
GO

EXEC dbo.usp_GetTableStats @table_name = N'Person.Person2';
GO




-- Reset changes
USE master
GO
RESTORE DATABASE AdventureWorks2017
FROM DISK = 'D:\SQLBackup\WINSRV1\AdventureWorks2017\FULL\WINSRV1_AdventureWorks2017_FULL_20200830_003027.bak'
WITH REPLACE,
     STATS = 10;
GO
