-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------- HELP Tables and Data --------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
/*

This is the process, including data, for the intaller script:
	Process of loading HELP to a new Minion Reinstall installation:
	
	1. Delete any old Reindex rows from Minion.HELPObjectDetail 
	2. Delete any old Reindex rows from Minion.HELPObjects 
	3. Load all HELP data to temp tables (#HELPObjects and #HELPObjectDetails)
	4. Insert all HELPObjects
	5. Update #HELPObjects and #HELPObjectDetails with the new object IDs from Minion.HELPObjects
	6. Insert all HELPObjectDetail rows
	7. Cleanup

*/

SET NOCOUNT ON;

--&--------------------------------------------
-- 1. delete any old Reindex rows from Minion.HELPObjectDetail 
DELETE  FROM Minion.HELPObjectDetail
FROM    Minion.HELPObjects AS O
WHERE   ObjectID = O.ID
        AND O.Module = 'Reindex';
GO

--&--------------------------------------------
-- 2. delete any old Reindex rows from Minion.HELPObjects 
DELETE  Minion.HELPObjects
WHERE   Module = 'Reindex';
GO


--&--------------------------------------------
-- 3. Load all HELP data to temp tables (#HELPObjects and #HELPObjectDetails)
IF OBJECT_ID('tempdb..#HELPObjects') IS NOT NULL
BEGIN
	DROP TABLE #HELPObjects;
END

IF OBJECT_ID('tempdb..#HELPObjectDetail') IS NOT NULL
BEGIN
	DROP TABLE #HELPObjectDetail;
END

CREATE TABLE #HELPObjects
    (
      [ID] [INT] NOT NULL ,
      [Module] [VARCHAR](50) COLLATE DATABASE_DEFAULT NULL ,
      [ObjectName] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [ObjectType] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [MinionVersion] [FLOAT] NULL ,
      [GlobalPosition] [INT] NULL ,
      NewObjectID INT NULL
    );

CREATE TABLE #HELPObjectDetail
    (
      [ObjectID] [INT] NULL ,
      [DetailName] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [Position] [SMALLINT] NULL ,
      [DetailType] [sysname] COLLATE DATABASE_DEFAULT NULL ,
      [DetailHeader] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL ,
      [DetailText] [VARCHAR](MAX) COLLATE DATABASE_DEFAULT NULL ,
      [DataType] [VARCHAR](20) COLLATE DATABASE_DEFAULT NULL ,
      updated BIT NULL
    );


--------------------------------------------------------------
--------------------------------------------------------------
-------------BEGIN HELPObjects inserts------------------------
--------------------------------------------------------------
--------------------------------------------------------------
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (104, N'Reindex', N'Quick Start', N'Information', 1.3, 5);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (105, N'Reindex', N'Top 10 Features', N'Information', 1.3, 10);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (106, N'Reindex', N'Architecture Overview', N'Information', 1.3, 15);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (107, N'Reindex', N'How To: Configure settings for a single database', N'Information', 1.3, 20);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (108, N'Reindex', N'How To: Configure settings for a single table', N'Information', 1.3, 25);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (109, N'Reindex', N'How To: Reindex databases in a specific order', N'Information', 1.3, 30);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (112, N'Reindex', N'How To: Reindex tables in a specific order', N'Information', 1.3, 35);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (240, N'Reindex', N'How To: Change schedules', N'Information', 1.3, 37);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (113, N'Reindex', N'How To: Generate Reindex Statement Only', N'Information', 1.3, 40);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (114, N'Reindex', N'How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF)', N'Information', 1.3, 45);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (115, N'Reindex', N'How To: Gather index fragmentation statistics on a different schedule from the reindex routine', N'Information', 1.3, 50);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (116, N'Reindex', N'How To: Exclude databases from index maintenance', N'Information', 1.3, 55);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (117, N'Reindex', N'How To: Exclude a table from index maintenance', N'Information', 1.3, 60);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (122, N'Reindex', N'How To: Run code before or after index maintenance', N'Information', 1.3, 65);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (118, N'Reindex', N'How To: Reindex databases on different schedules', N'Information', 1.3, 70);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (123, N'Reindex', N'How To: Configure how long the reindex logs are kept', N'Information', 1.3, 75);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (124, N'Reindex', N'Overview of Tables', N'Information', 1.3, 80); 
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (111, N'Reindex', N'Minion.IndexSettingsDB', N'Table', 1.3, 85);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (96, N'Reindex', N'Minion.IndexSettingsTable', N'Table', 1.3, 90);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (103, N'Reindex', N'Minion.DBMaintRegexLookup', N'Table', 1.3, 95);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (97, N'Reindex', N'Minion.IndexPhysicalStats', N'Table', 1.3, 100);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (101, N'Reindex', N'Minion.IndexTableFrag', N'Table', 1.3, 105);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (100, N'Reindex', N'Minion.IndexMaintLog', N'Table', 1.3, 110);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (98, N'Reindex', N'Minion.IndexMaintLogDetails', N'Table', 1.3, 115);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (99, N'Reindex', N'Minion.IndexMaintSettingsServer', N'Table', 1.3, 117);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (119, N'Reindex', N'Overview of Procedures', N'Information', 1.3, 120); 
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (102, N'Reindex', N'Minion.IndexMaintMaster', N'Procedure', 1.3, 125);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (95, N'Reindex', N'Minion.IndexMaintDB', N'Procedure', 1.3, 130);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (210, N'Reindex', N'Minion.CloneSettings', N'Procedure', 1.3, 132);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (215, N'Reindex', N'Minion.DBMaintDBSizeGet', N'Procedure', 1.3, 134);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (220, N'Reindex', N'Minion.DBMaintServiceCheck', N'Procedure', 1.3, 136);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (110, N'Reindex', N'Minion.HELP', N'Procedure', 1.3, 135);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (205, N'Reindex', N'Overview of Functions', N'Information', 1.3, 137);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (200, N'Reindex', N'Minion.DBMaintSQLInfoGet', N'Function', 1.3, 138);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (230, N'Reindex', N'Overview of Views', N'Information', 1.3, 139);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (120, N'Reindex', N'Overview of Jobs', N'Information', 1.3, 140);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (130, N'Reindex', N'Revisions', N'Information', 1.3, 143);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (131, N'Reindex', N'FAQ', N'Information', 1.3, 144);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (121, N'Reindex', N'About Us', N'Information', 1.3, 145);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (125, N'Reindex', N'Troubleshoot: ONLINE was set, but all or some of the indexes are being done OFFLINE.', N'Information', 1.3, 250);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (126, N'Reindex', N'Troubleshoot: Why is a certain database not being processed?', N'Information', 1.3, 255);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (127, N'Reindex', N'Troubleshoot: Nothing happens when I run a specific database.', N'Information', 1.3, 260);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (128, N'Reindex', N'Troubleshoot: Some tables aren’t reindexing at the proper threshold.', N'Information', 1.3, 265);
GO
INSERT #HELPObjects ([ID], [Module], [ObjectName], [ObjectType], [MinionVersion], [GlobalPosition]) 
VALUES (129, N'Reindex', N'Troubleshoot: Not all indexes in the Minion.IndexMaintLogDetails table are marked "Complete".', N'Information', 1.3, 270);
GO

--------------------------------------------------------------
--------------------------------------------------------------
-------------END HELPObjects inserts--------------------------
--------------------------------------------------------------
--------------------------------------------------------------



--------------------------------------------------------------
--------------------------------------------------------------
-------------BEGIN HELPObjectDetail inserts-------------------
--------------------------------------------------------------
--------------------------------------------------------------

-------------------- 104, 2: Quick Start - Introduction --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (104, 'Introduction', 2, 'Discussion', 'Introduction', 'Minion Reindex by MidnightDBA is a stand-alone index maintenance solution that can be deployed on any number of servers, for free. Minion Reindex is comprised of SQL Server tables, stored procedures, and SQL Agent jobs. For links to downloads, tutorials and articles, see MidnightSQL.com/Minion.
		  
To install, download Minion Reindex from MidnightSQL.com/Minion and run it on your target server. For simplicity, this Quick Start guide assumes that you have installed Minion Reindex on one server, named “YourServer”.

Note: You can also use the Powershell script provided on MidnightSQL.com to install Minion Reindex on dozens or hundreds of servers at once, just as easily as you would install it on a single instance.

Once MinionReindexing.sql has been run, nothing else is required. From here on, Minion Reindex will run nightly to defragment all non-tempdb databases. The reindexing routine automatically handles databases as they are created, dropped, or renamed.', NULL);

-------------------- 104, 3: Quick Start - System Requirements --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (104, 'System Requirements', 3, 'Discussion', 'System Requirements', 'SQL Server 2005 or above. The sp_configure setting xp_cmdshell must be enabled*. Powershell 2.0 or above;  execution policy set to RemoteSigned.  

* xp_cmdshell can be turned on and off with the database PreCode / PostCode options, to help comply with security policies.', NULL);

-------------------- 104, 4: Quick Start - Customizing Schedules --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (104, 'Customizing Schedules', 4, 'Discussion', 'Change Schedules', 'Minion Reindex offers a choice of scheduling options. This quick start section covers the default method of scheduling: table based scheduling. We will cover parameter based schedules, and hybrid schedules, in the section titled “How To: Change Schedules”.
--- Table based scheduling ---
In conjunction with the “MinionReindex-AUTO” job, the Minion.ReindexSettingsServer table allows you to configure flexible Reindex scheduling scenarios. By default, Minion Reindex is installed with the following configuration: 

The MinionReindex-AUTO job runs hourly, checking the Minion.IndexMaintSettingsServer table to determine what operation should be run.

In the Minion.ReindexSettingsServer table:
  * Reindex operations are scheduled daily at 12:00pm.
  * Reorg operations are scheduled for Saturdays at 1:00am.

The following table displays the first few columns of this default scenario in Minion.IndexMaintSettingsServer: 

ID	DBType  IndexOption ReorgMode Day      BeginTime EndTime   MaxForTimeframe
--  ------  ----------- --------- -------- --------- --------  --------------- 
1	All	    ALL         ALL       Saturday 01:00:00  03:00:00  1
2	All	    ALL         REORG     Weekday  23:00:00  02:00:00  1

Let’s walk through two different schedule change scenarios:

Scenario 1: Change the time of the weekly reorg. To change the default setup to run the weekday reorgs at 7:00pm, update the row with ReorgMode=’REORG’, setting the BeginTime field to ‘19:00:00’.

Scenario 2: Gather stats during the day, and run the reorg at night using those stats.  To change the default setup in order to run a “PrepOnly” operation during the day, and “RunPrepped” at night, first update the existing “Reorg” mode with RunPrepped=1. 

  UPDATE Minion.IndexMaintSettingsServer
  SET RunPrepped = 1
  WHERE ReorgMode = ''REORG'';

Then, insert a new row to Minion.IndexMaintSettingsServer for ReindexType=’Reorg’ and PrepOnly=1:
  INSERT INTO Minion.IndexMaintSettingsServer (
     DBType, 
     IndexOption, 
     ReorgMode, 
     RunPrepped, 
     PrepOnly, 
     Day, 
     BeginTime, 
     EndTime, 
     MaxForTimeframe, 
     Debug, 
     FailJobOnError, 
     FailJobOnWarning, 
     IsActive, 
     Comment)
  VALUES (
     ''All'', 
     ''ALL'', 
     ''REORG'', 
     0, 
     1, 
     ''Weekday'', 
     ''12:00:00'', 
     ''14:00:00'', 
     1, 
     0, 
     0, 
     0, 
     1, 
     ''Weekday - Prep only during the day!''
  );

In the scenario above there are a few critical concepts to understand:
  * Execution Window: The BeginTime and EndTime settings will restrict the new PrepOnly run to between 12:00pm and 2:00pm.  Minion Reindex will ignore this entry outside of that execution window.
  * Always set the MaxForTimeframe field. This setting determines the maximum number of times an operation may be executed in the defined timeframe. In the insert statement above, MaxForTimeframe is set to 1, because we only want a single PrepOnly run during the daily window (between 12:00pm and 2:00pm).', NULL);

-------------------- 104, 5: Quick Start - Change Default Settings --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (104, 'Change Default Settings', 5, 'Discussion', 'Change Default Settings', 'Minion Reindex stores default settings for the entire instance in a single row (where DBName=’MinionDefault’) in the Minion.IndexSettingsDB table.

Warning: Do not delete the MinionDefault row from Minion.IndexSettingsDB!

To change the default settings, run an update statement on the MinionDefault row in Minion.IndexSettingsDB. For example:

UPDATE [Minion].[IndexSettingsDB]
   SET [Exclude] = 0
      ,[ReindexGroupOrder] = 0
      ,[ReindexOrder] = 0
      ,[ReorgThreshold] = 10
      ,[RebuildThreshold] = 20
      ,[FILLFACTORopt] = 85
      ,[PadIndex] = ''ON''
      ,[SortInTempDB] = ''OFF''
      ,[DataCompression] = NULL
      ,[GetRowCT] = 1
      ,[GetPostFragLevel] = 1
      ,[UpdateStatsOnDefrag] = 1
      ,[LogIndexPhysicalStats] = 0
      ,[IndexScanMode] = ''Limited''
      ,[LogProgress] = 1
      ,[LogRetDays] = 60
      ,[LogLoc] = ''Local''
      ,[MinionTriggerPath] = ''\\minioncon\c$''
      ,[IncludeUsageDetails] = 1
 WHERE [DBName] = ''MinionDefault'';

Warning: Choose your settings wisely; these settings can have a massive impact on your system. For example, if you have a 500Gb database with fill factor set to 100, changing fill factor to 85 could increase the size of your database massively on the next reindex.

For more information on these settings, see the “Minion.IndexSettingsDB” section.

For instructions on setting database-level or table-level settings, see the section titled “How To: Configure settings for a single database”.', NULL);

-------------------- 105, 2: Top 10 Features - Features --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (105, 'Features', 2, 'Discussion', 'Features', 'Minion Reindex by MidnightDBA is a stand-alone index maintenance module. Once installed, Minion Reindex automatically maintains all online databases on the SQL Server instance, and will automatically incorporate databases and indexes as they are added or removed.

Ten of the very best features of Minion Reindex are, in a nutshell:

1.	Automated operation – Run the Minion Reindex installation scripts, and it just goes.  

2.	Easy mass installation – Install Minion Reindex on hundreds of servers as easily as you can on one.

3.	Granular configuration without extra jobs – Configure extensive settings at the default, database, and/or table levels with ease.  

4.	Database and table reindex ordering – Reindex databases and tables in exactly the order you need.

5.	Flexible include and exclude – Reindex only the databases you want, using specific database names, LIKE expressions, and even regular expressions.

6.	Live Insight – See what Minion Reindex is doing every step of the way, and how much further it has to go.

7.	Maximized maintenance window – Spend the whole maintenance window on index maintenance, not on gathering fragmentation stats.

8.	Extensive, useful logging – Use the Minion Reindex log for estimating the end of the current reindexing run, troubleshooting, planning, and reporting.

9.	Built in manual runs – Choose to only print reindex statements, and run them individually as needed.

10.	Integrated help –Get help on any Minion Reindex object without leaving Management Studio.

For more information on these, additional features and settings, and How To topics, see the sections “How To” Topics, and Moving Parts. For links to downloads, tutorials and articles, see MidnightSQL.com/Minion.', NULL);

-------------------- 106, 2: Architecture Overview - Introduction --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (106, 'Introduction', 2, 'Discussion', 'Introduction', 'Minion Reindex is made up of SQL Server stored procedures, tables, and jobs. There is an optional Powershell script for installation. The tables store configuration and log information; stored procedures perform reindex operations; and the jobs execute those index operations on a schedule.

Note: Minion is installed in the master database by default. You certainly can install Minion in another database (like a DBAdmin database), but when you do, you must also change the database that the jobs point to. ', NULL);

-------------------- 106, 3: Architecture Overview - Configuration Settings Hierarchy --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (106, 'Configuration Settings Hierarchy', 3, 'Discussion', 'Configuration Settings Hierarchy', 'As much as possible, configuration for reindex is stored in tables: Minion.IndexSettingsDB and Minion.IndexSettingsTable. A default row in Minion.IndexSettingsDB (DBName=’MinionDefault’) provides settings for any database that doesn’t have its own specific settings.  This is a hierarchy of granularity, where more specific configuration levels completely override the less specific levels. That is: 

  * Insert a row for a specific database into Minion.IndexSettingsDB, and that row will override ALL of the default settings for that database. 

  * Insert a row for a specific table in Minion.IndexSettingsTable, and that row will override ALL of the default (or, if available, database-specific) settings for that table.

Note a value left at NULL in one of these tables means that Minion will use the setting that the SQL Server instance itself uses.', NULL);

-------------------- 106, 4: Architecture Overview - Run Time Configuration --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (106, 'Run Time Configuration', 4, 'Discussion', 'Run Time Configuration', 'The main Minion Reindex stored procedure – Minion.IndexMaintMaster – takes a number of parameters that are specific to the current maintenance run. For example: 

  * Use @IndexOption to run index maintenance on only tables marked for ONLINE index maintenance. 

  * Use @PrepOnly to only gather index fragmentation stats. These are saved to a table, so that later you can run Minion.IndexMaintMaster using @RunPrepped, and the procedure will used the saved fragmentation stats (instead of gathering them anew).

  * Use @Include to run index maintenance on a specific list of databases, or databases that match a LIKE expression. Alternately, set @Include=’All’ or @Include=NULL to run maintenance on all databases.', NULL);

-------------------- 106, 5: Architecture Overview - Logging --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (106, 'Logging', 5, 'Discussion', 'Logging', 'As a Minion Reindex routine runs, it keeps logs of all activity in two tables: 

  * Minion.IndexMaintLog – a log of activity at the database level.

  * Minion.IndexMaintLogDetail – a log of activity at the index level.

The Status column for the current run is updated continually in each of these tables. This way, status information (Live Insight) is available to you while index maintenance is still running, and historical data is available after the fact for help in planning future operations, reporting, troubleshooting, and more.', NULL);

-------------------- 107, 2: How To: Configure settings for a single database - Configure settings for a single database --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (107, 'Configure settings for a single database', 2, 'Discussion', 'Configure settings for a single database', 'Default settings for the whole system are stored in the Minion.IndexSettingsDB table. To specify settings for a specific database that override those defaults (for that database), insert a row for that database to the Minion.IndexSettingsDB table.', NULL);

-------------------- 107, 3: How To: Configure settings for a single database - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (107, 'Example', 3, 'Example', 'Example', 'INSERT	INTO [Minion].[IndexSettingsDB]
		( DBName ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [SortInTempDB] ,
		  [DataCompression] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [LogLoc] ,
		  [MinionTriggerPath] ,
		  [IncludeUsageDetails] 
		)
VALUES	( ''YourDatabase'' ,	--	DBName ,
		  0 ,		--	Exclude ,
		  0 ,		--	ReindexGroupOrder ,
		  0 ,		--	ReindexOrder ,
		  10 ,		--	ReorgThreshold ,
		  20 ,		--	RebuildThreshold ,
		  80 ,		--	FILLFACTORopt ,
		  ''ON'' ,		--	PadIndex ,
		  ''OFF'' ,		--	SortInTempDB ,
		  NULL ,		--	DataCompression ,
		  1 ,		--	GetRowCT ,
		  1 ,		--	GetPostFragLevel ,
		  1 ,		--	UpdateStatsOnDefrag ,
		  0 ,		--	LogIndexPhysicalStats ,
		  ''Limited'' ,	--	IndexScanMode ,
		  1 ,		--	LogProgress ,
		  60 ,		--	LogRetDays ,
		  ''Local'' ,	--	LogLoc ,
		  ''\\minioncon\c$'' ,	--	MinionTriggerPath ,
		  1		--	IncludeUsageDetails 
		);', NULL);

-------------------- 108, 2: How To: Configure settings for a single table - Configure settings for a single table --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (108, 'Configure settings for a single table', 2, 'Discussion', 'Configure settings for a single table', 'Default settings are stored in the Minion.IndexSettingsDB table. To specify settings for a specific table that override those defaults (for that table), insert a row for that table to the Minion.IndexSettingsTable table.', NULL);

-------------------- 108, 3: How To: Configure settings for a single table - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (108, 'Example', 3, 'Example', 'Example', 'INSERT	INTO [Minion].[IndexSettingsTable]
		( [DBName] ,
		  [SchemaName] ,
		  [TableName] ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [ONLINEopt] ,
		  [SortInTempDB] ,
		  [DataCompression] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [IncludeUsageDetails]

		)
VALUES	( ''YourDatabase'' , -- DBName
	  ''dbo'' ,		-- SchemaName
	  ''YourTable'' ,	-- TableName
	  0 ,		-- Exclude
	  0 ,		-- ReindexGroupOrder
	  0 ,		-- ReindexOrder
	  10 ,		-- ReorgThreshold
	  20 ,		-- RebuildThreshold
	  80 ,		-- FILLFACTORopt
	  ''ON'' ,		-- PadIndex
	  NULL ,		-- ONLINEopt
	  NULL ,		-- SortInTempDB
	  NULL ,		-- DataCompression
	  1 ,		-- GetRowCT
	  1 ,		-- GetPostFragLevel
	  1 ,		-- UpdateStatsOnDefrag
	  0 ,		-- LogIndexPhysicalStats
	  ''Limited'' ,	-- IndexScanMode
	  1 ,		-- LogProgress
	  60 ,		-- LogRetDays
	  1		-- IncludeUsageDetails
 	);
', NULL);

-------------------- 109, 2: How To: Reindex databases in a specific order - Reindex databases in a specific order --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (109, 'Reindex databases in a specific order', 2, 'Discussion', 'Reindex databases in a specific order', 'You can choose the order in which databases will be maintained. For example, let’s say that you want your databases to be indexed in this order: 
1.	[YourDatabase] (it’s the most important database on your system)
2.	[Semi]
3.	[Lame]
4.	[Unused]

In this case, we would insert a row into the Minion.IndexSettingsDB for each one of the databases, specifying either ReindexGroupOrder, ReindexOrder, or both, as needed. 

NOTE: For ReindexGroupOrder and ReindexOrder, higher numbers have a greater “weight” - they have a higher priority - and will be indexed earlier than lower numbers. Note also that these columns are TINYINT, so weighted values must fall between 0 and 255.

NOTE: When you insert a row for a database, the settings in that row override all of the default index maintenance settings for that database. So, inserting a row for [YourDatabase] means that ONLY index settings from that row will be used for [YourDatabase]; none of the default settings will apply to [YourDatabase].

NOTE: Any databases that rely on the default system-wide settings (represented by the row where DBName=’MinionDefault’) will be indexed according to the values in the MinionDefault columns ReindexGroupOrder and ReindexOrder. By default, these are both 0 (lowest priority), and so non-specified databases would be maintained last. ', NULL);

-------------------- 109, 10: How To: Reindex databases in a specific order - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (109, 'Example', 10, 'Example', 'Example', 'Because we have so few databases in this example, the simplest method is to assign the heaviest “weight” to YourDatabase, and lesser weights to the other databases, in decreasing order. In our example, we would insert four rows: 

-- Insert IndexSettingsDB row for [YourDatabase], ReindexOrder=255 (first)
INSERT	INTO [Minion].[IndexSettingsDB]
		( DBName ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [SortInTempDB] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [LogLoc] ,
		  [MinionTriggerPath] ,
		  [IncludeUsageDetails] 
		)
VALUES	( ''YourDatabase'' ,	--	DBName ,
		  0 ,		--	Exclude ,
		  0 ,		--	ReindexGroupOrder ,
		  255 ,		--	ReindexOrder ,
		  10 ,		--	ReorgThreshold ,
		  20 ,		--	RebuildThreshold ,
		  80 ,		--	FILLFACTORopt ,
		  ''ON'' ,		--	PadIndex ,
		  ''OFF'' ,		--	SortInTempDB ,
		  1 ,		--	GetRowCT ,
		  1 ,		--	GetPostFragLevel ,
		  1 ,		--	UpdateStatsOnDefrag ,
		  0 ,		--	LogIndexPhysicalStats ,
		  ''Limited'' ,	--	IndexScanMode ,
		  1 ,		--	LogProgress ,
		  60 ,		--	LogRetDays ,
		  ''Local'' ,	--	LogLoc ,
		  ''\\minioncon\c$'' ,	--	MinionTriggerPath ,
		  1		--	IncludeUsageDetails 
		);

-- Insert IndexSettingsDB row for “Semi”, ReindexOrder=150 (after [YourDatabase])
INSERT	INTO [Minion].[IndexSettingsDB]
		( DBName ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [SortInTempDB] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [LogLoc] ,
		  [MinionTriggerPath] ,
		  [IncludeUsageDetails] 
		)
VALUES	( ''Semi'' ,	--	DBName ,
		  0 ,		--	Exclude ,
		  0 ,		--	ReindexGroupOrder ,
		  150 ,		--	ReindexOrder ,
		  10 ,		--	ReorgThreshold ,
		  20 ,		--	RebuildThreshold ,
		  80 ,		--	FILLFACTORopt ,
		  ''ON'' ,		--	PadIndex ,
		  ''OFF'' ,		--	SortInTempDB ,
		  1 ,		--	GetRowCT ,
		  1 ,		--	GetPostFragLevel ,
		  1 ,		--	UpdateStatsOnDefrag ,
		  0 ,		--	LogIndexPhysicalStats ,
		  ''Limited'' ,	--	IndexScanMode ,
		  1 ,		--	LogProgress ,
		  60 ,		--	LogRetDays ,
		  ''Local'' ,	--	LogLoc ,
		  ''\\minioncon\c$'' ,	--	MinionTriggerPath ,
		  1		--	IncludeUsageDetails 
		);

-- Insert IndexSettingsDB row for “Lame”, ReindexOrder=100 (after “Semi”)
INSERT	INTO [Minion].[IndexSettingsDB]
		( DBName ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [SortInTempDB] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [LogLoc] ,
		  [MinionTriggerPath] ,
		  [IncludeUsageDetails] 
		)
VALUES	( ''Lame'' ,	--	DBName ,
		  0 ,		--	Exclude ,
		  0 ,		--	ReindexGroupOrder ,
		  100 ,		--	ReindexOrder ,
		  10 ,		--	ReorgThreshold ,
		  20 ,		--	RebuildThreshold ,
		  80 ,		--	FILLFACTORopt ,
		  ''ON'' ,		--	PadIndex ,
		  ''OFF'' ,		--	SortInTempDB ,
		  1 ,		--	GetRowCT ,
		  1 ,		--	GetPostFragLevel ,
		  1 ,		--	UpdateStatsOnDefrag ,
		  0 ,		--	LogIndexPhysicalStats ,
		  ''Limited'' ,	--	IndexScanMode ,
		  1 ,		--	LogProgress ,
		  60 ,		--	LogRetDays ,
		  ''Local'' ,	--	LogLoc ,
		  ''\\minioncon\c$'' ,	--	MinionTriggerPath ,
		  1		--	IncludeUsageDetails 
		);

-- Insert IndexSettingsDB row for “Unused”, ReindexOrder=50 (after [Lame])
INSERT	INTO [Minion].[IndexSettingsDB]
		( DBName ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [SortInTempDB] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [LogLoc] ,
		  [MinionTriggerPath] ,
		  [IncludeUsageDetails] 
		)
VALUES	( ''Unused'' ,	--	DBName ,
		  0 ,		--	Exclude ,
		  0 ,		--	ReindexGroupOrder ,
		  50 ,		--	ReindexOrder ,
		  10 ,		--	ReorgThreshold ,
		  20 ,		--	RebuildThreshold ,
		  80 ,		--	FILLFACTORopt ,
		  ''ON'' ,		--	PadIndex ,
		  ''OFF'' ,		--	SortInTempDB ,
		  1 ,		--	GetRowCT ,
		  1 ,		--	GetPostFragLevel ,
		  1 ,		--	UpdateStatsOnDefrag ,
		  0 ,		--	LogIndexPhysicalStats ,
		  ''Limited'' ,	--	IndexScanMode ,
		  1 ,		--	LogProgress ,
		  60 ,		--	LogRetDays ,
		  ''Local'' ,	--	LogLoc ,
		  ''\\minioncon\c$'' ,	--	MinionTriggerPath ,
		  1		--	IncludeUsageDetails 
		);
', NULL);

-------------------- 112, 2: How To: Reindex tables in a specific order - Reindex tables in a specific order --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (112, 'Reindex tables in a specific order', 2, 'Discussion', 'Reindex tables in a specific order', 'You can choose the order in which tables will be maintained. For example, let’s say that you want two tables in [YourDatabase] to be indexed before all other tables in that database, in this order: 
1.	dbo.[Best] (it’s the most important or most badly fragmented table)
2.	dbo.[Okay]
3.	other tables

In this case, we would insert a row into the Minion.IndexSettingsTable for each one of the tables, specifying either ReindexGroupOrder, ReindexOrder, or both, as needed. 

NOTE: For ReindexGroupOrder and ReindexOrder, higher numbers have a greater “weight” - they have a higher priority - and will be indexed earlier than lower numbers. Note also that these columns are TINYINT, so weighted values must fall between 0 and 255.

NOTE: When you insert a row for a table, the settings in that row override all of the default index maintenance settings for that table. So, inserting a row for [YourDatabase].dbo.[Best] means that ONLY those specified index settings will be used for that table; no settings defined in Minion.IndexSettingsDB will apply to those specific tables.

NOTE: Any non-specified tables will have a ReindexGroupOrder of 0, and a ReindexOrder of 0, by default. (Order settings at the database level have no effect on table-level ordering.)', NULL);

-------------------- 112, 10: How To: Reindex tables in a specific order - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (112, 'Example', 10, 'Example', 'Example', 'Because we have so few tables in this example, the simplest method is to assign the heaviest “weight” to dbo.[Best], and lesser weights to dbo.[Okay]. In our example, we would insert two rows: 

-- Insert IndexSettingsDB row for dbo.[Best], ReindexOrder=255 (first)
INSERT	INTO [Minion].[IndexSettingsTable]
		( [DBName] ,
		  [SchemaName] ,
		  [TableName] ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [IncludeUsageDetails]
		)
VALUES	( ''YourDatabase'' , -- DBName
		  ''dbo'' ,		-- SchemaName
		  ''Best'' ,	-- TableName
		  0 ,		-- Exclude
		  0 ,		-- ReindexGroupOrder
		  255 ,		-- ReindexOrder
		  10 ,		-- ReorgThreshold
		  20 ,		-- RebuildThreshold
		  80 ,		-- FILLFACTORopt
		  ''ON'' ,		-- PadIndex
		  1 ,		-- GetRowCT
		  1 ,		-- GetPostFragLevel
		  1 ,		-- UpdateStatsOnDefrag
		  0 ,		-- LogIndexPhysicalStats
		  ''Limited'' ,	-- IndexScanMode
		  1 ,		-- LogProgress
		  60 ,		-- LogRetDays
		  1		-- IncludeUsageDetails
 		);

-- Insert IndexSettingsDB row for dbo.[Okay], ReindexOrder=200 (after [Best])
INSERT	INTO [Minion].[IndexSettingsTable]
		( [DBName] ,
		  [SchemaName] ,
		  [TableName] ,
		  [Exclude] ,
		  [ReindexGroupOrder] ,
		  [ReindexOrder] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [IncludeUsageDetails]

		)
VALUES	( ''YourDatabase'' , -- DBName
		  ''dbo'' ,		-- SchemaName
		  ''Okay'' ,	-- TableName
		  0 ,		-- Exclude
		  0 ,		-- ReindexGroupOrder
		  200 ,		-- ReindexOrder
		  10 ,		-- ReorgThreshold
		  20 ,		-- RebuildThreshold
		  80 ,		-- FILLFACTORopt
		  ''ON'' ,		-- PadIndex
		  1 ,		-- GetRowCT
		  1 ,		-- GetPostFragLevel
		  1 ,		-- UpdateStatsOnDefrag
		  0 ,		-- LogIndexPhysicalStats
		  ''Limited'' ,	-- IndexScanMode
		  1 ,		-- LogProgress
		  60 ,		-- LogRetDays
		  1		-- IncludeUsageDetails
 		);', NULL);

-------------------- 112, 20: How To: Reindex tables in a specific order - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (112, 'Example', 20, 'Example', 'Example', 'For a more complex ordering scheme, we could divide tables up into groups, and then order the reindexing both by group, and within each group. The pseudocode for this example might be:
  * Insert rows for tables dbo.One, dbo.Two, dbo.Three, all with ReindexGroupOrder = 200
     o	Row dbo.One: ReindexOrder = 255
     o	Row dbo.Two: ReindexOrder = 225
     o	Row dbo.Three: ReindexOrder = 150
  * Insert rows for tables dbo.Dog, dbo.Cat, dbo.Horse, all with ReindexGroupOrder = 100
     o	Row dbo.Dog: ReindexOrder = 255
     o	Row dbo.Cat: ReindexOrder = 215
     o	Row dbo.Horse: ReindexOrder = 175
  * Insert rows for tables dbo.Up, dbo.Down, all with ReindexGroupOrder = 50
     o	Row dbo.Up: ReindexOrder = 200
     o	Row dbo.Down: ReindexOrder = 100

The resulting index maintenance order would be as follows:
     1.	dbo.One
     2.	dbo.Two
     3.	dbo.Three
     4.	dbo.Dog
     5.	dbo.Cat
     6.	dbo.Horse
     7.	dbo.Up
     8.	dbo.Down', NULL);

-------------------- 240, 5: How To: Change schedules - Introduction --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (240, 'Discussion', 5, 'Discussion', 'Introduction', 'Minion Reindex offers you a choice of scheduling options: 
  * You can use the Minion.IndexMaintSettingsServer table to configure flexible scheduling scenarios; 
  * Or, you can use the traditional approach of one job per index maintenance schedule; 
  * Or, you can use a hybrid approach that employs a bit of both options.', NULL);

-------------------- 240, 10: How To: Change schedules - Table based scheduling --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (240, 'Discussion', 10, 'Discussion', 'Table based scheduling', 'When Minion Reindex is installed, it uses a single job (MinionReindex-AUTO) to run the stored procedure Minion.IndexMaintMaster with no parameters, every hour.  When the Minion.IndexMaintMaster procedure runs without parameters, it uses the Minion.IndexMaintSettingsServer table (among others) to determine its runtime parameters – including the schedule of operations. This is how MR operates by default, to allow for the most flexible scheduling with as few jobs as possible.

This document explains table based scheduling in the Quick Start section “Table based scheduling”.', NULL);

-------------------- 240, 15: How To: Change schedules - Parameter based scheduling (traditional approach) --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (240, 'Discussion', 15, 'Discussion', 'Parameter based scheduling (traditional approach)', 'Other SQL Server maintenance solutions traditionally use one job per schedule. To use the traditional approach of one job per schedule: 
  1. Disable or delete the MinionReindex-Auto job. 
  2. Configure new jobs for each index maintenance schedule scenario you need. 

Note: We highly recommend always using the Minion.IndexMaintMaster stored procedure to run index maintenance operations. While it is possible to use the procedure Minion.Reindex to perform operations, doing so will bypass much of the configuration and logging benefits that Minion Reindex was designed to provide.

Run Minion.IndexMaintMaster with parameters: The procedure takes a number of parameters that are specific to the current maintenance run.  (For full documentation of Minion.IndexMaintMaster parameters, see the “Minion.IndexMaintMaster” section.)

To configure traditional, one-job-per-schedule operations, you might configure two new jobs: 
  * MinionReindex-Reorg, to run reorgs for each database nightly at 9pm. 
  * MinionReindex-Rebuild, to run rebuilds all databases weekly at 10pm. ', NULL);

-------------------- 240, 20: How To: Change schedules - Hybrid scheduling --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (240, 'Discussion', 20, 'Discussion', 'Hybrid scheduling', 'It is possible to use both methods – table based scheduling, and traditional scheduling – by one job that runs Minion.IndexMaintMaster with no parameters, and one or more jobs that run Minion.IndexMaintMaster with parameters. 

We recommend against this, as hybrid scheduling has little advantage over either method, and increases the complexity of your scenario. However, it may be that there are as yet unforeseen situations where hybrid scheduling might be very useful.', NULL);


-------------------- 113, 2: How To: Generate Reindex Statement Only - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (113, 'Discussion', 2, 'Discussion', 'Generate Reindex Statement Only', 'Sometimes it is useful to generate index maintenance statements and run them by hand, individually or in small groups. To generate reindex statements without running the statements, run the procedure Minion.IndexMaintMaster with the parameter @StmtOnly set to 1. ', NULL);

-------------------- 113, 10: How To: Generate Reindex Statement Only - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (113, 'Example', 10, 'Example', 'Example', 'The following code will generate index statements for all tables in the [YourDatabase] database with the ONLINEopt set to “ONLINE” (that is, all tables that are configured to be maintained in online operations only). 
EXEC [Minion].[IndexMaintMaster] 
	@IndexOption = ''ONLINE'',
	@ReorgMode = ''All'',
	@RunPrepped = 0, 
	@PrepOnly = 0,
	@StmtOnly = 1,
	@Include = ''YourDatabase'', 
	@Exclude = NULL, 
	@LogProgress = 1;', NULL);

-------------------- 114, 2: How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF) - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (114, 'Discussion', 2, 'Discussion', 'Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF)', 'You can choose the set of indexes to maintain at a time. One of the filters available is to choose to maintain only the indexes that can be run reorganized ONLINE. 

Note: The ONLINE=ON option is set in either the Minion.IndexSettingsDB table, or the Minion.IndexSettingsTable table. Alter existing rows, or insert new rows, to set which databases or tables should have the ONLINEopt set to ON.  Any index that is not marked for ONLINE=ON is, by default, an OFFLINE index (whether it is marked for ONLINEopt=OFF or ONLINEopt=NULL).

Note: ONLINE index operations may not be possible for certain editions of SQL Server, and only for indexes that are eligible for ONLINE index operations. 

To reindex only indexes marked for ONLINE=ON, run the procedure Minion.IndexMaintMaster with the parameter @IndexOption set to ‘ONLINE’. ', NULL);

-------------------- 114, 10: How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF) - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (114, 'Example', 10, 'Example', 'Example', 'For example, to reindex only the ONLINE=ON indexes for ALL databases on the instance, use the following call:
EXEC [Minion].[IndexMaintMaster] 
	@IndexOption = ''ONLINE'',
	@ReorgMode = ''All'',
	@RunPrepped = 0, 
	@PrepOnly = 0,
	@StmtOnly = 0,
	@Include = NULL, 
	@Exclude = NULL, 
	@LogProgress = 1;', NULL);

-------------------- 114, 15: How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF) - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (114, 'Example', 15, 'Example', 'Example', 'To reindex the only the ONLINE=ON indexes for a single database – [YourDatabase] – use the following call:
EXEC [Minion].[IndexMaintMaster] 
	@IndexOption = ''ONLINE'',
	@ReorgMode = ''All'',
	@RunPrepped = 0, 
	@PrepOnly = 0,
	@StmtOnly = 0,
	@Include = ''YourDatabase'', 
	@Exclude = NULL, 
	@LogProgress = 1;', NULL);

-------------------- 114, 20: How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF) - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (114, 'Example', 20, 'Example', 'Example', 'To reindex the only OFFLINE indexes (again, any index which does not have ONLINEopt=ON) for a single database – [YourDatabase] – use the following call:
EXEC [Minion].[IndexMaintMaster] 
	@IndexOption = ''OFFLINE'',
	@ReorgMode = ''All'',
	@RunPrepped = 0, 
	@PrepOnly = 0,
	@StmtOnly = 0,
	@Include = ''YourDatabase'', 
	@Exclude = NULL, 
	@LogProgress = 1;', NULL);

-------------------- 115, 2: How To: Gather index fragmentation statistics on a different schedule from the reindex routine - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (115, 'Discussion', 2, 'Discussion', 'Gather index fragmentation statistics on a different schedule from the reindex routine', 'Maintenance windows are never the wide open space we’d like them to be. So, we made sure you have the option to maximize it: you can schedule the gathering of fragmentation stats at a different time than your reindexing itself.  This way, you can use your entire maintenance window for processing indexes instead of finding out the fragmentation levels, which can take a very long time.
Let’s take the example of ReallyBigDB:
1.	Exclude ReallyBigDB from the job MinionReindexDBs-All-All (using @Exclude=’ReallyBigDB’).
2.	Create the job MinionReindexDBs-ReallyBigDB-FragStats, to run sometime before the reindex job. For the job step, run Minion.IndexMaintMaster with @Include=’ReallyBigDB’,  @PrepOnly=1, @RunPrepped=0, and other options as appropriate.
3.	Create the job MinionReindexDBs-ReallyBigDB-All. For the job step, run Minion.IndexMaintMaster with @Include=’ReallyBigDB’,  @PrepOnly=0, @RunPrepped=1  (which tells the SP to use the stats stored by the previous @PrepOnly=1 run), and other options as appropriate.

Note: There can only be one prep per database at a time.  When you run @PrepOnly  = 1, it enters the data into the table Minion.IndexTableFrag, and deletes any previous preparation runs for the database in question.  So, while you can have as many databases as you like prepped in this table, each database can only have a single prep run.  Even if the previous ones weren’t deleted, the reindex SP only looks at the last one.', NULL);

-------------------- 115, 10: How To: Gather index fragmentation statistics on a different schedule from the reindex routine - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (115, 'Example', 10, 'Example', 'Example', 'The following code will gather the fragmentation stats for ReallyBigDB:
EXEC [Minion].[IndexMaintMaster] 
	@IndexOption = ''All'',
	@ReorgMode = ''All'',
	@RunPrepped = 0, 
	@PrepOnly = 1,
	@StmtOnly = 0,
	@Include = ''ReallyBigDB'', 
	@Exclude = NULL, 
	@LogProgress = 1;

The following execution will reindex the [ReallyBigDB] database, using the fragmentation stats stored by the previous @PrepOnly=1 run (instead of gathering statistics at the same time):
EXEC [Minion].[IndexMaintMaster] 
	@IndexOption = ''All'',
	@ReorgMode = ''All'',
	@RunPrepped = 0, 
	@PrepOnly = 0,
	@StmtOnly = 1,
	@Include = ''ReallyBigDB'', 
	@Exclude = NULL, 
	@LogProgress = 1;
', NULL);

-------------------- 116, 2: How To: Exclude databases from index maintenance - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (116, 'Discussion', 2, 'Discussion', 'Exclude databases from index maintenance', 'You can exclude a database from all index maintenance in any of three ways:
  * Database level settings: In the Minion.IndexSettingsDB table, insert or update the row for that database and set the Exclude column = 1. 
  * Run time parameter: In the appropriate reindex job(s), use the @Exclude parameter of the Minion.IndexMaintMaster procedure. This parameter accepts a column-delimited list of database names, and/or LIKE expressions. (E.g., @Exclude = ‘DB1, DB3, Archive%’.)
  * Regex exclusion (advanced): In the Minion.DBMaintRegexLookup table, insert a row with Action=’Exclude’ and the appropriate regular expression to encompass the proper set of database names.

Database level settings: To exclude [YourDatabase] from the Minion.IndexSettingsDB table, update the existing row, or insert a row:
INSERT INTO [Minion].[IndexSettingsDB]
           ( DBName
           , Exclude
           )
     VALUES
           (''YourDatabase''	-- DBName
           , 1		-- Exclude
           );

Run time parameter: To exclude [YourDatabase] from just one job running Minion.IndexMaintMaster, set the @Exclude parameter = ‘YourDatabase’.  

If you wanted to exclude all databases that begin with the string “Archive”, set @Exclude to “Archive%”.

Regex exclusion: This advanced option is controlled by regular expressions in a table, to exclude databases. This is most commonly used in rolling database scenarios, where you have archive or test databases with rolling names. 

NOTE: The use of the regular expressions exclude feature is not supported in SQL Server 2005.', NULL);

-------------------- 116, 10: How To: Exclude databases from index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (116, 'Example', 10, 'Example', 'Example', 'For example, to exclude all databases beginning with the word “Archive”, and ending in a number (e.g. Archive2, Archive3, Archive201410), insert the following row:
INSERT	INTO [Minion].[DBMaintRegexLookup]
	 ( [Action]
	  , MaintType
	  , Regex )
VALUES	
( ''EXCLUDE'' 	-- Action. EXCLUDE or INCLUDE
	   , ''ALL''		-- MaintType. ALL or REINDEX
	   , ''^Archive\d'' );	-- Regex expression', NULL);

-------------------- 117, 2: How To: Exclude a table from index maintenance - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (117, 'Discussion', 2, 'Discussion', 'Exclude a table from index maintenance', 'To exclude a single table from all index maintenance, insert a row to the Minion.IndexSettingsTable table and set the Exclude column = 1.', NULL);

-------------------- 117, 10: How To: Exclude a table from index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (117, 'Example', 10, 'Example', 'Example', 'INSERT	INTO [Minion].[IndexSettingsTable]
		( DBName ,
		  SchemaName ,
		  TableName ,
		  Exclude           
		)
     VALUES
	( ''YourDatabase'' -- DBName
	  , ''dbo''		-- SchemaName
	  , ''BigTable''	-- TableName
	  , 1		-- Exclude
	);', NULL);

-------------------- 122, 2: How To: Run code before or after index maintenance - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Discussion', 2, 'Discussion', 'Run code before or after index maintenance', 'You can schedule code to run before or after index maintenance operations. There are several options available: 
  * Run code before or after a single database
  * Run code before or after each and every table in a database
  * Run code before or after a single table
  * Run code before or after each of a few tables (code executing before or after each table)
  * Run code before or after all but a few tables (code executing before or after each table)
  * Run code before or after reindex statements (within the same batch)

NOTE: Unless otherwise specified, pre and post code will run in the context of the Minion Reindex’s database (wherever the Minion Reindex objects are stored), because it was a design decision not to limit the code that can be run to a specific database. Therefore, always use “USE” statements – or, for stored procedures, three-part naming convention – for pre and postcode.', NULL);

-------------------- 122, 10: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 10, 'Example', 'Example', 'To run code before or after a single database, insert a row for the database into Minion.IndexSettingsDB. Populate the column DBPreCode to run code before the index operations for that database; populate the column DBPostCode to run code before the index operations after that database. For example: 
INSERT INTO [Minion].[IndexSettingsDB]
           ( DBName
           , Exclude
           , ReorgThreshold
           , RebuildThreshold
           , FILLFACTORopt
           , PadIndex 
           , DBPreCode
           , DBPostCode)
     VALUES
           (''YourDatabase''	-- DBName
           , 0		-- Exclude
           , 15		-- ReorgThreshold
           , 25		-- RebuildThreshold
           , 90		-- FILLFACTORopt
           , ''ON''		-- DBPreCode
           , ''EXEC YourDatabase.dbo.SomeSP;'' -- DBPreCode
           , ''EXEC YourDatabase.dbo.OtherSP;'' -- DBPostCode
           );', NULL);

-------------------- 122, 15: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 15, 'Example', 'Example', 'To run code before or after each and every table in a database, insert a row for the database into Minion.IndexSettingsDB. Populate the column TablePreCode to run code before the index operations for each individual table in the database; populate the column TablePostCode to run code after the index operations for each individual table in the database. For example: 
INSERT INTO [Minion].[IndexSettingsDB]
           ( DBName
           , Exclude
           , ReorgThreshold
           , RebuildThreshold
           , FILLFACTORopt
           , PadIndex 
           , TablePreCode
           , TablePostCode)
     VALUES
           (''YourDatabase''	-- DBName
           , 0		-- Exclude
           , 15		-- ReorgThreshold
           , 25		-- RebuildThreshold
           , 90		-- FILLFACTORopt
           , ''ON''		-- DBPreCode
           , ''EXEC YourDatabase.dbo.SomeSP;'' -- TablePreCode
           , ''EXEC YourDatabase.dbo.OtherSP;'' -- TablePostCode
           );', NULL);

-------------------- 122, 20: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 20, 'Example', 'Example', 'To run code before or after a single table (instead of each table), insert a row for the table into Minion.IndexSettingsTable. Populate the column TablePreCode to run code before the index operations for that database; populate the column TablePostCode to run code before the index operations after that database. 

Note: An entry in Minion.IndexSettingsTable overrides ALL the index maintenance settings for that table; defaults set in Minion.IndexSettingsDB will be ignored for this table.

For example:
INSERT	INTO [Minion].[IndexSettingsTable]
		( [DBName] ,
		  [SchemaName] ,
		  [TableName] ,
		  [ReorgThreshold] ,
		  [RebuildThreshold] ,
		  [FILLFACTORopt] ,
		  [PadIndex] ,
		  [GetRowCT] ,
		  [GetPostFragLevel] ,
		  [UpdateStatsOnDefrag] ,
		  [LogIndexPhysicalStats] ,
		  [IndexScanMode] ,
		  [LogProgress] ,
		  [LogRetDays] ,
		  [IncludeUsageDetails] ,
		  [TablePreCode] ,
		  [TablePostCode] 
		)
VALUES	( ''YourDatabase'' ,	-- DBName
		  ''dbo'' ,		-- SchemaName
		  ''YourTable'' ,	-- TableName
		  10 ,		-- ReorgThreshold
		  20 ,		-- RebuildThreshold
		  80 ,		-- FILLFACTORopt
		  ''ON'' ,		-- PadIndex
		  1 ,		-- GetRowCT
		  1 ,		-- GetPostFragLevel
		  1 ,		-- UpdateStatsOnDefrag
		  0 ,		-- LogIndexPhysicalStats
		  ''Limited'' ,	-- IndexScanMode
		  1 ,		-- LogProgress
		  60 ,		-- LogRetDays
		  1 ,		-- IncludeUsageDetails
		  ''EXEC YourDatabase.dbo.SomeSP;'' ,	-- TablePreCode
		  ''EXEC YourDatabase.dbo.OtherSP;''	-- TablePostCode
 		);', NULL);

-------------------- 122, 25: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 25, 'Example', 'Example', 'To run code before or after each of a few tables, insert one row for each of the tables into Minion.IndexSettingsTable, populating the TablePreCode column and/or TablePostCode column as appropriate.', NULL);

-------------------- 122, 30: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 30, 'Example', 'Example', 'To run code before or after all but a few tables, insert one row for the database into Minion.IndexSettingsDB, populating the TablePreCode column and/or the TablePostCode column as appropriate. This will set up the execution code for all tables. Then, to prevent that code from running on a handful of tables, insert a row for each of those tables to Minion.IndexSettingsTable, and keep the TablePreCode and TablePostCode columns set to NULL. 

For example, if we want to run the stored procedure dbo.SomeSP before each table in [YourDatabase] except tables T1, T2, and T3, we would: 
1.	Insert a row to Minion.IndexSettingsDB for [YourDatabase], setting PreCode to ‘EXEC dbo.SomeSP;’
2.	Insert a row to Minion.IndexSettingsTable for [YourDatabase].dbo.T1, establishing all appropriate settings, and setting PreCode to NULL. 
3.	Insert a row to Minion.IndexSettingsTable for [YourDatabase].dbo.T2, establishing all appropriate settings, and setting PreCode to NULL. 
4.	Insert a row to Minion.IndexSettingsTable for [YourDatabase].dbo.T3, establishing all appropriate settings, and setting PreCode to NULL. 

NOTE: We strongly recommend that you encapsulate any pre- or post-code into a stored procedure, unless the code is extremely simple. You can’t pass pre- or post-code parameters into the indexing routine, so pre- and post-code must be self-contained. ', NULL);

-------------------- 122, 35: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 35, 'Example', 'Example', 'A real world TablePreCode example:  You have a database supplied by a vendor.  This database has a table with a non-clustered index with ALLOW_PAGE_LOCKS = OFF set.  This option causes the reorganize operation on that index to fail.  To resolve this, enter a row for that table into the Minion.IndexSettingsTable table, and include the following TablePreCode and TablePostCode options:
INSERT	Minion.IndexSettingsTable
		( DBName 
		  , SchemaName 
		  , TableName 
		  , Exclude 
		  , ReindexGroupOrder 
		  , ReindexOrder 
		  , ReorgThreshold 
		  , RebuildThreshold 
		  , AllowPageLocks 
		  , TablePreCode 
		  , TablePostCode
		)
SELECT	''Demo'' 		--DBName
		, ''dbo'' 	--SchemaName
		, ''fragment''  --TableName
		, 0 		--Exclude
		, 0 		--ReindexGroupOrder
		, 0 		--ReindexOrder
		, 10 		--ReorgThreshold,
		, 20 		--RebuildThreshold
		, ''ON'' 
		, ''USE [Demo]; ALTER index ix_fragment2 ON dbo.fragment SET (ALLOW_PAGE_LOCKS = ON);''   -- TablePreCode
		, ''USE [Demo]; ALTER index ix_fragment2 ON dbo.fragment SET (ALLOW_PAGE_LOCKS = OFF);'' --TablePostCode
', NULL);

-------------------- 122, 40: How To: Run code before or after index maintenance - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (122, 'Example', 40, 'Example', 'Example', 'To run code before or after reindex statements and within the same batch, you can use the StmtPrefix and/or StmtSuffix columns in Minion.IndexSettingsDB, Minion.IndexSettingsTable, or both.  

It is important to understand that this column allows you to prefix every reindex statement for a table, or for a database, with a statement of your own.  This is different from the table precode and postcode, because it is run in the same batch. Whereas, precode and postcode are run as completely separate statements, in different contexts.  

A good example use case for this is the need to ensure that your reindex statement is chosen as the deadlock victim (should a deadlock occur) for DatabaseA.  In this case, you would set StmtPrefix to “SET DEADLOCK_PRIORITY LOW;” for DatabaseA in the Minion.IndexSettingsDB table.  Other uses include setting a lock timeout, or adding a time delay to every reindex statement.  

The StmtPrefix you choose will be shown as part of the Cmd column in the Minion.IndexMaintLogDetails table. IMPORTANT: To ensure that your statements run properly, you must end the code in this column with a semicolon.', NULL);

-------------------- 118, 2: How To: Reindex databases on different schedules - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (118, 'Discussion', 2, 'Discussion', 'Reindex databases on different schedules', 'Create a new job for each different schedule you require for index maintenance. Let us take a simple example: 
       * Perform index rebuilds on [YourDatabase] Friday night at 11pm
       * Perform index rebuilds on all other databases on Saturday night at 10pm
       * Perform index reorganization on all databases Sunday through Thursdays at 10pm.

To achieve this using the default installed Minion Reindex jobs:
1.	Connect to “YourServer” and expand the SQL Agent node. You’ll see two new jobs: 
       * MinionReindexDBs-All-All – Runs once weekly – Fridays at 3:00 AM - to thoroughly defragment indexes (rebuild).
       * MinionReindexDBs-All-REORG – Runs Daily – 3:00 AM except for Friday – to complete lightweight defragmenting (reorganize).
2.	Edit the “MinionReindexDBs-All-All” job:
     a.	Edit the “Reindex” step: add ‘YourDatabase’ to the @Exclude parameter.
     b.	Edit the schedule to run Friday night at 11pm. 
3.	Create a new job “MinionReindexDBs-YourDatabase-All”. 
     a.	Create a “Reindex” step similar to that in the “MinionReindexDBs-All-All” job. Set @Include to ‘YourDatabase’, and set @Exclude to NULL.
     b.	Schedule it to run Saturday night at 10pm. 
4.	Edit the schedules for the job “MinionReindexDBs-All-REORG” to run Sunday through Thursday at 10pm. ', NULL);

-------------------- 123, 2: How To: Configure how long the reindex logs are kept - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (123, 'Discussion', 2, 'Discussion', 'Configure how long the reindex logs are kept', 'Minion Reindex stores the “log retention in days” setting (LogRetDays) in the Minion.IndexSettingsDB table and the Minion.IndexSettingsTable table. You can therefore set the log retention for individual tables, individual databases and/or the system as a whole.', NULL);

-------------------- 123, 10: How To: Configure how long the reindex logs are kept - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (123, 'Example', 10, 'Example', 'Example', 'To change the default log retention for the system, run an update statement on the MinionDefault row in Minion.IndexSettingsDB. For example:
UPDATE [Minion].[IndexSettingsDB]
SET  [LogRetDays] = 60
WHERE [DBName] = ''MinionDefault'';', NULL);

-------------------- 123, 15: How To: Configure how long the reindex logs are kept - Example --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (123, 'Example', 15, 'Example', 'Example', 'To change the log retention for a specific database, run an update statement on that database’s row in Minion.IndexSettingsDB. For example:
UPDATE [Minion].[IndexSettingsDB]
SET  [LogRetDays] = 90
WHERE [DBName] = ''YourDatabase'';', NULL);

-------------------- 124, 2: Overview of Tables - Overview --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (124, 'Overview', 2, 'Overview', 'Overview', 'Settings (like rebuild threshold) are stored in two separate tables, one for database-level defaults, and another for table-level defaults. Index fragmentation statistics are stored long term in one table, and in the short term (to aid the index maintenance operations) in another table. Index maintenance activities are logged at a high (“master”) level, and also at a per-operation level. So, for example, you can see how long the entire maintenance operation took, or how long an individual index rebuild lasted.  
Reindex settings:
  * Minion.IndexSettingsDB – This table holds index maintenance default settings at the database level. You may insert rows to define index maintenance settings per database, or you can rely on the system-wide default settings (defined in the “MinionDefault” row), or a combination of both.
  * Minion.IndexSettingsTable - This table holds index maintenance default settings at the table level. You may insert rows to override the default index maintenance settings for individual tables. Any table that does not have a value in this table gets its settings from the appropriate entry in the Minion.IndexSettingsDB table.
  * Minion.IndexMaintSettingsServer - This table contains server-level settings, including schedule information. The primary Minion Reindex job runs regularly in conjunction with this table to provide a wide range of index maintenance options, all without introducing additional SQL Agent jobs.
  * Minion.DBMaintRegexLookup – Allows you to exclude databases from index maintenance (or all maintenance), based off of regular expressions.

Index fragmentation stats:
  * Minion.IndexPhysicalStats – This table holds index size and fragmentation information when the @currLogIndexPhysicalStats parameter is enabled.  You can use this data after an index maintenance to investigate the raw fragmentation data, to estimate the next time a table will need to be reindexed, and more. Currently, this table must be manually deleted; the large amount of data here means we don’t recommend leaving this setting on for long.  Only turn it on when you need to diagnose something. 
  * Minion.IndexTableFrag - Holds index fragmentation information during the index maintenance process.  If you run the index maintenance process with @PrepOnly = 1, this table stores that data; a subsequent run of index maintenance with @RunPrepped = 1 will make use of this prepared data, instead of gathering statistics at the same time. 

Logs: 
  * Minion.IndexMaintLog – Holds a database-level summary of the whole maintenance operation. Each row contains the database name, operation status, the start and end time of the index maintenance event, and much more. This is updated as each operation occurs, so that you have Live Insight into active index operations.
  * Minion.IndexMaintLogDetails - Keeps a record of individual index maintenance activities. It contains one time-stamped row for each individual index operation (e.g., a single index rebuild). This is updated as each operation occurs, so that you have Live Insight into active index operations.
', NULL);

-------------------- 111, 2: Minion.IndexSettingsDB - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'Purpose', 2, 'Purpose', 'Purpose', 'This table holds index maintenance default settings at the default and database levels. You may insert rows for individual databases to override the default index maintenance settings (per database). Minion.IndexSettingsDB is installed with default settings already in place, via the system-wide default row (identified by DBName = “MinionDefault”). If you do not need to fine tune the reindexing process at all, no action is required, and all maintenance will use this default configuration. To override these default settings for a specific database, insert a new row for the individual database with the desired settings. Note that any database with its own entry in Minion.IndexSettingsDB retrieves ALL its configuration data from that row. For example, if you enter a row for [YourDatabase] and leave the FILLFACTORopt at NULL, Minion Reindex does not retrieve that value from the “MinionDefault” row; in this case, fill factor for YourDatabase would default to the current index setting (viewable for that index in sys.indexes).', NULL);

-------------------- 111, 3: Minion.IndexSettingsDB - Important --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'Important', 3, 'Important', 'Important', 'Important: Do not delete the MinionDefault row, or rename the DBName column for this row!', NULL);

-------------------- 111, 4: Minion.IndexSettingsDB - ID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'ID', 4, 'Column', 'Column', 'Primary key row identifier.', 'int');

-------------------- 111, 5: Minion.IndexSettingsDB - DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'DBName', 5, 'Column', 'Column', 'Database name.', 'nvarchar');

-------------------- 111, 6: Minion.IndexSettingsDB - Exclude --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'Exclude', 6, 'Column', 'Column', 'Exclude database from index maintenance. For more on this topic, see “How To: Exclude Databases from Index Maintenance”.', 'bit');

-------------------- 111, 7: Minion.IndexSettingsDB - ReindexGroupOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'ReindexGroupOrder', 7, 'Column', 'Column', 'Group to which this database belongs. Used solely for determining the order in which databases should be processed for index maintenance. By default, all databases have a value of 0, which means they’‘ll be processes in the order they’‘re queried from sysobjects. Higher numbers have a greater “weight” (they have a higher priority), and will be indexed earlier than lower numbers. The range of ReindexGroupOrder weight numbers is 0-255. For more information, see “How To: Reindex databases in a specific order”.', 'tinyint');

-------------------- 111, 8: Minion.IndexSettingsDB - ReindexOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'ReindexOrder', 8, 'Column', 'Column', 'The index maintenance order within a group. Used solely for determining the order in which databases should be processed for index maintenance. By default, all databases have a value of 0, which means they’‘ll be processes in the order they’‘re queried from sysobjects. Higher numbers have a greater “weight” (they have a higher priority), and will be indexed earlier than lower numbers. We recommend leaving some space between assigned reindex order numbers (e.g., 10, 20, 30) so there is room to move or insert rows in the ordering. For more information, see “How To: Reindex databases in a specific order”.', 'int');

-------------------- 111, 9: Minion.IndexSettingsDB - ReorgThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'ReorgThreshold', 9, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should reorganize an index. For example, if ReorgThreshold is set to 10 and the RebuildThreshold is 20, then a reorg will be done for all indexes between 10 and 19. And a rebuild will be done for all indexes 20 and above.', 'tinyint');

-------------------- 111, 10: Minion.IndexSettingsDB - RebuildThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'RebuildThreshold', 10, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should rebuild an index. For example, if ReorgThreshold is set to 10 and the RebuildThreshold is 20, then a reorg will be done for all indexes between 10 and 19. And a rebuild will be done for all indexes 20 and above.', 'tinyint');

-------------------- 111, 11: Minion.IndexSettingsDB - FILLFACTORopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'FILLFACTORopt', 11, 'Column', 'Column', 'Specify how full a reindex maintenance should make each page when it rebuilds an index. For example, a value of 85 would leave each data page 85% full of data. A value of NULL indicates that reindexing should use the current index setting (viewable for that index in sys.indexes).', 'tinyint');

-------------------- 111, 12: Minion.IndexSettingsDB - PadIndex --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'PadIndex', 12, 'Column', 'Column', 'Turn PAD_INDEX on or off. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the current index setting (viewable for that index in sys.indexes).', 'varchar (3)');

-------------------- 111, 13: Minion.IndexSettingsDB - SortInTempDB --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'SortInTempDB', 13, 'Column', 'Column', 'Direct index maintenance to use TempDB to store the intermediate sort results that are used to build the index. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the system setting (in this case, “OFF”).', 'varchar (3)');

-------------------- 111, 14: Minion.IndexSettingsDB - ONLINEopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'ONLINEopt', 14, 'Column', 'Column', 'Perform ONLINE index maintenance for indexes in this database. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the system setting (in this case, “OFF”, meaning the index maintenance will be done offline). Note that ONLINE index operations may not be possible for certain editions of SQL Server, and only for indexes that are eligible for ONLINE index operations. If you specify ONLINE when it is not possible, the routine will change it to OFFLINE.', 'varchar (3)');

-------------------- 111, 14: Minion.IndexSettingsDB - StmtPrefix --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'StmtPrefix', 14, 'Column', 'Column', 'This column allows you to prefix every reindex statement with a statement of your own.  This is different from the table precode and postcode, because it is run in the same batch. Whereas, precode and postcode are run as completely separate statements, in different contexts.  

Code entered in this column MUST end in a semicolon.

For more information, see “How To: Run code before or after index maintenance”.', 'nvarchar');

-------------------- 111, 15: Minion.IndexSettingsDB - MAXDOPopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'MAXDOPopt', 15, 'Column', 'Column', 'Specify the max degree of parallelism (“MAXDOP”, the number of CPUs to use) for the index maintenance operations. If specified, this overrides the MAXDOP configuration option for the duration of the index operation.', 'tinyint');

-------------------- 111, 16: Minion.IndexSettingsDB - StmtSuffix --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'StmtSuffix', 16, 'Column', 'Column', 'This column allows you to suffix every reindex statement with a statement of your own.  This is different from the table precode and postcode, because it is run in the same batch. Whereas, precode and postcode are run as completely separate statements, in different contexts.  

Code entered in this column MUST end in a semicolon.

For more information, see “How To: Run code before or after index maintenance”.', 'nvarchar');

-------------------- 111, 16: Minion.IndexSettingsDB - DataCompression --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'DataCompression', 16, 'Column', 'Column', 'The data compression option. The options are as follows: Valid inputs: NONE ROW PAGE COLUMNSTORE COLUMNSTORE_ARCHIVE A NULL value here would indicate DataCompression=‘‘NONE’‘.', 'varchar (50)');

-------------------- 111, 17: Minion.IndexSettingsDB - GetRowCT --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'GetRowCT', 17, 'Column', 'Column', 'Get a rowcount for each table.', 'bit');

-------------------- 111, 18: Minion.IndexSettingsDB - GetPostFragLevel --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'GetPostFragLevel', 18, 'Column', 'Column', 'Get the fragmentation level for each index, after the index maintenance operations are complete. This is done on a per index basis as soon as the reindex operation is complete for each index.', 'bit');

-------------------- 111, 19: Minion.IndexSettingsDB - UpdateStatsOnDefrag --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'UpdateStatsOnDefrag', 19, 'Column', 'Column', 'Update statistics after defragmenting. This should always be on, but Minion provides the option just in case your stats are handled in some other way.', 'bit');

-------------------- 111, 20: Minion.IndexSettingsDB - StatScanOption --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'StatScanOption', 20, 'Column', 'Column', 'Options available for the UPDATE STATISTICS statement (that is, anything that would go in the “WITH” statement). Valid inputs include any of the following options, as a comma-delimited list: FULLSCAN SAMPLE … RESAMPLE ON PARTITIONS ... STATS_STREAM ROWCOUNT PAGECOUNT For example, StatScanOption could be set to “SAMPLE 50 PERCENT”, or “FULLSCAN, NORECOMPUTE”.', 'varchar (25)');

-------------------- 111, 21: Minion.IndexSettingsDB - IgnoreDupKey --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'IgnoreDupKey', 21, 'Column', 'Column', 'Change the option so that for this index, inserts that add (normally illegal) duplicates generate a warning instead of an error. Applies to inserts that occur any time after the index operation. The default is OFF. Valid inputs: ON OFF', 'varchar (3)');

-------------------- 111, 22: Minion.IndexSettingsDB - StatsNoRecompute --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'StatsNoRecompute', 22, 'Column', 'Column', 'Disable the automatic statistics update option, AUTO_UPDATE_STATISTICS. Valid inputs: ON OFF', 'varchar (3)');

-------------------- 111, 23: Minion.IndexSettingsDB - AllowRowLocks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'AllowRowLocks', 23, 'Column', 'Column', 'Enable or disable the ALLOW_ROW_LOCKS option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx Valid inputs: ON OFF', 'varchar (3)');

-------------------- 111, 24: Minion.IndexSettingsDB - AllowPageLocks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'AllowPageLocks', 24, 'Column', 'Column', 'Enable or disable the ALLOW_PAGE_LOCKS option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx Valid inputs: ON OFF', 'varchar (3)');

-------------------- 111, 25: Minion.IndexSettingsDB - WaitAtLowPriority --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'WaitAtLowPriority', 25, 'Column', 'Column', 'Enable or disable the WAIT_AT_LOW_PRIORITY option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'bit');

-------------------- 111, 26: Minion.IndexSettingsDB - MaxDurationInMins --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'MaxDurationInMins', 26, 'Column', 'Column', 'Set the MAX_DURATION option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'bit');

-------------------- 111, 27: Minion.IndexSettingsDB - AbortAfterWait --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'AbortAfterWait', 27, 'Column', 'Column', 'Enable or disable the ABORT_AFTER_WAIT option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx Valid inputs: NONE SELF BLOCKERS', 'varchar (20)');

-------------------- 111, 28: Minion.IndexSettingsDB - PushToMinion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'PushToMinion', 28, 'Column', 'Column', 'Save these values to the central Minion server, if it exists. Modifies values for this particular database on the central Minion server. A value of NULL indicates that this feature is off. Functionality not yet supported.', 'bit');

-------------------- 111, 29: Minion.IndexSettingsDB - LogIndexPhysicalStats --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'LogIndexPhysicalStats', 29, 'Column', 'Column', 'Save the current index physical stats to a table (Minion.IndexPhysicalStats).', 'bit');

-------------------- 111, 30: Minion.IndexSettingsDB - IndexScanMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'IndexScanMode', 30, 'Column', 'Column', 'Valid inputs: Detailed Limited NULL A value of NULL indicates that reindexing should use the default (in this case, “LIMITED”).', 'varchar (25)');

-------------------- 111, 31: Minion.IndexSettingsDB - DBPreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'DBPreCode', 31, 'Column', 'Column', 'Code to run for a database, before the index maintenance operations begin for that database. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar (max)');

-------------------- 111, 32: Minion.IndexSettingsDB - DBPostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'DBPostCode', 32, 'Column', 'Column', 'Code to run for a database, after the index maintenance operations complete for that database. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar (max)');

-------------------- 111, 33: Minion.IndexSettingsDB - TablePreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'TablePreCode', 33, 'Column', 'Column', 'Code to run for each and every table, before the index maintenance operations begin for that table. Note: To run precode just once, before maintenance for the database begins, use the DBPreCode column. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar (max)');

-------------------- 111, 34: Minion.IndexSettingsDB - TablePostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'TablePostCode', 34, 'Column', 'Column', 'Code to run for each and every table, after the index maintenance operations end for that table. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar (max)');

-------------------- 111, 35: Minion.IndexSettingsDB - LogProgress --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'LogProgress', 35, 'Column', 'Column', 'Track the progress of index operations for this database. The overall status is tracked in the Minion.IndexMaintLog table, while specific operations are tracked in the Status column Minion.IndexMaintLogDetails.', 'bit');

-------------------- 111, 36: Minion.IndexSettingsDB - LogRetDays --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'LogRetDays', 36, 'Column', 'Column', 'Number of days to retain index maintenance log data, for this database. Just like any setting, if a table-specific row exists (in Minion.IndexSettingTable), those settings take precedence over database level settings. That is, if DB1.Table1 has an entry for LogRetDays=50, and DB1 has an entry for LogRetDays=40, the log will keep 50 days for DB1.Table1. When first implemented, Minion Reindex defaults to 60 days of log retention.', 'smallint');

