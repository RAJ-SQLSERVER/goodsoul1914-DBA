USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwMemoryClerkUsage]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY MemoryClerkType ORDER BY CollectionTime) AS CollectionNumber,
       MemoryClerkType,
       MemoryUsageMB
FROM DBA.dbo.MemoryClerkUsage;
GO
