SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwSqlInstancesByEditionGrouped
AS
SELECT SqlEdition,
       COUNT (*) AS Total
FROM dbo.SqlInstances
WHERE SqlEdition IS NOT NULL
      AND SqlEdition <> ''
GROUP BY SqlEdition;
GO