-------------------- 111, 38: Minion.IndexSettingsDB - MinionTriggerPath --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'MinionTriggerPath', 38, 'Column', 'Column', 'UNC path where the Minion logging trigger file is located. Not applicable for a standalone Minion Reindex instance.', 'varchar (1000)');

-------------------- 111, 39: Minion.IndexSettingsDB - RecoveryModel --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'RecoveryModel', 39, 'Column', 'Column', 'Change the recovery model of the database for the duration of the index maintenance operation. After index maintenance operations, the database will be set back to its original recovery model. Valid inputs: FULL BULK_LOGGED SIMPLE WARNING: While we have done extensive testing and checking for this feature, it may still be possible for the process to fail in such a way that a database changed (for example) from FULL to SIMPLE may not switch back. Therefore, we advise that if you’‘re in FULL you switch to BULK_LOGGED instead. It won’‘t break your log chain and it has the same effect as switching to SIMPLE.', 'varchar (12)');

-------------------- 111, 40: Minion.IndexSettingsDB - IncludeUsageDetails --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'IncludeUsageDetails', 40, 'Column', 'Column', 'Save index usage details from sys.dm_db_index_usage_stats, to Minion.IndexMaintLogDetails. This feature is useful for tracking which indexes are being used the most over time.', 'bit');

