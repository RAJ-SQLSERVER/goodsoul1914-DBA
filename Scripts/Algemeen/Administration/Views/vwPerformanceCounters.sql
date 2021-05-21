USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwPerformanceCounters]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY [Counter] ORDER BY CollectionTime) AS CollectionNumber,
       Counter,
       Type,
       Value
FROM DBA.dbo.PerformanceCounters;
GO
