USE AdventureWorksDW2014;
GO
SELECT *
FROM dbo.FactInternetSales;

WHILE 1 = 1
SELECT * FROM dbo.FactResellerSales ORDER BY ProductKey;





USE AdventureWorks2017;
GO
WHILE (1 = 1)
BEGIN
    DBCC DROPCLEANBUFFERS;
    SELECT TOP (10000)
           a.*
    FROM master.dbo.spt_values a,
         master..spt_values b
    ORDER BY a.number DESC,
             b.number DESC;
END;
GO