-------------------- 111, 43: Minion.IndexSettingsDB - RebuildHeap --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'RebuildHeap', 43, 'Column', 'Column', 'Whether or not to rebuild heaps. Caution: This will rebuild all the nonclustered indexes on the table.', 'bit');

-------------------- 111, 45: Minion.IndexSettingsDB - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'Discussion', 45, 'Discussion', 'Discussion', 'Insert a new row for [YourDatabase], if you wish to specify different default values for the reorg threshold, rebuild threshold, fill factor, and so on.', NULL);

-------------------- 111, 50: Minion.IndexSettingsDB - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'Discussion', 50, 'Discussion', 'Discussion', 'The Minion.IndexSettingsDB table comes with a row with “MinionDefault” as the DBName value. This row defines the system-wide defaults. 

Important: Any row inserted for an individual database overrides only ALL of the values, whether or not they are specified. Refer to the following for an example: 

ID DBName        Exclude ReorgThreshold RebuildThreshold FillFactorOpt 
1  MinionDefault 0       10             20               90 
2  YourDatabase  0       15             25               NULL 

The first row, “MinionDefault”, is the set of default values to use for all the databases in the SQL Server instance. These values will be used for index maintenance for all databases that do not have an additional row in this table. 

The second row, [YourDatabase], specifies some values for YourDatabase. This row completely overrides the “DefaultMinion” values for YourDatabase. 

