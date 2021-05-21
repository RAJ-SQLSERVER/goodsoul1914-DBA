
/******************************************************************************

sp_Blitz Pro Tips for Managing Multiple Servers Centrally
---------------------------------------------------------

The CheckID column refers to the list of sp_Blitz checks by priority. 
You can also scroll to the right in sp_Blitz results and look at the CheckID 
column to see the number of the one you want to skip.

* If you want to skip a check on all servers, all databases, then leave 
  the ServerName & DatabaseName null.
* If you want to skip a check on one server, but all the databases on it, 
  put in its ServerName, but leave DatabaseName null.
* If you want to skip a check on a particular database name, but all of your 
  servers, populate the DatabaseName, but leave the ServerName null. 
  (Like if you want to skip checks on all of your ReportServer databases.)
* If you want to skip ALL checks on a particular database, populate the 
  DatabaseName (and/or ServerName), but leave CheckID null.

https://www.brentozar.com/archive/2020/08/sp_blitz-pro-tips-for-managing-multiple-servers-centrally/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+BrentOzar-SqlServerDba+%28Brent+Ozar+Unlimited%29

******************************************************************************/

CREATE TABLE dbo.BlitzChecksToSkip (ServerName NVARCHAR(128), DatabaseName NVARCHAR(128), CheckID INT);

INSERT INTO dbo.BlitzChecksToSkip (ServerName, DatabaseName, CheckID)
VALUES ('LT-RSD-01', NULL, 1);
GO


EXEC DBATools.dbo.sp_Blitz @SkipChecksDatabase = 'DBAtools',
                           @SkipChecksSchema = 'dbo',
                           @SkipChecksTable = 'BlitzChecksToSkip';
GO


EXEC DBATools.dbo.sp_Blitz @SkipChecksServer = 'ManagementServerName',
                           @SkipChecksDatabase = 'DBAtools',
                           @SkipChecksSchema = 'dbo',
                           @SkipChecksTable = 'BlitzChecksToSkip';
GO


EXEC DBATools.dbo.sp_Blitz @SkipChecksServer = 'ManagementServerName', -- Linked server
                           @SkipChecksDatabase = 'DBAtools',
                           @SkipChecksSchema = 'dbo',
                           @SkipChecksTable = 'BlitzChecksToSkip',
                           @OutputServerName = 'ManagementServerName', -- Linked server
                           @OutputDatabaseName = 'DBAtools',
                           @OutputSchemaName = 'dbo',
                           @OutputTableName = 'BlitzResults';
GO


SELECT *
FROM DBATools.dbo.BlitzResults;
GO

