SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vwDiskSpeedTestsLatest]
AS
SELECT SqlInstance,
       [Database],
       FileName,
       DiskLocation,
       Reads,
       AverageReadStall,
       Writes,
       AverageWriteStall,
       [Avg Overall Latency]
FROM dbo.DiskSpeedTests
WHERE CheckDate >= DATEADD (DAY, -1, GETDATE ())
      AND (
          ReadPerformance NOT IN ( 'OK', 'Very Good' )
          OR (WritePerformance NOT IN ( 'OK', 'Very Good' ))
      );
GO