When index operations are performed for YourDatabase, only the values from the YourDatabase row will be used. So, even though the system-wide default (as specified in the MinionDefault row) for Fill Factor is 90%, YourDatabase will not use that default value. Because Fill Factor is NULL for YourDatabase, index maintenance will use the current value specified for the index. You can find the current value for a specific index by running the following query: 

SELECT * FROM sys.indexes 
WHERE name = ''nonMyIndex'' 

Likewise, you can also specify table-level override settings in the Minion.IndexSettingsTable table, which will override any settings for that particular table (and ignore the settings in Minion.IndexSettingsDB). 

NOTE: While it is possible to exclude a single database from reindexing, by setting both the ReorgThreshold and RebuildThreshold above 100% for that database, we do not recommend this approach. This would cause Minion Reindex to gather fragmentation stats that will never be used. Instead, set the Exclude column to 1 for that database. 

Likewise, we do not recommend setting the thresholds at 0%. While this would guarantee that every index in the database would be reorganized at every maintenance execution, it would likely be an unnecessary waste of resources.', NULL);

-------------------- 111, 55: Minion.IndexSettingsDB - Examples --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (111, 'Examples', 55, 'Examples', 'Examples', 'Usage examples: 
Example 1: Set custom thresholds, fill factor, and PadIndex for database ''YourDatabase''. 

INSERT INTO [Minion].[IndexSettingsDB] ( DBName
  , Exclude
  , ReorgThreshold
  , RebuildThreshold
  , FILLFACTORopt
  , PadIndex ) 
VALUES (''YourDatabase'' -- DBName
  , 0 -- Exclude
  , 15 -- ReorgThreshold
  , 25 -- RebuildThreshold
  , 90 -- FILLFACTORopt
  , ''ON'' -- PadIndex ); 

Example 2: Set custom reindex settings, and enable additional logging options for database ''YourDatabase''. 

INSERT INTO [Minion].[IndexSettingsDB] ( DBName
  , Exclude
  , ReorgThreshold
  , RebuildThreshold
  , FILLFACTORopt
  , PadIndex
  , SortInTempDB
  , UpdateStatsOnDefrag
  , GetRowCT
  , GetPostFragLevel
  , LogIndexPhysicalStats
  , LogProgress
  , LogRetDays
  , LogLoc) 
VALUES (''YourDatabase'' -- DBName
  , 0 -- Exclude
  , 15 -- ReorgThreshold
  , 25 -- RebuildThreshold
  , 90 -- FILLFACTORopt
  , ''ON'' -- PadIndex
  , ''ON'' -- SortInTempDB
  , 1 -- UpdateStatsOnDefrag
  , 1 -- GetRowCT
  , 1 -- GetPostFragLevel
  , 1 -- LogIndexPhysicalStats
  , 1 -- LogProgress
  , 90 -- LogRetDays
  , ''Local'' -- LogLoc );', NULL);


-------------------- 96, 2: Minion.IndexSettingsTable - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'Purpose', 2, 'Purpose', 'Purpose', 'This table holds index maintenance default settings at the table level. You may insert rows for individual tables to override the default index maintenance settings (per table). Any table that does not have a value in this table will get all of its index maintenance settings from the Minion.IndexSettingsDB table. For example, if FillFactorOpt is set at 90 in Minion.IndexSettingsDB, but a row for Table1 here has FillFactorOpt at 95, then the 95 value is used. (If FillFactorOpt is left at NULL in the Minion.IndexSettingsTable row, the database level setting is still not used. Instead, the current index setting in sys.indexes will be used.) Note that many shops will have no values in this table, if there is no need for ordering the tables for reindex, or for setting options for specific tables.', NULL);

-------------------- 96, 4: Minion.IndexSettingsTable - Use --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'Use', 4, 'Use', 'Use', 'Insert a new row for each individual table that requires specific table-level values for index maintenance.', NULL);

-------------------- 96, 6: Minion.IndexSettingsTable - ID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'ID', 6, 'Column', 'Column', 'Primary key row identifier.', 'int');

-------------------- 96, 7: Minion.IndexSettingsTable - DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'DBName', 7, 'Column', 'Column', 'Database name.', 'nvarchar');

-------------------- 96, 8: Minion.IndexSettingsTable - SchemaName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'SchemaName', 8, 'Column', 'Column', 'Schema name.', 'nvarchar');

-------------------- 96, 9: Minion.IndexSettingsTable - TableName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'TableName', 9, 'Column', 'Column', 'Table name.', 'nvarchar');

-------------------- 96, 10: Minion.IndexSettingsTable - Exclude --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'Exclude', 10, 'Column', 'Column', 'Exclude table from index maintenance. For more on this topic, see “How To: Exclude Databases from Index Maintenance”.', 'bit');

-------------------- 96, 11: Minion.IndexSettingsTable - GroupOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'GroupOrder', 11, 'Column', 'Column', 'Group to which this table belongs. Used solely for determining the order in which tables should be processed for index maintenance. By default, all tables have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects. Higher numbers have a greater “weight” (they have a higher priority), and will be indexed earlier than lower numbers. For more information, see “How To: Reindex databases in a specific order”.', 'int');

-------------------- 96, 12: Minion.IndexSettingsTable - ReindexOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'ReindexOrder', 12, 'Column', 'Column', 'The index maintenance order within a group. Used solely for determining the order in which tables should be processed for index maintenance. By default, all tables have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects. Higher numbers have a greater “weight” (they have a higher priority), and will be indexed earlier than lower numbers. We recommend leaving some space between assigned reindex order numbers (e.g., 10, 20, 30) so there is room to move or insert rows in the ordering. For more information, see “How To: Reindex databases in a specific order”.', 'int');

-------------------- 96, 13: Minion.IndexSettingsTable - ReorgThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'ReorgThreshold', 13, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should reorganize an index. For example, if ReorgThreshold is set to 10 and the RebuildThreshold is 20, then a reorg will be done for all indexes between 10 and 19. And a rebuild will be done for all indexes 20 and above.', 'tinyint');

-------------------- 96, 14: Minion.IndexSettingsTable - StmtPrefix --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'StmtPrefix', 14, 'Column', 'Column', 'This column allows you to prefix every reindex statement with a statement of your own.  This is different from the table precode and postcode, because it is run in the same batch. Whereas, precode and postcode are run as completely separate statements, in different contexts.  

Code entered in this column MUST end in a semicolon.

For more information, see “How To: Run code before or after index maintenance”.', 'nvarchar');

-------------------- 96, 14: Minion.IndexSettingsTable - RebuildThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'RebuildThreshold', 14, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should rebuild an index. For example, if ReorgThreshold is set to 10 and the RebuildThreshold is 20, then a reorg will be done for all indexes between 10 and 19. And a rebuild will be done for all indexes 20 and above.', 'tinyint');

-------------------- 96, 15: Minion.IndexSettingsTable - FILLFACTORopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'FILLFACTORopt', 15, 'Column', 'Column', 'Specify how full a reindex maintenance should make each page when it rebuilds an index. For example, a value of 85 would leave each data page 85% full of data. A value of NULL indicates that reindexing should use the current index setting (viewable for that index in sys.indexes).', 'tinyint');

-------------------- 96, 16: Minion.IndexSettingsTable - PadIndex --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'PadIndex', 16, 'Column', 'Column', 'Turn PAD_INDEX on or off. Valid inputs: ON OFF A value of NULL indicates that reindexing should use the current index setting (viewable for that index in sys.indexes).', 'varchar (3)');

-------------------- 96, 16: Minion.IndexSettingsTable - StmtSuffix --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'StmtSuffix', 16, 'Column', 'Column', 'This column allows you to suffix every reindex statement with a statement of your own.  This is different from the table precode and postcode, because it is run in the same batch. Whereas, precode and postcode are run as completely separate statements, in different contexts.  

Code entered in this column MUST end in a semicolon.

For more information, see “How To: Run code before or after index maintenance”.', 'nvarchar');

-------------------- 96, 17: Minion.IndexSettingsTable - ONLINEopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'ONLINEopt', 17, 'Column', 'Column', 'Perform ONLINE index maintenance for indexes in this database. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the system setting (in this case, “OFF”, meaning the index maintenance will be done offline). Note that ONLINE index operations may not be possible for certain editions of SQL Server, and only for indexes that are eligible for ONLINE index operations. If you specify ONLINE when it is not possible, the routine will change it to OFFLINE.', 'varchar (3)');

-------------------- 96, 18: Minion.IndexSettingsTable - SortInTempDB --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'SortInTempDB', 18, 'Column', 'Column', 'Direct index maintenance to use TempDB to store the intermediate sort results that are used to build the index. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the system setting (in this case, “OFF”).', 'varchar (3)');

-------------------- 96, 19: Minion.IndexSettingsTable - MAXDOPopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'MAXDOPopt', 19, 'Column', 'Column', 'Specify the max degree of parallelism (“MAXDOP”, the number of CPUs to use) for the index maintenance operations. If specified, this overrides the MAXDOP configuration option for the duration of the index operation.', 'tinyint');

-------------------- 96, 20: Minion.IndexSettingsTable - DataCompression --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'DataCompression', 20, 'Column', 'Column', 'The data compression option. The options are as follows: Valid inputs: NONE ROW PAGE COLUMNSTORE COLUMNSTORE_ARCHIVE', 'varchar (50)');

-------------------- 96, 21: Minion.IndexSettingsTable - GetRowCT --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'GetRowCT', 21, 'Column', 'Column', 'Get a rowcount for this table.', 'bit');

-------------------- 96, 22: Minion.IndexSettingsTable - GetPostFragLevel --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'GetPostFragLevel', 22, 'Column', 'Column', 'Get the level of fragmentation for each index, after the index maintenance operations are complete.', 'bit');

-------------------- 96, 23: Minion.IndexSettingsTable - UpdateStatsOnDefrag --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'UpdateStatsOnDefrag', 23, 'Column', 'Column', 'Update statistics after defragmenting. This should always be on, but Minion provides the option just in case your stats are handled in some other way.', 'bit');

-------------------- 96, 24: Minion.IndexSettingsTable - StatScanOption --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'StatScanOption', 24, 'Column', 'Column', 'Options available for the UPDATE STATISTICS statement (that is, anything that would go in the “WITH” statement). Valid inputs include any of the following options, as a comma-delimited list: FULLSCAN SAMPLE … RESAMPLE ON PARTITIONS ... STATS_STREAM ROWCOUNT PAGECOUNT For example, StatScanOption could be set to “SAMPLE 50 PERCENT”, or “FULLSCAN, NORECOMPUTE”.', 'varchar (25)');

-------------------- 96, 25: Minion.IndexSettingsTable - IgnoreDupKey --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'IgnoreDupKey', 25, 'Column', 'Column', 'Change the option so that for this index, inserts that add (normally illegal) duplicates generate a warning instead of an error. Applies to inserts that occur any time after the index operation. The default is OFF. Valid inputs: ON OFF', 'varchar (3)');

-------------------- 96, 26: Minion.IndexSettingsTable - StatsNoRecompute --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'StatsNoRecompute', 26, 'Column', 'Column', 'Disable the automatic statistics update option, AUTO_UPDATE_STATISTICS. Valid inputs: ON OFF', 'varchar (3)');

-------------------- 96, 27: Minion.IndexSettingsTable - AllowRowLocks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'AllowRowLocks', 27, 'Column', 'Column', 'Enable or disable the ALLOW_ROW_LOCKS option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx Valid inputs: ON OFF', 'varchar (3)');

-------------------- 96, 28: Minion.IndexSettingsTable - AllowPageLocks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'AllowPageLocks', 28, 'Column', 'Column', 'Enable or disable the ALLOW_PAGE_LOCKS option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx Valid inputs: ON OFF', 'varchar (3)');

-------------------- 96, 29: Minion.IndexSettingsTable - WaitAtLowPriority --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'WaitAtLowPriority', 29, 'Column', 'Column', 'Enable or disable the WAIT_AT_LOW_PRIORITY option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'bit');

