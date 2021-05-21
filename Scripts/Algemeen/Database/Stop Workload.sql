-- Stop Workload
USE master
GO

ALTER DATABASE AdventureWorks2014

SET single_user
WITH

ROLLBACK immediate;
GO

ALTER DATABASE AdventureWorks2014

SET multi_user
WITH

ROLLBACK immediate;
GO


