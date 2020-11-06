USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwDatabaseInfo]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY DBName ORDER BY CollectionTime) AS CollectionNumber,
       DBName,
       TableCount,
       TableColumnsCount,
       ViewCount,
       ProcedureCount,
       TriggerCount,
       FullTextCatalog,
       XmlIndexes,
       SpatialIndexes,
       DataTotalSizeMb,
       DataSpaceUtilMb,
       LogTotalSizeMb,
       LogSpaceUtilMb
FROM DBA.dbo.DatabaseInfo
GO