-------------------- 96, 30: Minion.IndexSettingsTable - MaxDurationInMins --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'MaxDurationInMins', 30, 'Column', 'Column', 'Set the MAX_DURATION option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'int');

-------------------- 96, 31: Minion.IndexSettingsTable - AbortAfterWait --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'AbortAfterWait', 31, 'Column', 'Column', 'Enable or disable the ABORT_AFTER_WAIT option of ALTER INDEX. See http://msdn.microsoft.com/en-us/library/ms188388.aspx Valid inputs: NONE SELF BLOCKERS', 'varchar (20)');

-------------------- 96, 32: Minion.IndexSettingsTable - PushToMinion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'PushToMinion', 32, 'Column', 'Column', 'Save these values to the central Minion server, if it exists. Modifies values for this particular table on the central Minion server. A value of NULL indicates that this feature is off. Functionality not yet supported.', 'bit');

-------------------- 96, 33: Minion.IndexSettingsTable - LogIndexPhysicalStats --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'LogIndexPhysicalStats', 33, 'Column', 'Column', 'Save the current index physical stats to a table.', 'bit');

-------------------- 96, 34: Minion.IndexSettingsTable - IndexScanMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'IndexScanMode', 34, 'Column', 'Column', 'Valid inputs: Detailed Limited NULL A value of NULL indicates that reindexing should use the default (in this case, “LIMITED”).', 'varchar (25)');

-------------------- 96, 35: Minion.IndexSettingsTable - TablePreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'TablePreCode', 35, 'Column', 'Column', 'Code to run for this table, before the index maintenance operations begin for that table. Note: To run precode once before each and every individual table in a database, use the TablePreCode column in Minion.IndexSettingsDB. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar');

-------------------- 96, 36: Minion.IndexSettingsTable - TablePostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'TablePostCode', 36, 'Column', 'Column', 'Code to run for this table, after the index maintenance operations complete for that table. Note: To run postcode once after each and every individual table in a database, use the TablePreCode column in Minion.IndexSettingsDB. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar');

-------------------- 96, 37: Minion.IndexSettingsTable - LogProgress --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'LogProgress', 37, 'Column', 'Column', 'Track the progress of index operations for this table. The overall index maintenance status is tracked in the Minion.IndexMaintLog table, while specific operations are tracked in the Status column Minion.IndexMaintLogDetails.', 'bit');

-------------------- 96, 38: Minion.IndexSettingsTable - LogRetDays --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'LogRetDays', 38, 'Column', 'Column', 'Number of days to retain index maintenance log data, for this table. Just like any setting, if a table-specific row exists (in Minion.IndexSettingTable), those settings take precedence over database level settings. That is, if DB1.Table1 has an entry for LogRetDays=50, and DB1 has an entry for LogRetDays=40, the log will keep 50 days for DB1.Table1. When first implemented, Minion Reindex defaults to 60 days of log retention.', 'smallint');

-------------------- 96, 39: Minion.IndexSettingsTable - PartitionReindex --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'PartitionReindex', 39, 'Column', 'Column', 'Future use.', 'bit');

-------------------- 96, 40: Minion.IndexSettingsTable - isLOB --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'isLOB', 40, 'Column', 'Column', 'Internal use.', 'bit');

-------------------- 96, 41: Minion.IndexSettingsTable - TableType --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'TableType', 41, 'Column', 'Column', 'Internal use.', 'char (1)');

-------------------- 96, 42: Minion.IndexSettingsTable - IncludeUsageDetails --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'IncludeUsageDetails', 42, 'Column', 'Column', 'Save index usage details from sys.dm_db_index_usage_stats, to Minion.IndexMaintLogDetails.', 'bit');

-------------------- 96, 45: Minion.IndexSettingsTable - RebuildHeap --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'RebuildHeap', 45, 'Column', 'Column', 'Whether or not to rebuild heaps. Caution: This will rebuild all the nonclustered indexes on the table.', 'bit');

-------------------- 96, 48: Minion.IndexSettingsTable - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'Discussion', 48, 'Discussion', 'Discussion', 'Insert a new row for a single table in [YourDatabase], if you wish to specify different default values for the reorg threshold, rebuild threshold, fill factor, and so on. 

Important: Any row inserted for an individual table overrides only ALL of the values for that table, whether or not they are specified. Refer to the following for an example: 

ID DBName        SchemaName  TableName  Exclude  ReorgThreshold
1  YourDatabase  dbo         Table1     0        15

The first row specifies values for Table1 in YourDatabase. This row completely overrides all other values for that table. 

When index operations are performed for Table1, only the values from the Table1 row will be used. Even though the ReorgThreshold value may be specified in Minion.IndexSettingsDB for [YourDatabase] – and there is most definitely a default value specified there - Table1 will not use that database-level value.', NULL);

-------------------- 96, 49: Minion.IndexSettingsTable - Examples --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (96, 'Examples', 49, 'Examples', 'Examples', 'Set custom thresholds, fill factor, and PadIndex for Table1. 
INSERT INTO [Minion].[IndexSettingsTable] ( DBName
 , SchemaName
 , TableName
 , Exclude
 , ReorgThreshold
 , RebuildThreshold
 , FILLFACTORopt
 , PadIndex ) 
VALUES (''YourDatabase'' -- DBName
 , ''dbo'' -- SchemaName
 , ''Table1'' -- TableName
 , 0 -- Exclude
 , 15 -- ReorgThreshold
 , 25 -- RebuildThreshold
 , 90 -- FILLFACTORopt
 , ''ON'' -- PadIndex );

NOTE: While it is possible to exclude a single table from reindexing, by setting both the ReorgThreshold and RebuildThreshold above 100% for that database, we do not recommend this approach. Instead, set the Exclude column to 1 for that table. 

NOTE: To ensure a table is reindexed at every run, set the ReorgThreshold at 0%.', NULL);

-------------------- 103, 1: Minion.DBMaintRegexLookup - DetailName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'DetailName', 1, 'DetailName', 'DetailName', 'Minion.DBMaintRegexLookup', NULL);

-------------------- 103, 2: Minion.DBMaintRegexLookup - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'Purpose', 2, 'Purpose', 'Purpose', 'Allows you to exclude databases from index maintenance (or all maintenance), based off of regular expressions.', NULL);

-------------------- 103, 3: Minion.DBMaintRegexLookup - Action --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'Action', 3, 'Column', 'Column', 'Action to perform with this regular expression. Valid inputs: EXCLUDE', 'varchar (10)');

-------------------- 103, 4: Minion.DBMaintRegexLookup - MaintType --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'MaintType', 4, 'Column', 'Column', 'Maintenance type to which this applies. Valid inputs: ALL REINDEX', 'varchar (20)');

-------------------- 103, 5: Minion.DBMaintRegexLookup - Regex --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'Regex', 5, 'Column', 'Column', 'Regular expression to match a database name, or set of database names.', 'nvarchar (2000)');

-------------------- 103, 6: Minion.DBMaintRegexLookup - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'Discussion', 6, 'Discussion', 'Discussion', 'Discussion This table is meant to be inclusive for all maintenance operations. (Minion will, in future, be more than just an excellent reindex solution.) Therefore, the MaintType column is important. By specifying ''All'' you ensure that all databases that satisfy the regex expression are excluded from all maintenance operations (Reindex, Backup, CheckDB, Update Statistics, etc.). This is an excellent way to shotgun groups of databases and exclude them from all maintenance. However, if you want to only exclude the databases from reindexing, set MaintType to ''Reindex''.', NULL);

-------------------- 103, 7: Minion.DBMaintRegexLookup - Examples --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (103, 'Examples', 7, 'Examples', 'Examples', 'Example 1 To exclude any database named “Minion” followed by one or more characters, from ALL database maintenance routines, insert the following row: INSERT INTO Minion.DBMaintRegexLookup ( [Action], MaintType, RegEx ) VALUES ( ''Exclude'', ''All'', ''Minion\w+'' ); Example 2 To exclude any database named “ADB” followed by one or more decimal digits, from index maintenance, insert the following row: INSERT INTO Minion.DBMaintRegexLookup ( [Action], MaintType, RegEx ) VALUES ( ''Exclude'', ''Reindex'', ''ADB\d+'' ); These databases will still be processed in the backups, CheckDB, and other maintenance operations, if those Minion modules are running on your instance.', NULL);

-------------------- 97, 2: Minion.IndexPhysicalStats - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'Purpose', 2, 'Purpose', 'Purpose', 'Stores the raw data from sys.dm_db_index_physical_stats. You can optionally save index size and fragmentation information to Minion.IndexPhysicalStats for use in investigating issues, as needed. To turn on IndexPhysicalStats logging, set the LogIndexPhysicalStats field to 1 for a database or table (in Minion.IndexSettingsDB or Minion.IndexSettingsTable, respectively). Data will be saved to Minion.IndexPhysicalStats for each index maintenance run thereafter. WARNING: LogIndexPhysicalStats is turned off by default because it can generate large amounts of data, and the table is currently not part of the log retention cleanup process. We recommend you use this feature only as needed. NOTE: Even if LogIndexPhysicalStats is enabled, this table will not store data for any table or database that is excluded from index maintenance, because the index process does not gather fragmentation stats for excluded tables\databases.', NULL);

-------------------- 97, 3: Minion.IndexPhysicalStats - ExecutionDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'ExecutionDateTime', 3, 'Column', 'Column', 'The execution date and time, common to the entire run of a database index maintenance event.', 'datetime');

-------------------- 97, 4: Minion.IndexPhysicalStats - BatchDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'BatchDateTime', 4, 'Column', 'Column', 'Date and time the index physical stats data was gathered.', 'datetime');

-------------------- 97, 5: Minion.IndexPhysicalStats - IndexScanMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'IndexScanMode', 5, 'Column', 'Column', 'Scan level that is used to obtain statistics. This is equivalent to the ‘mode’ input for sys.dm_index_physical_stats.', 'varchar (25)');

-------------------- 97, 6: Minion.IndexPhysicalStats - DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'DBName', 6, 'Column', 'Column', 'Database name.', 'nvarchar');

-------------------- 97, 7: Minion.IndexPhysicalStats - SchemaName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'SchemaName', 7, 'Column', 'Column', 'Schema name.', 'nvarchar');

-------------------- 97, 8: Minion.IndexPhysicalStats - TableName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'TableName', 8, 'Column', 'Column', 'Table name.', 'nvarchar');

-------------------- 97, 9: Minion.IndexPhysicalStats - IndexName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'IndexName', 9, 'Column', 'Column', 'Index name.', 'nvarchar');

-------------------- 97, 10: Minion.IndexPhysicalStats - database_id  --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'database_id ', 10, 'Column', 'Column', 'Database ID. See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'smallint');

-------------------- 97, 11: Minion.IndexPhysicalStats - object_id --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'object_id', 11, 'Column', 'Column', 'Object ID. See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'int');

-------------------- 97, 12: Minion.IndexPhysicalStats - index_id --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'index_id', 12, 'Column', 'Column', 'Index ID. See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'int');

-------------------- 97, 13: Minion.IndexPhysicalStats - partition_number --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'partition_number', 13, 'Column', 'Column', 'Partition ID. See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'int');

-------------------- 97, 14: Minion.IndexPhysicalStats - index_type_desc --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'index_type_desc', 14, 'Column', 'Column', 'Description of index type, e.g. HEAP, CLUSTERED, NONCLUSTERED, etc. See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'nvarchar (60)');

-------------------- 97, 15: Minion.IndexPhysicalStats - alloc_unit_type_desc --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'alloc_unit_type_desc', 15, 'Column', 'Column', 'Allocation type unit, e.g. IN_ROW_DATA, LOB_DATA, ROW_OVERFLOW_DATA. * See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'nvarchar (60)');

-------------------- 97, 16: Minion.IndexPhysicalStats - index_depth --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'index_depth', 16, 'Column', 'Column', 'Number of index levels. Note that 1 means the table is a HEAP. See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'tinyint');

-------------------- 97, 17: Minion.IndexPhysicalStats - index_level --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'index_level', 17, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'tinyint');

-------------------- 97, 18: Minion.IndexPhysicalStats - avg_fragmentation_in_percent --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'avg_fragmentation_in_percent', 18, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'float');

-------------------- 97, 19: Minion.IndexPhysicalStats - fragment_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'fragment_count', 19, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 97, 20: Minion.IndexPhysicalStats - avg_fragment_size_in_pages --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'avg_fragment_size_in_pages', 20, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'float');

-------------------- 97, 21: Minion.IndexPhysicalStats - page_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'page_count', 21, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 97, 22: Minion.IndexPhysicalStats - avg_page_space_used_in_percent --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'avg_page_space_used_in_percent', 22, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'float');

-------------------- 97, 23: Minion.IndexPhysicalStats - record_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'record_count', 23, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 97, 24: Minion.IndexPhysicalStats - ghost_record_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'ghost_record_count', 24, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 97, 25: Minion.IndexPhysicalStats - version_ghost_record_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'version_ghost_record_count', 25, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 97, 26: Minion.IndexPhysicalStats - min_record_size_in_bytes --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'min_record_size_in_bytes', 26, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'int');

-------------------- 97, 27: Minion.IndexPhysicalStats - max_record_size_in_bytes --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'max_record_size_in_bytes', 27, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'int');

-------------------- 97, 28: Minion.IndexPhysicalStats - avg_record_size_in_bytes --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'avg_record_size_in_bytes', 28, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'float');

-------------------- 97, 29: Minion.IndexPhysicalStats - forwarded_record_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'forwarded_record_count', 29, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 97, 30: Minion.IndexPhysicalStats - compressed_page_count --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (97, 'compressed_page_count', 30, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188917.aspx', 'bigint');

-------------------- 101, 2: Minion.IndexTableFrag - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'Purpose', 2, 'Purpose', 'Purpose', 'Holds index fragmentation information on a short-term basis, to be used by the currently-running index maintenance process. Minion.IndexTableFrag also holds fragmentation data for prepped operations (created with Minion.IndexMaintMaster with @PrepOnly = 1). PrepOnly data is marked with Prepped = 1 in this table, so Minion Reindex knows the difference between a current process and a prepped process. For more information on these columns, see Minion.IndexMaintDB, Minion.IndexMaintTable, and/or the MSDN article on sys.dm_db_index_physical_stats at http://msdn.microsoft.com/en-us/library/ms188917.aspx', NULL);

-------------------- 101, 3: Minion.IndexTableFrag - ExecutionDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'ExecutionDateTime', 3, 'Column', 'Column', 'The execution date and time, common to the entire run of a database index maintenance event.', 'datetime');

-------------------- 101, 4: Minion.IndexTableFrag - DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'DBName', 4, 'Column', 'Column', 'Database name.', 'nvarchar');

-------------------- 101, 5: Minion.IndexTableFrag - DBID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'DBID', 5, 'Column', 'Column', 'Database ID.', 'int');

-------------------- 101, 6: Minion.IndexTableFrag - TableID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'TableID', 6, 'Column', 'Column', 'Table ID.', 'bigint');

-------------------- 101, 7: Minion.IndexTableFrag - SchemaName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'SchemaName', 7, 'Column', 'Column', 'Schema name.', 'nvarchar');

-------------------- 101, 8: Minion.IndexTableFrag - TableName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'TableName', 8, 'Column', 'Column', 'Table name.', 'nvarchar');

-------------------- 101, 9: Minion.IndexTableFrag - IndexName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IndexName', 9, 'Column', 'Column', 'Index name from sysindexes.', 'nvarchar');

-------------------- 101, 10: Minion.IndexTableFrag - IndexID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IndexID', 10, 'Column', 'Column', 'Index ID.', 'bigint');

-------------------- 101, 11: Minion.IndexTableFrag - IndexType --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IndexType', 11, 'Column', 'Column', 'Index type number, e.g. 0 = HEAP, etc. See http://msdn.microsoft.com/en-us/library/ms173760.aspx', 'tinyint');

-------------------- 101, 12: Minion.IndexTableFrag - IndexTypeDesc --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IndexTypeDesc', 12, 'Column', 'Column', 'Description of index type, e.g. HEAP, CLUSTERED, NONCLUSTERED, etc. See http://msdn.microsoft.com/en-us/library/ms173760.aspx', 'nvarchar (120)');

-------------------- 101, 13: Minion.IndexTableFrag - IsDisabled --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IsDisabled', 13, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms173760.aspx', 'bit');

-------------------- 101, 14: Minion.IndexTableFrag - IsHypothetical --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IsHypothetical', 14, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms173760.aspx', 'bit');

-------------------- 101, 15: Minion.IndexTableFrag - avg_fragmentation_in_percent --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'avg_fragmentation_in_percent', 15, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms173760.aspx', 'float');

-------------------- 101, 16: Minion.IndexTableFrag - ReorgThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'ReorgThreshold', 16, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should reorganize an index. For example, if ReorgThreshold is set to 10 and the RebuildThreshold is 20, then a reorg will be done for all indexes between 10 and 19. And a rebuild will be done for all indexes 20 and above.', 'Tinyint');

-------------------- 101, 17: Minion.IndexTableFrag - RebuildThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'RebuildThreshold', 17, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should rebuild an index. For example, if ReorgThreshold is set to 10 and the RebuildThreshold is 20, then a reorg will be done for all indexes between 10 and 19. And a rebuild will be done for all indexes 20 and above.', 'tinyint');

-------------------- 101, 18: Minion.IndexTableFrag - FillFactorOpt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'FillFactorOpt', 18, 'Column', 'Column', 'Specify how full a reindex maintenance should make each page when it rebuilds an index. For example, a value of 85 would leave each data page 85% full of data. A value of NULL indicates that reindexing should use the current index setting (viewable for that index in sys.indexes).', 'tinyint');

-------------------- 101, 19: Minion.IndexTableFrag - PadIndex --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'PadIndex', 19, 'Column', 'Column', 'Turn PAD_INDEX on or off. Valid inputs: ON OFF A value of NULL indicates that reindexing should use the current index setting (viewable for that index in sys.indexes).', 'varchar (3)');

-------------------- 101, 20: Minion.IndexTableFrag - OnlineOpt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'OnlineOpt', 20, 'Column', 'Column', 'Perform ONLINE index maintenance for indexes in this database. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the system setting (in this case, “OFF”, meaning the index maintenance will be done offline). Note that ONLINE index operations may not be possible for certain editions of SQL Server, and only for indexes that are eligible for ONLINE index operations. If you specify ONLINE when it is not possible, the routine will change it to OFFLINE.', 'varchar (3)');

-------------------- 101, 21: Minion.IndexTableFrag - SortInTempDB --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'SortInTempDB', 21, 'Column', 'Column', 'Direct index maintenance to use TempDB to store the intermediate sort results that are used to build the index. Valid inputs: ON OFF NULL A value of NULL indicates that reindexing should use the system setting (in this case, “OFF”).', 'varchar (3)');

-------------------- 101, 22: Minion.IndexTableFrag - MAXDOPopt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'MAXDOPopt', 22, 'Column', 'Column', 'Specify the max degree of parallelism (“MAXDOP”, the number of CPUs to use) for the index maintenance operations. If specified, this overrides the MAXDOP configuration option for the duration of the index operation.', 'tinyint');

-------------------- 101, 23: Minion.IndexTableFrag - DataCompression --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'DataCompression', 23, 'Column', 'Column', 'The data compression option. The options are as follows: Valid inputs: NONE ROW PAGE COLUMNSTORE COLUMNSTORE_ARCHIVE A NULL value here would indicate DataCompression=''NONE''.', 'varchar (50)');

-------------------- 101, 24: Minion.IndexTableFrag - GetRowCT --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'GetRowCT', 24, 'Column', 'Column', 'Get a rowcount for each table.', 'bit');

-------------------- 101, 25: Minion.IndexTableFrag - GetPostFragLevel --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'GetPostFragLevel', 25, 'Column', 'Column', 'Get the fragmentation level for each index, after the index maintenance operations are complete. This is done on a per index basis as soon as the reindex operation is complete for each index.', 'bit');

-------------------- 101, 26: Minion.IndexTableFrag - UpdateStatsOnDefrag --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'UpdateStatsOnDefrag', 26, 'Column', 'Column', 'Update statistics after defragmenting. This should always be on, but Minion provides the option just in case your stats are handled in some other way.', 'bit');

-------------------- 101, 27: Minion.IndexTableFrag - StatScanOption --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'StatScanOption', 27, 'Column', 'Column', 'Options available for the UPDATE STATISTICS statement (that is, anything that would go in the “WITH” statement). Valid inputs include any of the following options, as a comma-delimited list: FULLSCAN SAMPLE RESAMPLE ON PARTITIONS ... STATS_STREAM ROWCOUNT PAGECOUNT For example, StatScanOption could be set to “SAMPLE 50 PERCENT”, or “FULLSCAN, NORECOMPUTE”.', 'varchar (25)');

-------------------- 101, 28: Minion.IndexTableFrag - IgnoreDupKey --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IgnoreDupKey', 28, 'Column', 'Column', 'Change the option so that for this index, inserts that add (normally illegal) duplicates generate a warning instead of an error. Applies to inserts that occur any time after the index operation. The default is OFF. Valid inputs: ON OFF', 'varchar (3)');

-------------------- 101, 29: Minion.IndexTableFrag - StatsNoRecompute --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'StatsNoRecompute', 29, 'Column', 'Column', 'Disable the automatic statistics update option, AUTO_UPDATE_STATISTICS. Valid inputs: ON OFF', 'varchar (3)');

-------------------- 101, 30: Minion.IndexTableFrag - AllowRowLocks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'AllowRowLocks', 30, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'varchar (3)');

-------------------- 101, 31: Minion.IndexTableFrag - AllowPageLocks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'AllowPageLocks', 31, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'varchar (3)');

