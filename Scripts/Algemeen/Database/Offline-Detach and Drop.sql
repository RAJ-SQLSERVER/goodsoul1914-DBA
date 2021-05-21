CREATE DATABASE SQLAuthority;
GO

-------------------------------------------------------------------------------
-- Taking the database offline (when database is not used)
-------------------------------------------------------------------------------
ALTER DATABASE SQLAuthority 
SET OFFLINE 
WITH ROLLBACK IMMEDIATE; -- Will immediately rollback any active transactions
GO

-------------------------------------------------------------------------------
-- Taking the database online
-------------------------------------------------------------------------------
ALTER DATABASE SQLAuthority 
SET ONLINE;
GO

-------------------------------------------------------------------------------
-- Detaching the database (when moving a database to another location)
-------------------------------------------------------------------------------
EXEC master.dbo.sp_detach_db @dbname = N'SQLAuthority';
GO

-------------------------------------------------------------------------------
-- Attaching the database
-------------------------------------------------------------------------------
EXEC master.dbo.sp_attach_db @dbname = N'SQLAuthority',
                             @filename1 = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\SQLAuthority.mdf',
                             @filename2 = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\SQLAuthority_log.ldf';
GO

-------------------------------------------------------------------------------
-- Dropping the database (when no longer needed)
-------------------------------------------------------------------------------
DROP DATABASE SQLAuthority;
GO
