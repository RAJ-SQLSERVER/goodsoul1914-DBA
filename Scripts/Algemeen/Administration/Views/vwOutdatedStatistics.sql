USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwOutdatedStatistics]
AS
-------------------------------------------------------------------------------
-- Alle statistieken ouder dan 1 maand met meer dan 100000 rijen waarvan
-- meer dan 2% of 100000 rijen gewijzigd zijn
-------------------------------------------------------------------------------

WITH s_cte AS
    (
        SELECT CollectionTime,
               ROW_NUMBER() OVER (PARTITION BY TableName, StatisticName ORDER BY CollectionTime) AS Run,
               TableName,
               StatisticName,
               StatisticType,
               ColumnName,
               LastUpdated,
               LAST_VALUE(LastUpdated) OVER (PARTITION BY TableName,
                                                          StatisticName
                                             ORDER BY LastUpdated
                                             RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                       ) AS LastUpdatedMax,
               Rows,
               RowsSampled,
               HistogramSteps,
               RowsUnfiltered,
               RowsModified,
               ((RowsModified * 1.0) / (Rows * 1.0)) * 100 AS RowsModifiedPct,
               'UPDATE STATISTICS ' + TableName + ' (' + StatisticName + ') WITH FULLSCAN;' AS UpdateCommand
        FROM DBA.dbo.StatisticsInfo
        WHERE DatabaseName = 'HIX_PRODUCTIE'
    )
SELECT *
FROM s_cte AS s
WHERE s.LastUpdatedMax < DATEADD(MONTH, -1, GETDATE())
      AND s.Rows > 100000
      AND (
          ((s.RowsModified * 1.0) / (s.Rows * 1.0) * 100 >= 2.0)
          OR (s.RowsModified > 100000)
      );


GO
