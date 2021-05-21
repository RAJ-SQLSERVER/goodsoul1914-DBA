USE [DBA]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwIOLatencyByFile]
AS
SELECT CollectionTime,
       ROW_NUMBER() OVER (PARTITION BY DatabaseName, PhysicalName ORDER BY CollectionTime) AS CollectionNumber,
       DatabaseName,
       AverageReadLatencyMs,
       AverageWriteLatencyMs,
       AverageIOLatencyMs,
       FileSizeMB,
       PhysicalName,
       Type,
       IOStallReadMs,
       NumberOfReads,
       IOStallWriteMs,
       NumberOfWrites,
       IOStalls,
       TotalIO
FROM DBA.dbo.IOLatencyByFile;
GO
