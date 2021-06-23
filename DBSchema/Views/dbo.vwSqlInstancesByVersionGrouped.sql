SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwSqlInstancesByVersionGrouped
AS
SELECT DISTINCT
       b.Version,
       a.SqlVersion,
       b.Release,
       b.Type,
       b.CU,
       COUNT (*) AS Total
FROM dbo.SqlInstances AS a
INNER JOIN dbo.SqlBuilds AS b
    ON (a.SqlVersion LIKE '%' + b.Version + '.%')
GROUP BY b.Version,
         a.SqlVersion,
         b.Release,
         b.Type,
         b.CU;
GO
