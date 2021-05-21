USE DBATools
GO

EXEC dbo.sp_BlitzWho @ExpertMode = 1
GO

SELECT *
FROM sys.dm_resource_governor_resource_pools
GO
