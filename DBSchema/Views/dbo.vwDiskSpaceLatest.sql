SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW vwDiskSpaceLatest
AS
SELECT ComputerName,
       Name,
       Label,
       Capacity,
       Free,
       PercentFree,
       BlockSize,
       FileSystem,
       DriveType,
       SizeInBytes,
       FreeInBytes,
       SizeInKB,
       FreeInKB,
       SizeInMB,
       FreeInMB,
       SizeInGB,
       FreeInGB,
       SizeInTB,
       FreeInTB,
       SizeInPB,
       FreeInPB
FROM DBA.dbo.DiskSpace
WHERE CheckDate >= DATEADD (D, -1, GETDATE ())
      AND (FreeInGB <= 5 AND PercentFree <= 10)
      AND Label <> 'Page file';
GO