-------------------- 101, 32: Minion.IndexTableFrag - WaitAtLowPriority --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'WaitAtLowPriority', 32, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'bit');

-------------------- 101, 33: Minion.IndexTableFrag - MaxDurationInMins --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'MaxDurationInMins', 33, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'int');

-------------------- 101, 34: Minion.IndexTableFrag - AbortAfterWait --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'AbortAfterWait', 34, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188388.aspx', 'varchar (3)');

-------------------- 101, 35: Minion.IndexTableFrag - LogProgress --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'LogProgress', 35, 'Column', 'Column', 'Track the progress of index operations for this database. The overall status is tracked in the Minion.IndexMaintLog table, while specific operations are tracked in the Status column Minion.IndexMaintLogDetails.', 'bit');

-------------------- 101, 36: Minion.IndexTableFrag - LogRetDays --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'LogRetDays', 36, 'Column', 'Column', 'Number of days to retain index maintenance log data, for this table. Just like any setting, if a table-specific row exists (in Minion.IndexSettingTable), those settings take precedence over database level settings. That is, if DB1.Table1 has an entry for LogRetDays=50, and DB1 has an entry for LogRetDays=40, the log will keep 50 days for DB1.Table1. When first implemented, Minion Reindex defaults to 60 days of log retention.', 'smallint');

-------------------- 101, 37: Minion.IndexTableFrag - PushToMinion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'PushToMinion', 37, 'Column', 'Column', 'Save these values to the central Minion server, if it exists. Modifies values for this particular table on the central Minion server. A value of NULL indicates that this feature is off. Functionality not yet supported.', 'bit');

-------------------- 101, 38: Minion.IndexTableFrag - LogIndexPhysicalStats --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'LogIndexPhysicalStats', 38, 'Column', 'Column', 'Save the current index physical stats to a table (Minion.IndexPhysicalStats).', 'bit');

-------------------- 101, 39: Minion.IndexTableFrag - IndexScanMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'IndexScanMode', 39, 'Column', 'Column', 'Valid inputs: Detailed Limited NULL A value of NULL indicates that reindexing should use the default (in this case, “LIMITED”).', 'varchar (25)');

-------------------- 101, 40: Minion.IndexTableFrag - TablePreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'TablePreCode', 40, 'Column', 'Column', 'Code to run for a table, before the index maintenance operations begin for that table. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar (max)');

-------------------- 101, 41: Minion.IndexTableFrag - TablePostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'TablePostCode', 41, 'Column', 'Column', 'Code to run for a table, after the index maintenance operations complete for that table. For more on this topic, see “How To: Run code before or after index maintenance”.', 'nvarchar (max)');

-------------------- 101, 41: Minion.IndexTableFrag - Prepped --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'Prepped', 41, 'Column', 'Column', 'If Prepped=1, this data was entered into the table as a result of running the Minion.IndexMaintMaster stored procedure with @PrepOnly = 1. It is then necessary to run the reindexing routine with @RunPrepped = 1 to use this data. For more on this topic, see “How To: Gather index fragmentation statistics on a different schedule from the reindex routine”. NOTE: There can only be one set of prepared data per database at any given time. When you run @PrepOnly = 1, it enters the data into this table, and deletes any previous prep runs for the database in question. So while you can have as many databases as you like prepped in this table, each database can only have a single prep run.', 'bit');

-------------------- 101, 43: Minion.IndexTableFrag - GroupOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'GroupOrder', 43, 'Column', 'Column', 'Group to which this database belongs. Used solely for determining the order in which databases should be processed for index maintenance. By default, all tables have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects. Higher numbers have a greater “weight” (they have a higher priority), and will be indexed earlier than lower numbers. The range of ReindexGroupOrder weight numbers is 0-255. For more information, see “How To: Reindex databases in a specific order”.', 'int');

-------------------- 101, 44: Minion.IndexTableFrag - ReindexOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'ReindexOrder', 44, 'Column', 'Column', 'The index maintenance order within a group. Used solely for determining the order in which databases should be processed for index maintenance. By default, all tables have a value of 0, which means they’ll be processed in the order they’re queried from sysobjects. Higher numbers have a greater “weight” (they have a higher priority), and will be indexed earlier than lower numbers. We recommend leaving some space between assigned reindex order numbers (e.g., 10, 20, 30) so there is room to move or insert rows in the ordering. For more information, see “How To: Reindex databases in a specific order”.', 'int');


-------------------- 101, 50: Minion.IndexTableFrag - StmtPrefix --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'StmtPrefix', 50, 'Column', 'Column', 'The code that will prefix every reindex statement with a statement of your own.  

For more information, see “How To: Run code before or after index maintenance”', 'nvarchar');

-------------------- 101, 55: Minion.IndexTableFrag - StmtSuffix --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'StmtSuffix', 55, 'Column', 'Column', 'The code that will suffix every reindex statement with a statement of your own.  

For more information, see “How To: Run code before or after index maintenance”', 'nvarchar');

-------------------- 101, 60: Minion.IndexTableFrag - RebuildHeap --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, 'RebuildHeap', 60, 'Column', 'Column', 'Whether or not to rebuild heaps. Caution: This will rebuild all the nonclustered indexes on the table.', 'bit');

-------------------- 101, 55: Minion.IndexTableFrag - * Footnote --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, '* Footnote', 55, '* Footnote', '* Footnote', '* For information on this column, see the sys.indexes article on msdn.microsoft.com', NULL);

-------------------- 101, 60: Minion.IndexTableFrag - ** Footnote --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (101, '** Footnote', 60, '** Footnote', '** Footnote', '** For information on this column, see the sys.dm_db_index_physical_stats article on msdn.microsoft.com', NULL);


-------------------- 100, 2: Minion.IndexMaintLog - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'Purpose', 2, 'Purpose', 'Purpose', 'Holds a database level summary of the maintenance operation. This table stores the parameters and settings that were used during the operation, as well as status and summary information. This information can help with troubleshooting, or just stats gathering when you want to see what has happened between one maintenance run to the next. For example, you can use this to determine why a job has wildly varying run times.', NULL);

-------------------- 100, 3: Minion.IndexMaintLog - ID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'ID', 3, 'Column', 'Column', 'IDENTITY column; primary key row identifier.', 'bigint');

-------------------- 100, 4: Minion.IndexMaintLog - ExecutionDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'ExecutionDateTime', 4, 'Column', 'Column', 'Date and time of the entire run. If several databases are run in the same job then this value will be the same for all of them. Join ExecutionDatetime and DBName with the same columns in the IndexMaintDetails table to see full details.', 'datetime');

-------------------- 100, 5: Minion.IndexMaintLog - Status --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'Status', 5, 'Column', 'Column', 'Status of the current reindex operation. If the database completes without error this column will be set to ''Complete''. If the database encountered errors you will see ''Complete with errors''. This column will also be updated with high level status messages when using the Live Insight feature. To see details of these high level messages check the Status column in the IndexMaintLogDetails table. If the current database is complete and this column doesn''t have ''Complete'' or ''Complete with errors'', then that probably means that the job was stopped either by an unhandled fatal error or manually. Once the job is stopped there is no way to update this column further so it will be stuck in an invalid status.', 'varchar (500)');

-------------------- 100, 6: Minion.IndexMaintLog - DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBName', 6, 'Column', 'Column', 'Database name.', 'sysname');

-------------------- 100, 7: Minion.IndexMaintLog - Tables --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'Tables', 7, 'Column', 'Column', 'Shows whether Offline, Online, or All indexes were processed. Offline indexes are those that have to be done offline because they contain a legacy data type like text, image, etc. Online tables are the ones that can be processed online. If you choose Online for a table and it has an index that must be done offline, then that index will be excluded from processing.', 'varchar (7)');

-------------------- 100, 8: Minion.IndexMaintLog - RunPrepped --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'RunPrepped', 8, 'Column', 'Column', 'This shows that the job was called with this option set to 1. RunPrepped means that a PrepOnly run was executed before in order to store the fragmentation stats for the indexes. See PrepOnly for more details.', 'bit');

-------------------- 100, 9: Minion.IndexMaintLog - PrepOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'PrepOnly', 9, 'Column', 'Column', 'This option is used to prepare a reindexing job for later processing. If you have a tight maintenance window and you don''t have time to query the fragmentation stats, you can run the job with this option earlier in the day and it will take the fragmentation stats and save them. Then later you run it with RunPrepped = 1 and it will use the fragmentation stats you just collected. This allows you to use your entire maintenance window for processing indexes instead of wasting part of it on finding the fragmentation. This setting is setting is incompatible with RunPrepped. One or the other must can be set to 1, but not both. However, they can both be set to 0.', 'bit');

-------------------- 100, 10: Minion.IndexMaintLog - ReorgMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'ReorgMode', 10, 'Column', 'Column', 'Shows that the job was called with either REORG, REBUILD, or All. If set to REORG, tables will only be reorged. This includes tables that are past the RebuildThreshold. However, if REBUILD is used, only tables that are past the RebuildThreshold will be processed. Tables between the ReorgThreshold and RebuildThreshold will be ignored.', 'varchar (7)');

-------------------- 100, 11: Minion.IndexMaintLog - NumTablesProcessed --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'NumTablesProcessed', 11, 'Column', 'Column', 'The number of tables processed for the current database.', 'int');

-------------------- 100, 12: Minion.IndexMaintLog - NumIndexesProcessed --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'NumIndexesProcessed', 12, 'Column', 'Column', 'The number of indexes processed for the current database.', 'int');

-------------------- 100, 13: Minion.IndexMaintLog - NumIndexesRebuilt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'NumIndexesRebuilt', 13, 'Column', 'Column', 'The number of indexes rebuilt for the current database.', 'int');

-------------------- 100, 14: Minion.IndexMaintLog - NumIndexesReorged --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'NumIndexesReorged', 14, 'Column', 'Column', 'The number of indexes reorged for the current database.', 'int');

-------------------- 100, 15: Minion.IndexMaintLog - RecoveryModelChanged --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'RecoveryModelChanged', 15, 'Column', 'Column', '0 or 1. Was the recovery model for the current database changed?', 'bit');

-------------------- 100, 16: Minion.IndexMaintLog - RecoveryModelCurrent --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'RecoveryModelCurrent', 16, 'Column', 'Column', 'This is the recovery model of the database before the reindex operation began.', 'varchar (12)');

-------------------- 100, 17: Minion.IndexMaintLog - RecoveryModelReindex --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'RecoveryModelReindex', 17, 'Column', 'Column', 'This is the recovery model of the database during the operation. The recovery model can be changed in the IndexSettingsDB table.', 'varchar (12)');

-------------------- 100, 18: Minion.IndexMaintLog - SQLVersion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'SQLVersion', 18, 'Column', 'Column', 'The current version of SQL Server.', 'varchar (20)');

-------------------- 100, 19: Minion.IndexMaintLog - SQLEdition --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'SQLEdition', 19, 'Column', 'Column', 'The current edition of SQL Server.', 'varchar (50)');

-------------------- 100, 20: Minion.IndexMaintLog - DBPreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPreCode', 20, 'Column', 'Column', 'Any database-level code that was run before it processed any tables.', 'nvarchar (max)');

-------------------- 100, 21: Minion.IndexMaintLog - DBPostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPostCode', 21, 'Column', 'Column', 'Any database-level code that was run after it processed all the tables.', 'nvarchar (max)');

-------------------- 100, 22: Minion.IndexMaintLog - DBPreCodeBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPreCodeBeginDateTime', 22, 'Column', 'Column', 'Date and time the precode started.', 'datetime');

-------------------- 100, 23: Minion.IndexMaintLog - DBPreCodeEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPreCodeEndDateTime', 23, 'Column', 'Column', 'Date and time the precode ended.', 'datetime');

-------------------- 100, 24: Minion.IndexMaintLog - DBPostCodeBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPostCodeBeginDateTime', 24, 'Column', 'Column', 'Date and time the postcode started.', 'datetime');

-------------------- 100, 25: Minion.IndexMaintLog - DBPostCodeEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPostCodeEndDateTime', 25, 'Column', 'Column', 'Date and time the postcode ended.', 'datetime');

-------------------- 100, 26: Minion.IndexMaintLog - DBPreCodeRunTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPreCodeRunTimeInSecs', 26, 'Column', 'Column', 'How many seconds the precode took.', 'int');

-------------------- 100, 27: Minion.IndexMaintLog - DBPostCodeRunTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'DBPostCodeRunTimeInSecs', 27, 'Column', 'Column', 'How many seconds the postcode took.', 'int');

-------------------- 100, 28: Minion.IndexMaintLog - ExecutionFinishTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'ExecutionFinishTime', 28, 'Column', 'Column', 'Date and time the entire database reindex operation finished.', 'datetime');

-------------------- 100, 29: Minion.IndexMaintLog - ExecutionRunTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'ExecutionRunTimeInSecs', 29, 'Column', 'Column', 'How many seconds the database reindex operation took.', 'int');

-------------------- 100, 35: Minion.IndexMaintLog - IncludeDBs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'IncludeDBs', 35, 'Column', 'Column', 'A comma-delimited list of database names, and/or wildcard strings, included in the operation.', 'nvarchar');
-------------------- 100, 40: Minion.IndexMaintLog - ExcludeDBs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'ExcludeDBs', 40, 'Column', 'Column', 'A comma-delimited list of database names, and/or wildcard strings, excluded from the operation.', 'nvarchar');
-------------------- 100, 45: Minion.IndexMaintLog - RegexDBsIncluded --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'RegexDBsIncluded', 45, 'Column', 'Column', 'A list of databases included in the backup operation via the Minion CheckDB regular expressions feature.', 'nvarchar');
-------------------- 100, 50: Minion.IndexMaintLog - RegexDBsExcluded --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'RegexDBsExcluded', 50, 'Column', 'Column', 'A list of databases excluded from the backup operation via the Minion CheckDB regular expressions feature.', 'nvarchar');
-------------------- 100, 55: Minion.IndexMaintLog - Warnings --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'Warnings', 55, 'Column', 'Column', 'Warnings encountered for the operation.', 'nvarchar');

-------------------- 100, 30: Minion.IndexMaintLog - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (100, 'Discussion', 60, 'Discussion', 'Discussion', 'Discussion: Each row contains the database name, the start and end time of the index maintenance event, and much more.', NULL);

-------------------- 98, 2: Minion.IndexMaintLogDetails - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'Purpose', 2, 'Purpose', 'Purpose', 'Keeps a record of individual index maintenance activities. It contains one time-stamped row for each individual index operation (e.g., a single index rebuild).', NULL);

-------------------- 98, 30: Minion.IndexMaintLogDetails - ID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'ID', 30, 'Column', 'Column', 'Primary key row identifier.', 'int');

-------------------- 98, 31: Minion.IndexMaintLogDetails - ExecutionDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'ExecutionDateTime', 31, 'Column', 'Column', 'Date and time the entire reindex operation took place. If the job were started through IndexMaintMaster then all databases in that run have the same ExecutionDateTime. If the job was run manually from Minion.IndexMaintDB, then this value will only be for this database. It will still have a matching row in the Minion.IndexMaintLog table.', 'datetime');

-------------------- 98, 32: Minion.IndexMaintLogDetails - Status --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'Status', 32, 'Column', 'Column', 'Current status of the index operation. If Live Insight is being used the status updates will appear here. When finished, this column will either read ‘Complete’ or ‘FATAL ERROR: error message’. The one exception is when the job has been run with PrepOnly = 1. When running with PrepOnly = 1, this column is updated with the index fragmentation gather stats. For example, say that you were pulling fragmentation stats for 7 indexes with PrepOnly = 1. The final status message would look something like this: ‘7 of 7: GATHERING FRAG STATS: dbo.fragment.ix_fragment2’. This shows you that all 7 of the fragmentation stats were collected.', 'varchar (500)');

-------------------- 98, 33: Minion.IndexMaintLogDetails - DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'DBName', 33, 'Column', 'Column', 'Database name.', 'nvarchar');

-------------------- 98, 34: Minion.IndexMaintLogDetails - TableID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'TableID', 34, 'Column', 'Column', 'The table ID in sysobjects.', 'bigint');

-------------------- 98, 35: Minion.IndexMaintLogDetails - SchemaName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'SchemaName', 35, 'Column', 'Column', 'Schema name.', 'nvarchar');

-------------------- 98, 36: Minion.IndexMaintLogDetails - TableName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'TableName', 36, 'Column', 'Column', 'Table name.', 'nvarchar');

-------------------- 98, 37: Minion.IndexMaintLogDetails - IndexID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'IndexID', 37, 'Column', 'Column', 'The index ID from sys.indexes.', 'int');

-------------------- 98, 38: Minion.IndexMaintLogDetails - IndexName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'IndexName', 38, 'Column', 'Column', 'The index name from sys.indexes.', 'nvarchar');

-------------------- 98, 39: Minion.IndexMaintLogDetails - IndexTypeDesc --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'IndexTypeDesc', 39, 'Column', 'Column', 'The index type description from sys.indexes.', 'varchar');

-------------------- 98, 40: Minion.IndexMaintLogDetails - IndexScanMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'IndexScanMode', 40, 'Column', 'Column', 'Either NULL, Limited, or Detailed. NULL means that nothing was entered into the column in either Minion.IndexSettingsDB or Minion.IndexSettingsTable and therefore the default (Limited) was used.', 'varchar (25)');

-------------------- 98, 41: Minion.IndexMaintLogDetails - Op --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'Op', 41, 'Column', 'Column', 'Operation. Valid inputs are Reorg or Rebuild. This is the type of operation performed in the current index.', 'varchar (10)');

-------------------- 98, 42: Minion.IndexMaintLogDetails - OnlineOpt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'OnlineOpt', 42, 'Column', 'Column', 'NULL, On, Off. If NULL, then nothing was entered into either the Minion.IndexSettingsDB or Minion.IndexSettingsTable tables, and the default (OFF) is used. So the operation was either done offline or online.', 'tinyint');

-------------------- 98, 43: Minion.IndexMaintLogDetails - ReorgThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'ReorgThreshold', 43, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should reorganize an index.', 'tinyint');

-------------------- 98, 44: Minion.IndexMaintLogDetails - ReindexThreshold --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'ReindexThreshold', 44, 'Column', 'Column', 'The percentage threshold at which Index Maintenance should rebuild an index.', 'tinyint');

-------------------- 98, 45: Minion.IndexMaintLogDetails - FragLevel --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'FragLevel', 45, 'Column', 'Column', 'The fragmentation level of the current index at the time the fragmentation stats were taken. If they were taken earlier in the day as part of a PrepOnly run, then they may not match current fragmentation stats.', 'tinyint');

-------------------- 98, 46: Minion.IndexMaintLogDetails - Stmt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'Stmt', 46, 'Column', 'Column', 'The reindex statement that was run.', 'nvarchar (1000)');

-------------------- 98, 47: Minion.IndexMaintLogDetails - GroupOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'GroupOrder', 47, 'Column', 'Column', 'Group to which this table belongs. Used solely for determining the order in which tables should be processed for index maintenance. Most of the time this will be 0. However, if you choose to take advantage of this feature a row in Minion.IndexSettingsTable will get you there. This is a weighted list so higher numbers are more important and will be processed first. For more information, see “How To: Reindex databases in a specific order”.', 'int');

-------------------- 98, 48: Minion.IndexMaintLogDetails - ReindexOrder --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'ReindexOrder', 48, 'Column', 'Column', 'The ordering of the tables within the previous group. Most of the time this will be 0. However, if you choose to take advantage of this feature a row in Minion.IndexSettingsTable will get you there. This is a weighted list so higher numbers are more important and will be processed first. For more information, see “How To: Reindex databases in a specific order”.', 'int');

-------------------- 98, 49: Minion.IndexMaintLogDetails - PreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PreCode', 49, 'Column', 'Column', 'Any precode run before the table is processed. If the table has multiple indexes the precode will only be run once.', 'nvarchar');

-------------------- 98, 50: Minion.IndexMaintLogDetails - PostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostCode', 50, 'Column', 'Column', 'Any postcode run after the table is processed. If the table has multiple indexes the postcode will only be run once.', 'nvarchar');

-------------------- 98, 51: Minion.IndexMaintLogDetails - OpBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'OpBeginDateTime', 51, 'Column', 'Column', 'Date and time the reindex statement began running.', 'datetime');

-------------------- 98, 52: Minion.IndexMaintLogDetails - OpEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'OpEndDateTime', 52, 'Column', 'Column', 'Date and time the reindex statement finished running.', 'datetime');

-------------------- 98, 53: Minion.IndexMaintLogDetails - OpRunTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'OpRunTimeInSecs', 53, 'Column', 'Column', 'How many seconds the reindex statement took.', 'int');

-------------------- 98, 54: Minion.IndexMaintLogDetails - TableRowCTBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'TableRowCTBeginDateTime', 54, 'Column', 'Column', 'Internal use.', 'datetime');

-------------------- 98, 55: Minion.IndexMaintLogDetails - TableRowCTEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'TableRowCTEndDateTime', 55, 'Column', 'Column', 'Internal use.', 'datetime');

-------------------- 98, 56: Minion.IndexMaintLogDetails - TableRowCTTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'TableRowCTTimeInSecs', 56, 'Column', 'Column', 'Internal use.', 'int');

-------------------- 98, 57: Minion.IndexMaintLogDetails - TableRowCT --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'TableRowCT', 57, 'Column', 'Column', 'The count of rows in the table. Therefore, all indexes for a single table will have the exact same row counts.', 'bigint');

