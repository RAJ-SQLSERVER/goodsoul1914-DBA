USE AdventureWorks;
GO

-- Show statistics for a table
SELECT OBJECT_NAME(object_id) AS [ObjectName],
       [name] AS [StatisticName],
       STATS_DATE([object_id], [stats_id]) AS [StatisticUpdateDate]
FROM sys.stats
WHERE OBJECT_NAME(object_id) = 'Product';
GO


-- List al columns of a table that have statistics
SELECT s.name AS statistics_name,
       c.name AS column_name,
       sc.stats_column_id
FROM sys.stats AS s
    INNER JOIN sys.stats_columns AS sc
        ON s.object_id = sc.object_id
           AND s.stats_id = sc.stats_id
    INNER JOIN sys.columns AS c
        ON sc.object_id = c.object_id
           AND c.column_id = sc.column_id
WHERE s.object_id = OBJECT_ID('Production.Product');
GO

/*
	_WA_Sys_00000007_75A278F5

	- The WA really just stands for Washington � of course we know where that came from!

	- 00000007 means it is the 7th column in the table (SafetyStockLevel)
	
	- 75A278F5 is a hexadecimal number of the object ID.  
	  The query below you can see that the object ID is the same as 75A278F5 
	  converted to a decimal number.
*/

SELECT id,
       name
FROM sys.sysobjects
WHERE name = 'Product';
GO


-- No statistics yet on MakeFlag, what will be the name when we execute this query?
SELECT Name,
       MakeFlag
FROM [Production].[Product]
WHERE MakeFlag = 2;
GO
-- _WA_Sys_00000004_75A278F5

