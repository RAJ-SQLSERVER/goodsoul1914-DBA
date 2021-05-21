USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwStatisticsInfo]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY DatabaseName, SchemaName, TableName, StatisticName ORDER BY CollectionTime) AS CollectionNumber,
       DatabaseName,
       SchemaName,
       TableName,
       StatisticID,
       StatisticName,
       StatisticType,
       IsTemporary,
       IsFiltered,
       ColumnName,
       FilterDefinition,
       LastUpdated,
       Rows,
       RowsSampled,
       HistogramSteps,
       RowsUnfiltered,
       RowsModified
FROM DBA.dbo.StatisticsInfo;        
GO