-------------------- 98, 58: Minion.IndexMaintLogDetails - PostFragBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostFragBeginDateTime', 58, 'Column', 'Column', 'Date and time the post fragmentation statement began. The post fragmentation level is explained above in the Minion.IndexSettingsDB and Minion.IndexSettingsTable tables.', 'datetime');

-------------------- 98, 59: Minion.IndexMaintLogDetails - PostFragEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostFragEndDateTime', 59, 'Column', 'Column', 'Date and time the post fragmentation statement finished. The post fragmentation level is explained above in the Minion.IndexSettingsDB and Minion.IndexSettingsTable tables.', 'datetime');

-------------------- 98, 60: Minion.IndexMaintLogDetails - PostFragTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostFragTimeInSecs', 60, 'Column', 'Column', 'How many seconds the post fragmentation stats collection took.', 'int');

-------------------- 98, 61: Minion.IndexMaintLogDetails - PostFragLevel --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostFragLevel', 61, 'Column', 'Column', 'The fragmentation level of the index immediately after the reindex operation finished. This is an excellent way to see the effectiveness of your routines and whether you need to adjust your threshold levels for individual tables.', 'tinyint');

-------------------- 98, 62: Minion.IndexMaintLogDetails - UpdateStatsBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UpdateStatsBeginDateTime', 62, 'Column', 'Column', 'Date and time update statistics began. This will only be populated if the operation is a REORG and the UpdateStatsOnDefrag column in either Minion.IndexSettingsDB or Minion.IndexSettingsTable is set to 1. The value should always be set to 1 unless you have a specific reason not to.', 'datetime');

-------------------- 98, 63: Minion.IndexMaintLogDetails - UpdateStatsEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UpdateStatsEndDateTime', 63, 'Column', 'Column', 'Date and time update statistics finished. This will only be populated if the operation is a REORG and the UpdateStatsOnDefrag column in either Minion.IndexSettingsDB or Minion.IndexSettingsTable is set to 1. The value should always be set to 1 unless you have a specific reason not to.', 'datetime');

-------------------- 98, 64: Minion.IndexMaintLogDetails - UpdateStatsTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UpdateStatsTimeInSecs', 64, 'Column', 'Column', 'How many seconds the update statistics statement took.', 'int');

-------------------- 98, 65: Minion.IndexMaintLogDetails - UpdateStatsStmt --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UpdateStatsStmt', 65, 'Column', 'Column', 'The exact update statistics statement that was run.', 'nvarchar');

-------------------- 98, 66: Minion.IndexMaintLogDetails - PreCodeBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PreCodeBeginDateTime', 66, 'Column', 'Column', 'Date and time the precode for the table began.', 'datetime');

-------------------- 98, 67: Minion.IndexMaintLogDetails - PreCodeEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PreCodeEndDateTime', 67, 'Column', 'Column', 'Date and time the precode for the table finished.', 'datetime');

-------------------- 98, 68: Minion.IndexMaintLogDetails - PreCodeRunTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PreCodeRunTimeInSecs', 68, 'Column', 'Column', 'How many seconds the table precode took.', 'int');

-------------------- 98, 69: Minion.IndexMaintLogDetails - PostCodeBeginDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostCodeBeginDateTime', 69, 'Column', 'Column', 'Date and time the postcode for the table began.', 'datetime');

-------------------- 98, 70: Minion.IndexMaintLogDetails - PostCodeEndDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostCodeEndDateTime', 70, 'Column', 'Column', 'Date and time the postcode for the table finished.', 'datetime');

-------------------- 98, 71: Minion.IndexMaintLogDetails - PostCodeRunTimeInSecs --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'PostCodeRunTimeInSecs', 71, 'Column', 'Column', 'How many seconds the table postcode took.', 'datetime');

-------------------- 98, 72: Minion.IndexMaintLogDetails - UserSeeks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UserSeeks', 72, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 73: Minion.IndexMaintLogDetails - UserScans --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UserScans', 73, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 74: Minion.IndexMaintLogDetails - UserLookups --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UserLookups', 74, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 75: Minion.IndexMaintLogDetails - UserUpdates --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'UserUpdates', 75, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 76: Minion.IndexMaintLogDetails - LastUserSeek --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastUserSeek', 76, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 77: Minion.IndexMaintLogDetails - LastUserScan --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastUserScan', 77, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 78: Minion.IndexMaintLogDetails - LastUserLookup --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastUserLookup', 78, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 79: Minion.IndexMaintLogDetails - LastUserUpdate --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastUserUpdate', 79, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 80: Minion.IndexMaintLogDetails - SystemSeeks --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'SystemSeeks', 80, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 81: Minion.IndexMaintLogDetails - SystemScans --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'SystemScans', 81, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 82: Minion.IndexMaintLogDetails - SystemLookups --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'SystemLookups', 82, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 83: Minion.IndexMaintLogDetails - SystemUpdates --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'SystemUpdates', 83, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'bigint');

-------------------- 98, 84: Minion.IndexMaintLogDetails - LastSystemSeek --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastSystemSeek', 84, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 85: Minion.IndexMaintLogDetails - LastSystemScan --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastSystemScan', 85, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 86: Minion.IndexMaintLogDetails - LastSystemLookup --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastSystemLookup', 86, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 87: Minion.IndexMaintLogDetails - LastSystemUpdate --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'LastSystemUpdate', 87, 'Column', 'Column', 'See http://msdn.microsoft.com/en-us/library/ms188755.aspx', 'datetime');

-------------------- 98, 88: Minion.IndexMaintLogDetails - Warnings --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'Warnings', 88, 'Column', 'Column', 'Reserved for future use.', 'nvarchar');

-------------------- 98, 89: Minion.IndexMaintLogDetails - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (98, 'Discussion', 89, 'Discussion', 'Discussion', 'The data available in this log includes the status of the operation, the object information, the statement used, operation type, reorg and rebuild thresholds, index usage information, and more.', NULL);

-------------------- 99, 5: Minion.IndexMaintSettingsServer - Introduction --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Introduction', 5, 'Discussion', 'Introduction', 'This table contains server-level index maintenance settings, including schedule information. The primary Minion Reindex job runs regularly in conjunction with this table to provide a wide range of Reindex options, all without introducing additional jobs.', NULL);

-------------------- 99, 10: Minion.IndexMaintSettingsServer - ID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'ID', 10, 'Column', 'ID', 'Primary key row identifier.', 'int');

-------------------- 99, 15: Minion.IndexMaintSettingsServer - DBType --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'DBType', 15, 'Column', 'DBType', 'Database type (e.g., System or User). This field is not yet in use.', 'varchar');

-------------------- 99, 20: Minion.IndexMaintSettingsServer - IndexOption --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'IndexOption', 20, 'Column', 'IndexOption', 'Perform maintenance only for indexes marked for online operations; only for those marked for offline operations; or for all indexes.

Valid inputs: 
ONLINE
OFFLINE
ALL

For more information, see “How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF)”', 'varchar');

-------------------- 99, 25: Minion.IndexMaintSettingsServer - ReorgMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'ReorgMode', 25, 'Column', 'ReorgMode', 'Perform maintenance only for indexes that meet the REORG threshold; only for those that meet the REBUILD threshold; or for all indexes that meet either threshold (when this is set to “All”).

Note that for REORG mode, only REORG statements will be generated, even for indexes that are over the rebuild threshold.  For REBUILD, only REBUILD statements will be generated.

Valid inputs: 
All
REORG
REBUILD', 'varchar');

-------------------- 99, 30: Minion.IndexMaintSettingsServer - RunPrepped --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'RunPrepped', 30, 'Column', 'RunPrepped', 'If you''ve collected index fragmentation stats ahead of time by running with PrepOnly = 1, then you can use this option.  It causes the index maintenance to use the saved frag stats.

For more information, see “How To: Gather index fragmentation statistics on a different schedule from the reindex routine”.', 'bit');

-------------------- 99, 35: Minion.IndexMaintSettingsServer - PrepOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'PrepOnly', 35, 'Column', 'PrepOnly', 'Only gets index fragmentation stats, and saves to a table.  This prepares the database to be reindexed.  

If PrepOnly = 1, then RunPrepped must be set to 0.

For more information, see “How To: Gather index fragmentation statistics on a different schedule from the reindex routine”.', 'bit');

-------------------- 99, 40: Minion.IndexMaintSettingsServer - Day --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Day', 40, 'Column', 'Day', 'The day or days to which the settings apply.

See the discussion below for information about Day hierarchy and precedence.

Note that the least frequent “Day” settings – FirstOfYear, LastOfYear, FirstOfMonth, LastOfMonth – only apply to user databases, not to system databases.

Valid values:
Daily
Weekday
Weekend
[an individual day, e.g., Sunday]
FirstOfMonth
LastOfMonth
FirstOfYear
LastOfYear', 'varchar');

-------------------- 99, 45: Minion.IndexMaintSettingsServer - BeginTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'BeginTime', 45, 'Column', 'BeginTime', 'The start time at which this schedule applies. 

IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds); on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0).', 'varchar');

-------------------- 99, 50: Minion.IndexMaintSettingsServer - EndTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'EndTime', 50, 'Column', 'EndTime', 'The end time at which this schedule applies. 

IMPORTANT: Must be in the format hh:mm:ss, or hh:mm:ss:mmm (where mmm is milliseconds); on a 24 hour clock. This means that both ’00:00:00’ and ’08:15:00:000’ are valid times, but ‘8:15:00:000’ is not (because single digit hours must have a leading 0).', 'varchar');

-------------------- 99, 55: Minion.IndexMaintSettingsServer - MaxForTimeframe --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'MaxForTimeframe', 55, 'Column', 'MaxForTimeframe', 'Maximum number of iterations within the specified timeframe (BeginTime to EndTime).

For more information, see “Table based scheduling” in the “Quick Start” section.', 'int');

-------------------- 99, 60: Minion.IndexMaintSettingsServer - FrequencyMins --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'FrequencyMins', 60, 'Column', 'FrequencyMins', 'The frequency (in minutes) that the operation should occur. 

Note that actual frequency also depends on the SQL Agent job schedule. If FrequencyMins = 60, but the job runs every 12 hours, you will only get this operation every 12 hours.

However, if FrequencyMins = 720 (12 hours) and the job runs every hour, this operation will occur every 720 minutes.', 'int');

-------------------- 99, 65: Minion.IndexMaintSettingsServer - CurrentNumOps --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'CurrentNumOps', 65, 'Column', 'CurrentNumOps', 'Count of operation attempts for the particular DBType, IndexOption, and Day, for the current timeframe (BeginTime to EndTime).', 'int');

-------------------- 99, 70: Minion.IndexMaintSettingsServer - NumConcurrentOps --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'NumConcurrentOps', 70, 'Column', 'NumConcurrentOps', 'Not yet in use.', 'tinyint');

-------------------- 99, 75: Minion.IndexMaintSettingsServer - DBInternalThreads --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'DBInternalThreads', 75, 'Column', 'DBInternalThreads', 'Not yet in use.', 'tinyint');

-------------------- 99, 80: Minion.IndexMaintSettingsServer - TimeLimitInMins --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'TimeLimitInMins', 80, 'Column', 'TimeLimitInMins', 'Not yet in use.', 'int');

-------------------- 99, 85: Minion.IndexMaintSettingsServer - LastRunDateTime --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'LastRunDateTime', 85, 'Column', 'LastRunDateTime', 'The last time an operation ran that applied to this particular scenario (DBType, IndexOption, Day, and timeframe).', 'datetime');

-------------------- 99, 90: Minion.IndexMaintSettingsServer - Include --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Include', 90, 'Column', 'Include', 'The value to pass into the @Include parameter of the Minion.IndexMaintMaster job; in other words, the databases to include in this attempt. This may be left NULL (meaning “all databases”).', 'nvarchar');

-------------------- 99, 95: Minion.IndexMaintSettingsServer - Exclude --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Exclude', 95, 'Column', 'Exclude', 'The value to pass into the @Exclude parameter of the Minion.IndexMaintMaster job; in other words, the databases to exclude from this attempt. This may be left NULL (meaning “no exclusions”).', 'nvarchar');

-------------------- 99, 100: Minion.IndexMaintSettingsServer - Schemas --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Schemas', 100, 'Column', 'Schemas', 'Not yet in use.', 'nvarchar');

-------------------- 99, 105: Minion.IndexMaintSettingsServer - Tables --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Tables', 105, 'Column', 'Tables', 'Not yet in use.', 'nvarchar');

-------------------- 99, 110: Minion.IndexMaintSettingsServer - BatchPreCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'BatchPreCode', 110, 'Column', 'BatchPreCode', 'Precode to run before the entire operation.', 'nvarchar');

-------------------- 99, 115: Minion.IndexMaintSettingsServer - BatchPostCode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'BatchPostCode', 115, 'Column', 'BatchPostCode', 'Precode to run after the entire operation.', 'nvarchar');

-------------------- 99, 120: Minion.IndexMaintSettingsServer - Debug --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Debug', 120, 'Column', 'Debug', 'Not yet in use.', 'bit');

-------------------- 99, 125: Minion.IndexMaintSettingsServer - FailJobOnError --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'FailJobOnError', 125, 'Column', 'FailJobOnError', 'Not yet in use.', 'bit');

-------------------- 99, 130: Minion.IndexMaintSettingsServer - FailJobOnWarning --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'FailJobOnWarning', 130, 'Column', 'FailJobOnWarning', 'Not yet in use.', 'bit');

-------------------- 99, 135: Minion.IndexMaintSettingsServer - IsActive --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'IsActive', 135, 'Column', 'IsActive', 'Whether the current row is valid (active); and should be used in the Minion Reindex process.', 'bit');

-------------------- 99, 140: Minion.IndexMaintSettingsServer - Comment --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (99, 'Comment', 140, 'Column', 'Comment', 'For your reference only. You can label each row with a short description and/or purpose.', 'varchar');

-------------------- 119, 2: Overview of Procedures - Overview --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (119, 'Overview', 2, 'Overview', 'Overview', 'Two separate procedures execute index maintenance operations for Minion Reindex: one procedure runs per database, and the other is a “Master” procedure that performs run time logic and calls the DB procedure as appropriate.

In addition, Minion Reindex comes with a Help procedure to provide information about the system itself.

Index maintenance procedures:

  * Minion.IndexMaintMaster – This procedure makes all the decisions on which databases to reindex, and what order they should be in.  
  * Minion.IndexMaintDB – This procedure is called by Minion.IndexMaintMaster to perform index maintenance for a single database. 
  * Minion.HELP – Display help on Minion Reindex objects and concepts.', NULL);

-------------------- 102, 2: Minion.IndexMaintMaster - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, 'Purpose', 2, 'Purpose', 'Purpose', 
'The Minion.IndexMaintMaster procedure makes all the decisions on which databases to reindex, and what order they should be in.  This stored procedure calls the Minion.IndexSettingsDB stored procedure once per each database specified in the parameters; or, if “All” is specified, per each eligible database in sys.databases.

Minion Reindex supports SQL Server databases that are part of an Availability Group (AG). Reindex will run for databases that are not part of an AG, and for AG primaries, but not for databases that act as a secondary in an A scenario. (AG secondary databases do not require index maintenance.)', NULL);

-------------------- 102, 3: Minion.IndexMaintMaster - @IndexOption --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@IndexOption', 3, 'Param', '@IndexOption', 'Perform maintenance only for indexes marked for online operations; only for those marked for offline operations; or for all indexes. Valid inputs: ONLINE OFFLINE ALL For more information, see “How To: Reindex only indexes that are marked ONLINE = ON (or, only ONLINE = OFF)”', 'varchar');

-------------------- 102, 4: Minion.IndexMaintMaster - @ReorgMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@ReorgMode', 4, 'Param', '@ReorgMode', 'Perform maintenance only for indexes that meet the REORG threshold; only for those that meet the REBUILD threshold; or for all indexes that meet either threshold (when this is set to “All”). Note that for REORG mode, only REORG statements will be generated, even for indexes that are over the rebuild threshold. For REBUILD, only REBUILD statements will be generated. Valid inputs: All REORG REBUILD', 'varchar');

-------------------- 102, 5: Minion.IndexMaintMaster - @RunPrepped --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@RunPrepped', 5, 'Param', '@RunPrepped', 'If you''ve collected index fragmentation stats ahead of time by running with @PrepOnly = 1, then you can use this option. It causes the index maintenance to use the saved frag stats. For more information, see “How To: Gather index fragmentation statistics on a different schedule from the reindex routine”.', 'bit');

-------------------- 102, 6: Minion.IndexMaintMaster - @PrepOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@PrepOnly', 6, 'Param', '@PrepOnly', 'Only gets index fragmentation stats, and saves to a table. This prepares the databases to be reindexed. If @PrepOnly = 1, then @RunPrepped must be set to 0. For more information, see “How To: Gather index fragmentation statistics on a different schedule from the reindex routine”.', 'bit');

-------------------- 102, 7: Minion.IndexMaintMaster - @StmtOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@StmtOnly', 7, 'Param', '@StmtOnly', 'Only prints reindex statements. This is an excellent choice for running statements manually; it allows you to pick and choose which indexes you want to do, or just see how many are over the thresholds. For more information, see “How To: Generate reindex statements only”.', 'bit');

-------------------- 102, 8: Minion.IndexMaintMaster - @Include --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@Include', 8, 'Param', '@Include', 'Use @Include to run index maintenance on a specific list of databases, or databases that match a LIKE expression. Alternately, set @Include=’All’ or @Include=NULL to run maintenance on all databases. Examples of valid inputs include: All NULL DBname DBName1, DBname2, etc. DBName%, YourDatabase, Archive%', 'nvarchar');

-------------------- 102, 9: Minion.IndexMaintMaster - @Exclude --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@Exclude', 9, 'Param', '@Exclude', 'Use @Exclude to skip index maintenance for a specific list of databases, or databases that match a LIKE expression. Examples of valid inputs include: DBname DBName1, DBname2, etc. DBName%, YourDatabase, Archive% For more information, see “How To: Exclude databases from index maintenance”.', 'nvarchar');

-------------------- 102, 10: Minion.IndexMaintMaster - @LogProgress --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, '@LogProgress', 10, 'Param', '@LogProgress', 'Track the progress of index operations for this database. The overall status is tracked in the Minion.IndexMaintLog table, while specific operations are tracked in the Status column Minion.IndexMaintLogDetails.', 'bit');

-------------------- 102, 11: Minion.IndexMaintMaster - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (102, 'Discussion', 11, 'Discussion', 'Discussion', 'Discussion: Minion.IndexMaintMaster is the heart and brain of Minion Reindex; it decides what needs to be done and pushes out orders to get it done. A few things you can do with Minion.IndexMaintMaster include: Maintain only indexes that can be done online, only those that can be done offline, or all. Generate and execute only reorganize statements, only rebuild statements, or both. Run the procedure to gather index fragmentation stats, and save them to a table. This prepares the database to be reindexed. Run the procedure without gathering index fragmentation stats. This requires that the index fragmentation data has already been collected. Choose to maintain a specific set of databases, via the @Include parameter. (E.g., @Include=''DB1, DB2, DB3''…) Choose to maintain all databases Choose to maintain all databases, with specific exclusions, via the @Exclude parameter. Only print reindex statements, do not run. This is an excellent choice for running statements manually; it allows you to pick and choose which indexes you want to maintain, or just see how many indexes are over the thresholds. Have every step of the run printed in the log so you can watch the progress (called Live Insight). This option is on by default.', NULL);

-------------------- 95, 2: Minion.IndexMaintDB - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, 'Purpose', 2, 'Purpose', 'Purpose', 'The Minion.IndexMaintDB stored procedure performs index maintenance for a single database. Minion.IndexMaintDB is the procedure that creates and runs the actual reindex statements for tables that meet the criteria stored in the settings tables (Minion.IndexSettingsDB and Minion.IndexSettingsTable). IMPORTANT: We HIGHLY recommend using Minion.IndexMaintMaster for all of your reindex operations, even when reindexing a single database. Do not call Minion.IndexMaintDB to perform index maintenance. The Minion.IndexMaintMaster procedure makes all the decisions on which databases to reindex, and what order they should be in. It''s certainly possible to call Minion.IndexMaintDB manually, to run an individual database, but we instead recommend using the Minion.IndexMaintMaster procedure (and just include the single database using the @Include parameter). First, it unifies your code, and therefore minimizes your effort. By calling the same procedure every time you reduce your learning curve and cut down on mistakes. Second, future functionality may move to the Minion.IndexMaintMaster procedure; if you get used to using Minion.IndexMaintMaster now, then things will always work as intended.', NULL);

-------------------- 95, 3: Minion.IndexMaintDB - @DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, '@DBName', 3, 'Param', '@DBName', 'Name of the database being reindexed.', 'nvarchar');

-------------------- 95, 3: Minion.IndexMaintDB - @IndexOption --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, '@IndexOption', 3, 'Param', '@IndexOption', 'Picks the online option for the indexes. Some indexes can only be rebuilt offline. This option allows you to specify whether you want the online, offline, or all indexes to be processed. This is very common in situations where you don''t want offline reindexing to occur during the week, for example. This way you can run the offline reindexes only during the slow times. Valid Options: All, Online, Offline', 'varchar');

-------------------- 95, 3: Minion.IndexMaintDB - @ReorgMode --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, '@ReorgMode', 3, 'Param', '@ReorgMode', 'Chooses whether you want to do reorgs, rebuilds, or both. Sometimes you don''t want to do rebuilds during the week so you save them for the weekend. With this option you can make sure that you don''t do rebuild during your busy times. Simply create 2 separate jobs, one with REORG and the other with REBUILD or ALL. When using the REORG option, indexes that would ordinarily be rebuilt because they crossed the rebuild threshold, will be reorged instead. When using the REBUILD option, any indexes that fall below the reorg threshold and the rebuild threshold will be ignored. Only indexes that are above the reindex threshold will be processed. Valid Options: REORG, REBUILD, ALL.', 'varchar');

