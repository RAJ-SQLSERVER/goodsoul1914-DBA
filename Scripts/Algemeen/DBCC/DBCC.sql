-- Show help for using a specific DBCC
---------------------------------------------------------------------------------------------------
DBCC HELP('WRITEPAGE');
GO


-- Show all the undocumented DBCC commands
---------------------------------------------------------------------------------------------------
DBCC HELP('?');
GO


-- Checks the logical and physical integrity of all the objects in the specified database
---------------------------------------------------------------------------------------------------
DBCC CHECKDB(N'master') WITH data_purity, no_infomsgs;

DBCC CHECKDB(N'model') WITH data_purity, no_infomsgs;
GO


-- Checks for catalog consistency within the specified database. The database must be online.
---------------------------------------------------------------------------------------------------
DBCC CHECKCATALOG(AdventureWorks) WITH no_infomsgs;
GO


-- Displays fragmentation information for the data and indexes of the specified table or view
---------------------------------------------------------------------------------------------------
DBCC SHOWCONTIG;
GO


-- The first parameter is the database id. If you pass in 0 here, the current database is 
-- used. The second parameter is the table name in quotes. You can also pass in the object_id 
-- of the table. The third parameter is the index_id. There is an optional fourth parameter 
-- that allows us to specify the partition_id if we are only interested in a single partition.
---------------------------------------------------------------------------------------------------
DBCC IND(0, 'dbo.LargeTable', 1)
GO


-- dbcc page ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
---------------------------------------------------------------------------------------------------
DBCC TRACEON(3604);
DBCC PAGE(6, 1, 295, 0);
DBCC TRACEOFF(3604);
GO


-- sp_configure options page in master db
---------------------------------------------------------------------------------------------------
DBCC TRACEON (3604);
DBCC PAGE ('master', 1, 10, 3);
DBCC TRACEOFF(3604);
GO


-- Removes all clean buffers from the buffer pool, and columnstore objects from the columnstore 
-- object pool
---------------------------------------------------------------------------------------------------
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
GO


-- Momentopname van de huidige geheugenstatus van Microsoft SQL Server.
---------------------------------------------------------------------------------------------------
DBCC MEMORYSTATUS
GO


-- Allows you alter any byte on any page in any database, as long as you have sysadmin privileges. 
-- It also allows you to completely circumvent the buffer pool, in other words you can force page 
-- checksum failures
--
-- The purposes of DBCC WRITEPAGE are:
--
-- * To allow automated testing of DBCC CHECKDB and repair by the SQL Server team.
-- * To engineer corruptions for demos and testing.
-- * To allow for last-ditch disaster recovery by manually editing a live, corrupt database
---------------------------------------------------------------------------------------------------
DBCC WRITEPAGE
GO


-- The number of rows returned equals the number of VLFs your transaction log file has
---------------------------------------------------------------------------------------------------
DBCC LOGINFO
GO


-- Returns the oldest uncommitted and unreplicated transaction
---------------------------------------------------------------------------------------------------
DBCC OPENTRAN;
GO


-- Returns 
---------------------------------------------------------------------------------------------------
DBCC INPUTBUFFER(54);
GO


-- View statistics 
---------------------------------------------------------------------------------------------------
USE StackOverflow2010

DBCC SHOW_STATISTICS('dbo.Users', 'IX_Reputation') WITH STAT_HEADER, HISTOGRAM
GO

SELECT Reputation,
       RecordCount = COUNT(*)
FROM dbo.Users
WHERE Reputation >= 4
      AND Reputation <= 6
GROUP BY Reputation
GO


-- Clear wait statistics
---------------------------------------------------------------------------------------------------
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)
GO


-- Drop all clean buffers from the buffer pool
---------------------------------------------------------------------------------------------------
DBCC DROPCLEANBUFFERS
GO