-------------------- 95, 5: Minion.IndexMaintDB - @RunPrepped --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, '@RunPrepped', 5, 'Param', '@RunPrepped', 'Allows you to run the reindex operations off of previously gathered fragmentation stats. Many shops have tight maintenance windows and gathering the index fragmentation stats can take a very long time on large databases. That eats into your maintenance window significantly. This way you can setup a job to run earlier in the day to gather the stats using the @PrepOnly parameter. Then you can run the job during your maintenance window with @RunPrepped = 1.', 'bit');

-------------------- 95, 6: Minion.IndexMaintDB - @PrepOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, '@PrepOnly', 6, 'Param', '@PrepOnly', 'Allows you to gather the index fragmentation stats before your maintenance window. Many shops have tight maintenance windows and gathering the index fragmentation stats can take a very long time on large databases. That eats into your maintenance window significantly. This way you can setup a job to run earlier in the day to gather the stats, using this parameter. Then you can run the job during your maintenance window with the @RunPrepped flag.', 'bit');

-------------------- 95, 7: Minion.IndexMaintDB - @StmtOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, '@StmtOnly', 7, 'Param', '@StmtOnly', 'Allows you to print the reorg or rebuild statements instead of running them. This is helpful when you just want to see which indexes are past their thresholds, and when you want to just pick and choose certain indexes to process. Either way, this is a powerful feature that''s easy to use and notice how we don''t make you alter the procedure to print the statements?', 'bit');

-------------------- 95, 8: Minion.IndexMaintDB - RunPrepped vs PrepOnly --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, 'RunPrepped vs PrepOnly', 8, 'Advice', 'RunPrepped vs PrepOnly', 'The @RunPrepped and @PrepOnly parameters are incompatible. Only one can be turned on at a time. If they''re both turned on this will throw a logic error as you can''t prep the stats and use them at the same time.', NULL);

-------------------- 95, 9: Minion.IndexMaintDB - About --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, 'About', 9, 'Advice', 'About Minion.IndexMaintMaster', 'The Minion.IndexMaintMaster procedure is what makes all the decisions on which datbases to backup, and what order they should be in. You *could* call this one manually if you like if you were going to run an individual database. However, even then the preferred usage is to run the Minion.IndexMaintMaster procedure and just include the single database you''re interested by putting it in the @Include parameter. There are a couple reasons why it is recommended to run the procedures this way. First, it unifies your code and therefore minimizes your effort. By calling the same procedure every time you reduce your learning curve and therefore reducing mistakes. Second, there may be functionality moved to the Minion.IndexMaintMaster procedure in the future and if you get used to using it now, then things will always work as intended.', NULL);

-------------------- 95, 10: Minion.IndexMaintDB - Example 1 --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (95, 'Example 1', 10, 'Example', 'Example 1', 'Coming soon.', NULL);


-------------------- 210, 5: Minion.CloneSettings - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (210, 'Purpose', 10, 'Purpose', 'Purpose', 'This procedure allows you to generate an insert statement for a table, based on a particular row in that table.

We made this procedure flexible: you can enter in the name of any Minion table, and a row ID, and it will generate the insert statement for you.

Note that this function is shared between Minion modules. 

WARNING: This generates a clone of an existing row as an INSERT statement. Before you run that insert, be sure to change key identifying information - e.g., the DBName - before you run the INSERT statement; you would not want to insert a completely identical row.', NULL);

-------------------- 210, 10: Minion.CloneSettings - @TableName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (210, '@TableName', 10, 'Param', 'Param', 'The name of the table to generate an insert statement for.

Note: This can be in the format "Minion.CheckDBSettingsDB" or just " CheckDBSettingsDB".', 'varchar');

-------------------- 210, 15: Minion.CloneSettings - @ID --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (210, '@ID', 15, 'Param', 'Param', 'The ID number of the row you''d like to clone. See the discussion below.', 'int');

-------------------- 210, 20: Minion.CloneSettings - @WithTrans --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (210, '@WithTrans', 20, 'Param', 'Param', 'Include “BEGIN TRANSACTION” and “ROLLBACK TRANSACTION” clauses around the insert statement, for safety.', 'bit');

-------------------- 210, 25: Minion.CloneSettings - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (210, 'Discussion', 25, 'Discussion', 'Discussion', 'Because of the way we have writte Minion CheckDB, you may often need to insert a row that is nearly identical to an existing row. If you want to change just one setting, you still have to fill out 40 columns. For example, you may wish to insert a row to Minion.CheckDBSettingsDB that is only different from the MinionDefault rows in two respects (e.g., DBName and GroupOrder). 

We created Minion.CloneSettings to easily duplicate any existing row in any table. This "helper" procedure lets you pass in the name off the table you would like to insert to, and the ID of the row you want to model the new row off of. The procedure returns an insert statement so you can change the one or two values you want.', NULL);

-------------------- 210, 30: Minion.CloneSettings - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (210, 'Discussion', 30, 'Discussion', 'Discussion: Identity columns', 'If the table in question has an IDENTITY column, regardless of that column’s name, Minion.CloneSettings will be able to use it to select your chosen row. For example, let’s say that the IDENTITY column of Table1 is ObjectID, and that you call Minion.CloneSettings with @ID = 2. The procedure will identify that column and return an INSERT statement that contains the values from the row where ObjectID = 2.', NULL);

-------------------- 215, 5: Minion.DBMaintDBSizeGet - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (215, 'Purpose', 10, 'Purpose', 'Purpose', 'Determines the size of the database passed in through @DBName, as determined by the ThresholdType and ThresholdValue fields in the Minion.CheckDBSettingsAutoThresholds table.

Note that this function is shared between Minion modules. ', NULL);

-------------------- 215, 10: Minion.DBMaintDBSizeGet - @Module --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (215, '@Module', 10, 'Param', 'Param', 'The name of the Minion module.

Valid inputs include:
CHECKDB
', 'varchar');

-------------------- 215, 15: Minion.DBMaintDBSizeGet - @OpName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (215, '@OpName', 15, 'Param', 'Param', 'An output parameter that provides the operation name (e.g., CHECKDB). ', 'varchar');
		
-------------------- 215, 20: Minion.DBMaintDBSizeGet - @DBName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (215, '@DBName', 20, 'Param', 'Param', 'Database name.', 'varchar');

-------------------- 215, 25: Minion.DBMaintDBSizeGet - @DBSize --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (215, '@DBSize', 25, 'Param', 'Param', 'An output parameter that provides the database size, as measured in GB. ', 'decimal');

-------------------- 220, 5: Minion.DBMaintServiceCheck - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (220, 'Purpose', 5, 'Purpose', 'Purpose', 'This procedure checks the SQL Agent run status and returns the result in an output parameter.

Note that this function is shared between Minion modules. ', NULL);

-------------------- 220, 10: Minion.DBMaintServiceCheck - @ServiceStatus --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (220, '@ServiceStatus', 10, 'Param', 'Param', 'Output column that returns the state of the SQL Agent service: running (1), or not running (0).', 'bit');

-------------------- 220, 15: Minion.DBMaintServiceCheck - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (220, 'Example', 15, 'Example', 'Example', 'DECLARE @ServiceStatus BIT;
EXEC Minion.DBMaintServiceCheck @ServiceStatus = @ServiceStatus OUTPUT
SELECT  @ServiceStatus;', NULL);

-------------------- 110, 1: Minion.HELP - DetailName --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (110, 'DetailName', 1, 'DetailName', 'DetailName', 'Minion.HELP', NULL);

-------------------- 110, 2: Minion.HELP - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (110, 'Purpose', 2, 'Purpose', 'Purpose', 'Use this stored procedure to get help on any Minion Reindex object without leaving Management Studio.', NULL);

-------------------- 110, 3: Minion.HELP - @Module --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (110, '@Module', 3, 'Param', '@Module', 'The name of the module to retrieve help for. Valid inputs include: NULL Reindex', 'varchar');

-------------------- 110, 4: Minion.HELP - @Name --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (110, '@Name', 4, 'Param', '@Module', 'The name of the topic for which you would like help. If you run Minion.HELP by itself, or with a @Module specified, it will return a list of available topics.', 'varchar');

-------------------- 110, 5: Minion.HELP - Examples --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (110, 'Examples', 5, 'Examples', 'Examples', 'Examples: For introductory help, run: EXEC Minion.HELP; For introductory help on Minion Reindex, run: EXEC Minion.HELP ''Reindex''; For help on a particular topic – in this case, the Top 10 Features – run: EXEC Minion.HELP ''Reindex'', ''Top 10 Features'';', NULL);

-------------------- 200, 5: Minion.DBMaintSQLInfoGet - Purpose --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (200, 'Purpose', 5, 'Discussion', 'Purpose', 'This function returns a table with information about the current server instance: VersionRaw, Version, Edition, OnlineEdition, Instance, InstanceName, and ServerAndInstance.

Note that this function is shared between Minion modules.', 'NULL');

-------------------- 200, 10: Minion.DBMaintSQLInfoGet - Example execution --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (200, 'Example execution', 10, 'Discussion', 'Example execution', 'SELECT  VersionRaw
      , Version
      , Edition
      , OnlineEdition
      , Instance
      , InstanceName
      , ServerAndInstance
FROM    Minion.DBMaintSQLInfoGet();', 'NULL');


-------------------- 205, 5: Overview of Functions - Overview --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (205, 'Overview', 5, 'Overview', 'Overview', 'Minion Reindex has three functions that are shared among modules: 
  * Minion.DBMaintSQLInfoGet – Returns a table with information about the current server instance: VersionRaw, Version, Edition, OnlineEdition, Instance, InstanceName, and ServerAndInstance.
  * Minion.FormatHelp – Used in the Minion.HELP procedure.
  * Minion.HELPformat – Used in the Minion.HELP procedure.', NULL);


-------------------- 230, 2: Overview of Views - Overview --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (230, 'Overview', 5, 'Overview', 'Overview', 'Minion Reindex comes with two views:
  * Minion.IndexMaintLogCurrent – Provides the most recent batch of high level log entries of index maintenance operations.
  * Minion.IndexMaintLogDetailsCurrent – Provides the most recent batch of detailed log entries of index maintenance operations.', NULL);


-------------------- 120, 2: Overview of Jobs - Overview --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (120, 'Overview', 2, 'Overview', 'Overview', 'When you install Minion Reindex, it creates and schedules a job – MinionReindex-AUTO – to run hourly. The schedule of index maintenance operations is determined by the table Minion.IndexMaintSettingsServer.

For information on changing schedules, see the Quick Start topic “Change Schedules”.', NULL);

--1.3--
-------------------- 130, 2: Revisions - Revisions --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (130, 'Revisions', 2, 'Revisions', 'Revisions', 'Version     Release Date     Changes
1.0         October 2014     * Initial release.

1.1         January 2015     * Minion Reindex now handles nonstandard naming (e.g., object names with spaces or special characters.)
                             * Added support for Availability Group replicas.

1.2         September 2015   Issues resolved:
                             * Fix: MR failed when running on BIN collation.
                             * Fix: Help didn’t install if Minion Backup was installed.
                             * Fix: MR didn’t handle XML and reorganize properly.
                             * Fix: ONLINE/OFFLINE modes were not being handled properly.
                             * Fix: XML indexes were put into ONLINE mode instead of OFFLINE mode.
                             * Fix: Situation where indexes could be processed more than once.
                             * Update: Increased Status column in log tables to varchar(max).
                             * Fix: Status variable in stored procedures had different sizes.
                             * Fix: Wrong syntax created for Wait_at_low_priority option.
                             * Fix: Reports that offline indexes were failing when it’s set to online instead of doing it offline.
New features:
                             * Error trapping and logging is improved.  MR is able to capture many more error situations now, and they all appear in the log table.
                             * Statement Prefix – All of the Settings tables now have a StmtPrefix column.  See document for details. Note: To ensure that your statements run properly, you must end the code in this column with a semicolon.
                             * Statement Suffix – All of the Settings tables now have a StmtSuffix column.  See document for details. Note: To ensure that your statements run properly, you must end the code in this column with a semicolon.

1.3			April 2017	      Issues resolved:
							  * Some errors were not captured in the log tables.
							  * Japanese/international characters in a table name caused errors.
							  * Performance fixes.
							  * Issue with object names in brackets. 
							  * Issue with running PrepOnly then RunPrepped immediately after, in the same window.
							  * Formatting issues in Minion.HELP.
							  * Updated code “section” comments.
							  
							  New features:
							  * Minion.IndexMaintSettingsServer provides table-based scheduling.
							  * Reindex heaps – New logic lets you choose whether to reindex heaps or not.
							  * New Powershell installer.
							  * “Current” views: Minion.IndexMaintLogCurrent and IndexMaintLogDetailsCurrent
							  * MR now uses the DBMaintSQLInfoGet function, like MC and MB do.', NULL);

-------------------- 131, 2: FAQ - FAQ --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (131, 'FAQ', 2, 'FAQ', 'FAQ', 'How do I install Minion Reindex?
     For information on this, see the “Quick Start” on page 1, or use the Minion Reindex help function: EXEC Minion.Help ''Reindex'', ''Quick Start'';

Do I really need SQL Server 2005 or above / xp_cmdshell / PowerShell 2.0?
     Yep. Minion Reindex does an awful lot for you. To simplify a great many things, we’ve decided not to support SQL Server 2000 and previous versions (er, sorry about that), to require xp_cmdshell, and to make use of PowerShell 2.0 or above.  There’s no such thing as a free lunch, they say, but this particular lunch is very very cheap.

Why is Minion Reindex better than [some other index maintenance solution]?
     This is a very big question, and I’m tempted to just point to the entire body of documentation. But briefly: (1) Minion Reindex provides vastly improved logging and insight, including live insight into the active process. (2) It provides ease of management, especially through reducing the number of jobs (or job steps) required. (3) Minion Reindex gives you fine-grained control, in the form of database- and table-level configurations and exclusions. (4) And, Minion Reindex is massively scalable, where other solutions require a “one by one by one” approach to deployment and configuration.

Does Minion Reindex support Availability Groups?
     Yes, as of version 1.1.

Does Minion Reindex support clusters?
     Clusters have no impact on Minion Reindex. So, yes.

I have an old database that has objects named with keywords and spaces. Does Minion handle that?
     Yes, as of version 1.1.

Have a questions? Get in contact at http://www.midnightsql.com/contact-me/ ', NULL);

-------------------- 121, 2: About Us - About --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (121, 'About', 2, 'About', 'About', 'Minion by MidnightDBA is a creation of Jen and Sean McCown, owners of MidnightSQL Consulting, LLC.

In our “MidnightSQL” consulting work, we perform a full range of databases services that revolve around SQL Server. We’ve got over 30 years of experience between us and we''ve seen and done almost everything there is to do.  We have two decades of experience managing large enterprises, and we bring that straight to you. Take a look at www.MidnightSQL.com for more information on what we can do for you and your databases.

Under the “MidnightDBA” banner, we make free technology tutorials, blogs, and a live weekly webshow (DBAs@Midnight). We cover various aspects of SQL Server and PowerShell, technology news, and whatever else strikes our fancy. You’ll also find recordings of our classes – we speak at user groups and conferences internationally – and of our webshow. Check all of that out at www.MidnightDBA.com 

We are both “MidnightDBA” and “MidnightSQL”…the terms are nearly interchangeable, but we tend to keep all of our free stuff under the MidnightDBA banner, and paid services under MidnightSQL Consulting, LLC. Feel free to call us the MidnightDBAs, those MidnightSQL guys, or just “Sean” and “Jen”. We''re all good.', NULL);

-------------------- 125, 1: Troubleshoot: ONLINE was set, but all or some of the indexes are being done OFFLINE. - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (125, 'Discussion', 1, 'Discussion', 'Troubleshoot: ONLINE was set, but all or some of the indexes are being done OFFLINE.', 'Minion Reindexing strives to run no matter what.  If you’ve got the ONLINEopt column set and some indexes are being done OFFLINE, then you could be on an edition of SQL Server that doesn’t support online reindexing.  In this case, Minion Reindexing will change it to OFFLINE mode for you.  

You could also have a legacy data type in the index itself, and for versions of SQL Server under 2014, this automatically means OFFLINE mode reindexing.  These legacy types are varchar(max), nvarchar(max), text, image, and also includes, xml, and the spatial data types.  If it’s a clustered index in question, it’ll be done offline if the table itself has a legacy data type.  This is a SQL Server limitation.', NULL);

-------------------- 126, 1: Troubleshoot: Why is a certain database not being processed? - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (126, 'Discussion', 1, 'Discussion', 'Troubleshoot: Why is a certain database not being processed?', 'There are a few reasons why a database could be skipped.  
1.	It could be excluded in the @Excluded parameter of the SP.
2.	It could be excluded in the Exclude column in the Minion.IndexSettingsDB table.
3.	It could be excluded in the Minion. DBMaintRegexLookup table.
4.	It could be OFFLINE or some other troubled state.
5.	There could be no indexes in the database or none of them have exceeded the threshold.
6.	There could be a missing entry for ‘MinionDefault’ in the Minion.IndexSettingsDB table.

', NULL);

-------------------- 127, 1: Troubleshoot: Nothing happens when I run a specific database. - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (127, 'Discussion', 1, 'Discussion', 'Troubleshoot: Nothing happens when I run a specific database.', 'There are a few reasons you could see this behavior.
1.	There could be no indexes in the database or none of them have exceeded the threshold.
2.	The settings in the tables could be incorrect or missing.  While there are few columns in the settings tables that are mandatory, there are some.  ReorgThreshold, RebuildThreshold, Exclude, ReindexGroupOrder, ReindexOrder are the only columns I can think of that need to be populated.
3.	The SP was set with @RunPrepped = 1 and there are no rows in the Minion.IndexTableFrag table for that database.  This is because the PrepOnly was never run or failed.
4.	You’re running it with @StmtOnly  = 1.

', NULL);

-------------------- 128, 1: Troubleshoot: Some tables aren’t reindexing at the proper threshold. - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (128, 'Discussion', 1, 'Discussion', 'Troubleshoot: Some tables aren’t reindexing at the proper threshold.', 'The only thing that might cause this would be a table override.  Check that the Minion.IndexSettingsTable table doesn’t have an entry for the problem tables.', NULL);

-------------------- 129, 1: Troubleshoot: Not all indexes in the Minion.IndexMaintLogDetails table are marked "Complete". - Discussion --------------------
INSERT #HELPObjectDetail ([ObjectID], [DetailName], [Position], [DetailType], [DetailHeader], [DetailText], [DataType]) 
VALUES (129, 'Discussion', 1, 'Discussion', 'Troubleshoot: Not all indexes in the Minion.IndexMaintLogDetails table are marked "Complete".', 'This is often do to an unhandled exception or caused by someone manually stopping the routine before it is finished.  Unhandled exceptions aren’t very common but there are still some errors that can halt the database run.', NULL);


--------------------------------------------------------------
--------------------------------------------------------------
-------------END HELPObjectDetail inserts-------------------
--------------------------------------------------------------
--------------------------------------------------------------

--&--------------------------------------------
-- 4. Insert all HELPObjects

INSERT  INTO Minion.HELPObjects
        ( [Module] ,
          [ObjectName] ,
          [ObjectType] ,
          [MinionVersion] ,
          [GlobalPosition]
        )
        SELECT  [Module] ,
                [ObjectName] ,
                [ObjectType] ,
                [MinionVersion] ,
                [GlobalPosition]
        FROM    #HELPObjects;


--&--------------------------------------------
-- 5. Update #HELPObjects and #HELPObjectDetails with the new object IDs from Minion.HELPObjects
UPDATE  HO
SET     NewObjectID = MHO.ID
FROM    #HELPObjects AS HO
        JOIN Minion.HELPObjects AS MHO ON ISNULL(HO.[Module], '') = ISNULL(MHO.[Module],'')
                AND ISNULL(HO.[ObjectName], '') = ISNULL(MHO.[ObjectName],'')
                AND ISNULL(HO.[ObjectType], '') = ISNULL(MHO.[ObjectType],'')
                AND ISNULL(HO.[MinionVersion], 1) = ISNULL(MHO.[MinionVersion],1)
                AND ISNULL(HO.[GlobalPosition], 1) = ISNULL(MHO.[GlobalPosition],1);

UPDATE  HDO
SET     HDO.ObjectID = HO.NewObjectID ,
        updated = 1
FROM    #HELPObjectDetail HDO
        JOIN #HELPObjects HO ON HDO.ObjectID = HO.ID;

--&--------------------------------------------
-- 6. Insert all HELPObjectDetail rows
INSERT  INTO Minion.HELPObjectDetail
        ( [ObjectID] ,
          [DetailName] ,
          [Position] ,
          [DetailType] ,
          [DetailHeader] ,
          [DetailText] ,
          [DataType] 
        )
        SELECT  [ObjectID] ,
                [DetailName] ,
                [Position] ,
                [DetailType] ,
                [DetailHeader] ,
                [DetailText] ,
                [DataType] 
        FROM    #HELPObjectDetail
        ORDER BY [ObjectID] ,
                [Position];


--&--------------------------------------------
-- 7. Cleanup

DROP TABLE #HELPObjectDetail;
DROP TABLE #HELPObjects;


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
-----------------------------------END Help Data Insert-----------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
