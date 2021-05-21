/*************************************
 Let's create our parsing function... 
*************************************/

if exists
(
	select object_id
	from sys.objects
	where name = 'udf_parseString'
) 
	drop function dbo.udf_parseString;
go

create function dbo.udf_parseString
(
	@stringToParse varchar(8000), 
	@delimiter     char(1)) 
returns @parsedString table
(
	stringValue varchar(128)) 
as

/********************************************************************************
    Name:       udf_parseString 
    Author:     Michelle Ufford, http://sqlfool.com 
    Purpose:    This function parses string input using a variable delimiter. 
    Notes:      Two common delimiter values are space (' ') and comma (',')
    
	Date        Initials    Description
    ----------------------------------------------------------------------------
    2011-05-20  MFU         Initial Release
*********************************************************************************
Usage: 		
    SELECT *
    FROM udf_parseString(<string>, <delimiter>);
 
Test Cases:
 
    1.  multiple strings separated by space
        SELECT * FROM dbo.udf_parseString('  aaa  bbb  ccc ', ' ');
 
    2.  multiple strings separated by comma
        SELECT * FROM dbo.udf_parseString(',aaa,bbb,,,ccc,', ',');
********************************************************************************/

	begin

/******************
 Declare variables 
******************/

		declare @trimmedString varchar(8000);

/***********************************************************************
 We need to trim our string input in case the user entered extra spaces 
***********************************************************************/

		set @trimmedString = LTRIM(RTRIM(@stringToParse));

/*************************************************************
 Let's create a recursive CTE to break down our string for us 
*************************************************************/

		with parseCTE(StartPos, 
					  EndPos)
			 as (select 1 as StartPos, 
						CHARINDEX(@delimiter, @trimmedString + @delimiter) as EndPos
				 union all
				 select EndPos + 1 as StartPos, 
						CHARINDEX(@delimiter, @trimmedString + @delimiter, EndPos + 1) as EndPos
				 from parseCTE
				 where CHARINDEX(@delimiter, @trimmedString + @delimiter, EndPos + 1) <> 0)

/***********************************************
 Let's take the results and stick it in a table 
***********************************************/

			 insert into @parsedString
			 select SUBSTRING(@trimmedString, StartPos, EndPos - StartPos)
			 from parseCTE
			 where LEN(LTRIM(RTRIM(SUBSTRING(@trimmedString, StartPos, EndPos - StartPos)))) > 0 option(maxrecursion 8000);

		return;
	end;
go

/*************************************************************************
 First, we need to take care of schema updates, in case you have a legacy 
   version of the script installed 
*************************************************************************/

declare @indexDefragLog_rename       varchar(128), 
		@indexDefragExclusion_rename varchar(128), 
		@indexDefragStatus_rename    varchar(128);

select @indexDefragLog_rename = 'dba_indexDefragLog_obsolete_' + CONVERT(varchar(10), GETDATE(), 112), 
	   @indexDefragExclusion_rename = 'dba_indexDefragExclusion_obsolete_' + CONVERT(varchar(10), GETDATE(), 112);

if exists
(
	select object_id
	from sys.indexes
	where name = 'PK_indexDefragLog'
) 
	execute sp_rename dba_indexDefragLog, @indexDefragLog_rename;

if exists
(
	select object_id
	from sys.indexes
	where name = 'PK_indexDefragExclusion'
) 
	execute sp_rename dba_indexDefragExclusion, @indexDefragExclusion_rename;

if not exists
(
	select object_id
	from sys.indexes
	where name = 'PK_indexDefragLog_v40'
) 
begin

	create table dbo.dba_indexDefragLog
	(
		indexDefrag_id  int identity(1, 1) not null, 
		databaseID      int not null, 
		databaseName    nvarchar(128) not null, 
		objectID        int not null, 
		objectName      nvarchar(128) not null, 
		indexID         int not null, 
		indexName       nvarchar(128) not null, 
		partitionNumber smallint not null, 
		fragmentation   float not null, 
		page_count      int not null, 
		dateTimeStart   datetime not null, 
		dateTimeEnd     datetime null, 
		durationSeconds int null, 
		sqlStatement    varchar(4000) null, 
		errorMessage    varchar(1000) null
									  constraint PK_indexDefragLog_v40 primary key clustered (indexDefrag_id));

	print 'dba_indexDefragLog Table Created';
end;

if not exists
(
	select object_id
	from sys.indexes
	where name = 'PK_indexDefragExclusion_v40'
) 
begin

	create table dbo.dba_indexDefragExclusion
	(
		databaseID    int not null, 
		databaseName  nvarchar(128) not null, 
		objectID      int not null, 
		objectName    nvarchar(128) not null, 
		indexID       int not null, 
		indexName     nvarchar(128) not null, 
		exclusionMask int not null

/********************************************************************************
 1=Sunday, 2=Monday, 4=Tuesday, 8=Wednesday, 16=Thursday, 32=Friday, 64=Saturday 
********************************************************************************/

						  constraint PK_indexDefragExclusion_v40 primary key clustered (databaseID, objectID, indexID));

	print 'dba_indexDefragExclusion Table Created';
end;

if not exists
(
	select object_id
	from sys.indexes
	where name = 'PK_indexDefragStatus_v40'
) 
begin

	create table dbo.dba_indexDefragStatus
	(
		databaseID       int not null, 
		databaseName     nvarchar(128) not null, 
		objectID         int not null, 
		indexID          int not null, 
		partitionNumber  smallint not null, 
		fragmentation    float not null, 
		page_count       int not null, 
		range_scan_count bigint not null, 
		schemaName       nvarchar(128) null, 
		objectName       nvarchar(128) null, 
		indexName        nvarchar(128) null, 
		scanDate         datetime not null, 
		defragDate       datetime null, 
		printStatus      bit default 0 not null, 
		exclusionMask    int default 0 not null
									   constraint PK_indexDefragStatus_v40 primary key clustered (databaseID, objectID, indexID, partitionNumber));

	print 'dba_indexDefragStatus Table Created';
end;

if OBJECTPROPERTY(OBJECT_ID('dbo.sp_IndexDefrag'), N'IsProcedure') = 1
begin
	drop procedure dbo.sp_IndexDefrag;
	print 'Procedure sp_IndexDefrag dropped';
end;
go

create procedure dbo.sp_IndexDefrag

/*******************
 Declare Parameters 
*******************/

	@minFragmentation    float         = 10.0,

/*****************************************************************
 in percent, will not defrag if fragmentation less than specified 
*****************************************************************/

	@rebuildThreshold    float         = 30.0,

/***********************************************************************************
 in percent, greater than @rebuildThreshold will result in rebuild instead of reorg 
***********************************************************************************/

	@executeSQL          bit           = 1,

/************************************
 1 = execute; 0 = print command only 
************************************/

	@defragOrderColumn   nvarchar(20)  = 'range_scan_count',

/***************************************************************
 Valid options are: range_scan_count, fragmentation, page_count 
***************************************************************/

	@defragSortOrder     nvarchar(4)   = 'DESC',

/*****************************
 Valid options are: ASC, DESC 
*****************************/

	@timeLimit           int           = 720,

/**********************
 defaulted to 12 hours 
**********************/

/***********************************************
 Optional time limitation; expressed in minutes 
***********************************************/

	@database            varchar(128)  = null,

/****************************************************************************************
 Option to specify one or more database names, separated by commas; NULL will return all 
****************************************************************************************/

	@tableName           varchar(4000) = null, -- databaseName.schema.tableName

/*****************************************************
 Option to specify a table name; null will return all 
*****************************************************/

	@forceRescan         bit           = 0,

/********************************************************************************************
 Whether or not to force a rescan of indexes; 1 = force, 0 = use existing scan, if available 
********************************************************************************************/

	@scanMode            varchar(10)   = N'LIMITED',

/*******************************************
 Options are LIMITED, SAMPLED, and DETAILED 
*******************************************/

	@minPageCount        int           = 8,

/************************************
  MS recommends > 1 extent (8 pages) 
************************************/

	@maxPageCount        int           = null,

/****************
 NULL = no limit 
****************/

	@excludeMaxPartition bit           = 0,

/**************************************************************************************
 1 = exclude right-most populated partition; 0 = do not exclude; see notes for caveats 
**************************************************************************************/

	@onlineRebuild       bit           = 1,

/************************************************************
 1 = online rebuild; 0 = offline rebuild; only in Enterprise 
************************************************************/

	@sortInTempDB        bit           = 1,

/*****************************************************************************************
 1 = perform sort operation in TempDB; 0 = perform sort operation in the index's database 
*****************************************************************************************/

	@maxDopRestriction   tinyint       = null,

/**********************************************************************************
 Option to restrict the number of processors for the operation; only in Enterprise 
**********************************************************************************/

	@printCommands       bit           = 0,

/**********************************************
 1 = print commands; 0 = do not print commands 
**********************************************/

	@printFragmentation  bit           = 0,

/*****************************************
 1 = print fragmentation prior to defrag; 
           0 = do not print 
*****************************************/

	@defragDelay         char(8)       = '00:00:05',

/*************************************
 time to wait between defrag commands 
*************************************/

	@debugMode           bit           = 0

/*********************************************************************
 display some useful comments to help determine if/WHERE issues occur 
*********************************************************************/

as
begin

/***************************************************************************************
    Name:       sp_IndexDefrag

    Author:     Michelle Ufford, http://sqlfool.com

    Purpose:    Defrags one or more indexes for one or more databases

    Notes:

    CAUTION: TRANSACTION LOG SIZE SHOULD BE MONITORED CLOSELY WHEN DEFRAGMENTING.
             DO NOT RUN UNATTENDED ON LARGE DATABASES DURING BUSINESS HOURS.

      @minFragmentation     defaulted to 10%, will not defrag if fragmentation 
                            is less than that
      
      @rebuildThreshold     defaulted to 30% AS recommended by Microsoft in BOL;
                            greater than 30% will result in rebuild instead

      @executeSQL           1 = execute the SQL generated by this proc; 
                            0 = print command only

      @defragOrderColumn    Defines how to prioritize the order of defrags.  Only
                            used if @executeSQL = 1.  
                            Valid options are: 
                            range_scan_count = count of range and table scans on the
                                               index; in general, this is what benefits 
                                               the most FROM defragmentation
                            fragmentation    = amount of fragmentation in the index;
                                               the higher the number, the worse it is
                            page_count       = number of pages in the index; affects
                                               how long it takes to defrag an index

      @defragSortOrder      The sort order of the ORDER BY clause.
                            Valid options are ASC (ascending) or DESC (descending).

      @timeLimit            Optional, limits how much time can be spent performing 
                            index defrags; expressed in minutes.

                            NOTE: The time limit is checked BEFORE an index defrag
                                  is begun, thus a long index defrag can exceed the
                                  time limitation.

      @database             Optional, specify specific database name to defrag;
                            If not specified, all non-system databases will
                            be defragged.

      @tableName            Specify if you only want to defrag indexes for a 
                            specific table, format = databaseName.schema.tableName;
                            if not specified, all tables will be defragged.

      @forceRescan          Whether or not to force a rescan of indexes.  If set
                            to 0, a rescan will not occur until all indexes have
                            been defragged.  This can span multiple executions.
                            1 = force a rescan
                            0 = use previous scan, if there are indexes left to defrag

      @scanMode             Specifies which scan mode to use to determine
                            fragmentation levels.  Options are:
                            LIMITED - scans the parent level; quickest mode,
                                      recommended for most cases.
                            SAMPLED - samples 1% of all data pages; if less than
                                      10k pages, performs a DETAILED scan.
                            DETAILED - scans all data pages.  Use great care with
                                       this mode, AS it can cause performance issues.

      @minPageCount         Specifies how many pages must exist in an index in order 
                            to be considered for a defrag.  Defaulted to 8 pages, AS 
                            Microsoft recommends only defragging indexes with more 
                            than 1 extent (8 pages).  

                            NOTE: The @minPageCount will restrict the indexes that
                            are stored in dba_indexDefragStatus table.

      @maxPageCount         Specifies the maximum number of pages that can exist in 
                            an index and still be considered for a defrag.  Useful
                            for scheduling small indexes during business hours and
                            large indexes for non-business hours.

                            NOTE: The @maxPageCount will restrict the indexes that
                            are defragged during the current operation; it will not
                            prevent indexes FROM being stored in the 
                            dba_indexDefragStatus table.  This way, a single scan
                            can support multiple page count thresholds.

      @excludeMaxPartition  If an index is partitioned, this option specifies whether
                            to exclude the right-most populated partition.  Typically,
                            this is the partition that is currently being written to in
                            a sliding-window scenario.  Enabling this feature may reduce
                            contention.  This may not be applicable in other types of 
                            partitioning scenarios.  Non-partitioned indexes are 
                            unaffected by this option.
                            1 = exclude right-most populated partition
                            0 = do not exclude

      @onlineRebuild        1 = online rebuild; 
                            0 = offline rebuild

      @sortInTempDB         Specifies whether to defrag the index in TEMPDB or in the
                            database the index belongs to.  Enabling this option may
                            result in faster defrags and prevent database file size 
                            inflation.
                            1 = perform sort operation in TempDB
                            0 = perform sort operation in the index's database 

      @maxDopRestriction    Option to specify a processor limit for index rebuilds

      @printCommands        1 = print commands to screen; 
                            0 = do not print commands

      @printFragmentation   1 = print fragmentation to screen;
                            0 = do not print fragmentation

      @defragDelay          Time to wait between defrag commands; gives the
                            server a little time to catch up 

      @debugMode            1 = display debug comments; helps with troubleshooting
                            0 = do not display debug comments

    Called by:  SQL Agent Job or DBA

    ----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------
    LICENSE: 
    This index defrag script is free to download and use for personal, educational, 
    and internal corporate purposes, provided that this header is preserved. 
    Redistribution or sale of this index defrag script, in whole or in part, is 
    prohibited without the author's express written consent.
    ----------------------------------------------------------------------------
    Date        Initials	Version Description
    ----------------------------------------------------------------------------
    2007-12-18  MFU         1.0     Initial Release
    2008-10-17  MFU         1.1     Added @defragDelay, CIX_temp_indexDefragList
    2008-11-17  MFU         1.2     Added page_count to log table
                                    , added @printFragmentation option
    2009-03-17  MFU         2.0     Provided support for centralized execution
                                    , consolidated Enterprise & Standard versions
                                    , added @debugMode, @maxDopRestriction
                                    , modified LOB and partition logic  
    2009-06-18  MFU         3.0     Fixed bug in LOB logic, added @scanMode option
                                    , added support for stat rebuilds (@rebuildStats)
                                    , support model and msdb defrag
                                    , added columns to the dba_indexDefragLog table
                                    , modified logging to show "in progress" defrags
                                    , added defrag exclusion list (scheduling)
    2009-08-28  MFU         3.1     Fixed read_only bug for database lists
    2010-04-20  MFU         4.0     Added time limit option
                                    , added static table with rescan logic
                                    , added parameters for page count & SORT_IN_TEMPDB
                                    , added try/catch logic and additional debug options
                                    , added options for defrag prioritization
                                    , fixed bug for indexes with allow_page_lock = off
                                    , added option to exclude right-most partition
                                    , removed @rebuildStats option
                                    , refer to http://sqlfool.com for full release notes
    2011-04-28  MFU         4.1     Bug fixes for databases requiring []
                                    , cleaned up the create table section
                                    , updated syntax for case-sensitive databases
                                    , comma-delimited list for @database now supported
*********************************************************************************
    Example of how to call this script:

        EXECUTE dbo.sp_IndexDefrag
              @executeSQL           = 1
            , @printCommands        = 1
            , @debugMode            = 1
            , @printFragmentation   = 1
            , @forceRescan          = 1
            , @maxDopRestriction    = 1
            , @minPageCount         = 8
            , @maxPageCount         = NULL
            , @minFragmentation     = 1
            , @rebuildThreshold     = 30
            , @defragDelay          = '00:00:05'
            , @defragOrderColumn    = 'page_count'
            , @defragSortOrder      = 'DESC'
            , @excludeMaxPartition  = 1
            , @timeLimit            = NULL
            , @database             = 'sandbox,sandbox_caseSensitive';
***************************************************************************************/

	set nocount on;
	set xact_abort on;
	set quoted_identifier on;

	begin

		begin try

/****************************
 Just a little validation... 
****************************/

			if @minFragmentation is null
			   or @minFragmentation not between 0.00 and 100.0
				set @minFragmentation = 10.0;

			if @rebuildThreshold is null
			   or @rebuildThreshold not between 0.00 and 100.0
				set @rebuildThreshold = 30.0;

			if @defragDelay not like '00:[0-5][0-9]:[0-5][0-9]'
				set @defragDelay = '00:00:05';

			if @defragOrderColumn is null
			   or @defragOrderColumn not in('range_scan_count', 'fragmentation', 'page_count')
				set @defragOrderColumn = 'range_scan_count';

			if @defragSortOrder is null
			   or @defragSortOrder not in('ASC', 'DESC')
				set @defragSortOrder = 'DESC';

			if @scanMode not in('LIMITED', 'SAMPLED', 'DETAILED')
				set @scanMode = 'LIMITED';

			if @executeSQL is null
				set @executeSQL = 0;

			if @debugMode is null
				set @debugMode = 0;

			if @forceRescan is null
				set @forceRescan = 0;

			if @minPageCount is null
				set @minPageCount = 8;

			if @sortInTempDB is null
				set @sortInTempDB = 1;

			if @onlineRebuild is null
				set @onlineRebuild = 0;

			if @debugMode = 1
				raiserror('Undusting the cogs AND starting up...', 0, 42) with nowait;

/**********************
 Declare our variables 
**********************/

			declare @objectID               int, 
					@databaseID             int, 
					@databaseName           nvarchar(128), 
					@indexID                int, 
					@partitionCount         bigint, 
					@schemaName             nvarchar(128), 
					@objectName             nvarchar(128), 
					@indexName              nvarchar(128), 
					@partitionNumber        smallint, 
					@fragmentation          float, 
					@pageCount              int, 
					@sqlCommand             nvarchar(4000), 
					@rebuildCommand         nvarchar(200), 
					@datetimestart          datetime, 
					@dateTimeEnd            datetime, 
					@containsLOB            bit, 
					@editionCheck           bit, 
					@debugMessage           nvarchar(4000), 
					@updateSQL              nvarchar(4000), 
					@partitionSQL           nvarchar(4000), 
					@partitionSQL_Param     nvarchar(1000), 
					@LOB_SQL                nvarchar(4000), 
					@LOB_SQL_Param          nvarchar(1000), 
					@indexDefrag_id         int, 
					@startdatetime          datetime, 
					@enddatetime            datetime, 
					@getIndexSQL            nvarchar(4000), 
					@getIndexSQL_Param      nvarchar(4000), 
					@allowPageLockSQL       nvarchar(4000), 
					@allowPageLockSQL_Param nvarchar(4000), 
					@allowPageLocks         int, 
					@excludeMaxPartitionSQL nvarchar(4000);

/*************************
 Initialize our variables 
*************************/

			select @startdatetime = GETDATE(), 
				   @enddatetime = DATEADD(minute, @timeLimit, GETDATE());

/****************************
 Create our temporary tables 
****************************/

			create table #databaseList
			(
				databaseID   int, 
				databaseName varchar(128), 
				scanStatus   bit);

			create table #processor
			(
				[index]         int, 
				Name            varchar(128), 
				Internal_Value  int, 
				Character_Value int);

			create table #maxPartitionList
			(
				databaseID   int, 
				objectID     int, 
				indexID      int, 
				maxPartition int);

			if @debugMode = 1
				raiserror('Beginning validation...', 0, 42) with nowait;

/*************************************************************************
 Make sure we're not exceeding the number of processors we have available 
*************************************************************************/

			insert into #processor
			execute xp_msver 'ProcessorCount';

			if @maxDopRestriction is not null
			   and @maxDopRestriction >
			(
				select Internal_Value
				from #processor
			) 
				select @maxDopRestriction = Internal_Value
				from #processor;

/**************************************************************************************************************
 Check our server version; 1804890536 = Enterprise, 610778273 = Enterprise Evaluation, -2117995310 = Developer 
**************************************************************************************************************/

			if
			(
				select SERVERPROPERTY('EditionID')
			) in(1804890536, 610778273, -2117995310)
				set @editionCheck = 1 -- supports online rebuilds;
			else
				set @editionCheck = 0; -- does not support online rebuilds

/*****************************************
 Output the parameters we're working with 
*****************************************/

			if @debugMode = 1
			begin

				select @debugMessage = 'Your SELECTed parameters are... 
            Defrag indexes WITH fragmentation greater than ' + CAST(@minFragmentation as varchar(10)) + ';
            REBUILD indexes WITH fragmentation greater than ' + CAST(@rebuildThreshold as varchar(10)) + ';
            You' + case
					   when @executeSQL = 1 then ' DO'
				   else ' DO NOT'
				   end + ' want the commands to be executed automatically; 
            You want to defrag indexes in ' + @defragSortOrder + ' order of the ' + UPPER(@defragOrderColumn) + ' value;
            You have' + case
							when @timeLimit is null then ' NOT specified a time limit;'
						else ' specified a time limit of ' + CAST(@timeLimit as varchar(10))
						end + ' minutes;
            ' + case
					when @database is null then 'ALL databases'
				else 'The ' + @database + ' database(s)'
				end + ' will be defragged;
            ' + case
					when @tableName is null then 'ALL tables'
				else 'The ' + @tableName + ' TABLE'
				end + ' will be defragged;
            We' + case
					  when exists
				(
					select top 1 *
					from dbo.dba_indexDefragStatus
					where defragDate is null
				)
						   and @forceRescan <> 1 then ' WILL NOT'
				  else ' WILL'
				  end + ' be rescanning indexes;
            The scan will be performed in ' + @scanMode + ' mode;
            You want to limit defrags to indexes with' + case
															 when @maxPageCount is null then ' more than ' + CAST(@minPageCount as varchar(10))
														 else ' BETWEEN ' + CAST(@minPageCount as varchar(10)) + ' AND ' + CAST(@maxPageCount as varchar(10))
														 end + ' pages;
            Indexes will be defragged' + case
											 when @editionCheck = 0
												  or @onlineRebuild = 0 then ' OFFLINE;'
										 else ' ONLINE;'
										 end + '
            Indexes will be sorted in' + case
											 when @sortInTempDB = 0 then ' the DATABASE'
										 else ' TEMPDB;'
										 end + '
            Defrag operations will utilize ' + case
												   when @editionCheck = 0
														or @maxDopRestriction is null then 'system defaults for processors;'
											   else CAST(@maxDopRestriction as varchar(2)) + ' processors;'
											   end + '
            You' + case
					   when @printCommands = 1 then ' DO'
				   else ' DO NOT'
				   end + ' want to PRINT the ALTER INDEX commands; 
            You' + case
					   when @printFragmentation = 1 then ' DO'
				   else ' DO NOT'
				   end + ' want to OUTPUT fragmentation levels; 
            You want to wait ' + @defragDelay + ' (hh:mm:ss) BETWEEN defragging indexes;
            You want to run in' + case
									  when @debugMode = 1 then ' DEBUG'
								  else ' SILENT'
								  end + ' mode.';

				raiserror(@debugMessage, 0, 42) with nowait;
			end;

			if @debugMode = 1
				raiserror('Grabbing a list of our databases...', 0, 42) with nowait;

/**********************************************
 Retrieve the list of databases to investigate 
**********************************************/

/*****************************************************************
 If @database is NULL, it means we want to defrag *all* databases 
*****************************************************************/

			if @database is null
			begin

				insert into #databaseList
				select database_id, 
					   name, 
					   0 -- not scanned yet for fragmentation
				from sys.databases
				where name not in ('master', 'tempdb')-- exclude system databases   
					  and [state] = 0 -- state must be ONLINE
					  and is_read_only = 0;  -- cannot be read_only
			end;
			else

/************************************************************
 Otherwise, we're going to just defrag our list of databases 
************************************************************/

			begin

				insert into #databaseList
				select database_id, 
					   name, 
					   0 -- not scanned yet for fragmentation
				from sys.databases as d
					 join dbo.udf_parseString(@database, ',') as x on d.name collate database_default = x.stringValue
				where name not in ('master', 'tempdb')-- exclude system databases   
					  and [state] = 0 -- state must be ONLINE
					  and is_read_only = 0;  -- cannot be read_only
			end;

/**************************************************************************************
 Check to see IF we have indexes in need of defrag; otherwise, re-scan the database(s) 
**************************************************************************************/

			if not exists
			(
				select top 1 *
				from dbo.dba_indexDefragStatus
				where defragDate is null
			)
			   or @forceRescan = 1
			begin

/*******************************************************
 Truncate our list of indexes to prepare for a new scan 
*******************************************************/

				truncate table dbo.dba_indexDefragStatus;

				if @debugMode = 1
					raiserror('Looping through our list of databases and checking for fragmentation...', 0, 42) with nowait;

/***********************************
 Loop through our list of databases 
***********************************/

				while
				(
					select COUNT(*)
					from #databaseList
					where scanStatus = 0
				) > 0
				begin

					select top 1 @databaseID = databaseID
					from #databaseList
					where scanStatus = 0;

					select @debugMessage = '  working on ' + DB_NAME(@databaseID) + '...';

					if @debugMode = 1
						raiserror(@debugMessage, 0, 42) with nowait;

/********************************************************************
 Determine which indexes to defrag using our user-defined parameters 
********************************************************************/

					insert into dbo.dba_indexDefragStatus (databaseID, 
														   databaseName, 
														   objectID, 
														   indexID, 
														   partitionNumber, 
														   fragmentation, 
														   page_count, 
														   range_scan_count, 
														   scanDate) 
					select ps.database_id as 'databaseID', 
						   QUOTENAME(DB_NAME(ps.database_id)) as 'databaseName', 
						   ps.object_id as 'objectID', 
						   ps.index_id as 'indexID', 
						   ps.partition_number as 'partitionNumber', 
						   SUM(ps.avg_fragmentation_in_percent) as 'fragmentation', 
						   SUM(ps.page_count) as 'page_count', 
						   os.range_scan_count, 
						   GETDATE() as 'scanDate'
					from sys.dm_db_index_physical_stats(@databaseID, OBJECT_ID(@tableName), null, null, @scanMode) as ps
						 join sys.dm_db_index_operational_stats(@databaseID, OBJECT_ID(@tableName), null, null) as os on ps.database_id = os.database_id
																														 and ps.object_id = os.object_id
																														 and ps.index_id = os.index_id
																														 and ps.partition_number = os.partition_number
					where avg_fragmentation_in_percent >= @minFragmentation
						  and ps.index_id > 0 -- ignore heaps
						  and ps.page_count > @minPageCount
						  and ps.index_level = 0 -- leaf-level nodes only, supports @scanMode
					group by ps.database_id, 
							 QUOTENAME(DB_NAME(ps.database_id)), 
							 ps.object_id, 
							 ps.index_id, 
							 ps.partition_number, 
							 os.range_scan_count option(maxdop 2);

/*********************************************************************************
 Do we want to exclude right-most populated partition of our partitioned indexes? 
*********************************************************************************/

					if @excludeMaxPartition = 1
					begin

						set @excludeMaxPartitionSQL = '
                        SELECT ' + CAST(@databaseID as varchar(10)) + ' AS [databaseID]
                            , [object_id]
                            , index_id
                            , MAX(partition_number) AS [maxPartition]
                        FROM [' + DB_NAME(@databaseID) + '].sys.partitions
                        WHERE partition_number > 1
                            AND [rows] > 0
                        GROUP BY object_id
                            , index_id;';

						insert into #maxPartitionList
						execute sp_executesql @excludeMaxPartitionSQL;
					end;

/********************************************************
 Keep track of which databases have already been scanned 
********************************************************/

					update #databaseList
					set scanStatus = 1
					where databaseID = @databaseID;
				end;

/******************************************************************************************
 We don't want to defrag the right-most populated partition, so
               delete any records for partitioned indexes where partition = MAX(partition) 
******************************************************************************************/

				if @excludeMaxPartition = 1
				begin

					delete ids
					from dbo.dba_indexDefragStatus as ids
						 join #maxPartitionList as mpl on ids.databaseID = mpl.databaseID
														  and ids.objectID = mpl.objectID
														  and ids.indexID = mpl.indexID
														  and ids.partitionNumber = mpl.maxPartition;
				end;

/***********************************************************************************************
 Update our exclusion mask for any index that has a restriction ON the days it can be defragged 
***********************************************************************************************/

				update ids
				set ids.exclusionMask = ide.exclusionMask
				from dbo.dba_indexDefragStatus as ids
					 join dbo.dba_indexDefragExclusion as ide on ids.databaseID = ide.databaseID
																 and ids.objectID = ide.objectID
																 and ids.indexID = ide.indexID;
			end;

			select @debugMessage = 'Looping through our list... there are ' + CAST(COUNT(*) as varchar(10)) + ' indexes to defrag!'
			from dbo.dba_indexDefragStatus
			where defragDate is null
				  and page_count between @minPageCount and ISNULL(@maxPageCount, page_count);

			if @debugMode = 1
				raiserror(@debugMessage, 0, 42) with nowait;

/******************************
 Begin our loop for defragging 
******************************/

			while
			(
				select COUNT(*)
				from dbo.dba_indexDefragStatus
				where( @executeSQL = 1
					   and defragDate is null
					   or @executeSQL = 0
					   and defragDate is null
					   and printStatus = 0
					 )
					 and exclusionMask&POWER(2, DATEPART(weekday, GETDATE()) - 1) = 0
					 and page_count between @minPageCount and ISNULL(@maxPageCount, page_count)
			) > 0
			begin

/*******************************************************************
 Check to see IF we need to exit our loop because of our time limit 
*******************************************************************/

				if ISNULL(@enddatetime, GETDATE()) < GETDATE()
				begin
					raiserror('Our time limit has been exceeded!', 11, 42) with nowait;
				end;

				if @debugMode = 1
					raiserror('  Picking an index to beat into shape...', 0, 42) with nowait;

/*****************************************************************************
 Grab the index with the highest priority, based on the values submitted; 
               Look at the exclusion mask to ensure it can be defragged today 
*****************************************************************************/

				set @getIndexSQL = N'
            SELECT TOP 1 
                  @objectID_Out         = objectID
                , @indexID_Out          = indexID
                , @databaseID_Out       = databaseID
                , @databaseName_Out     = databaseName
                , @fragmentation_Out    = fragmentation
                , @partitionNumber_Out  = partitionNumber
                , @pageCount_Out        = page_count
            FROM dbo.dba_indexDefragStatus
            WHERE defragDate IS NULL ' + case
											 when @executeSQL = 0 then 'AND printStatus = 0'
										 else ''
										 end + '
                AND exclusionMask & Power(2, DatePart(weekday, GETDATE())-1) = 0
                AND page_count BETWEEN @p_minPageCount AND ISNULL(@p_maxPageCount, page_count)
            ORDER BY + ' + @defragOrderColumn + ' ' + @defragSortOrder;

				set @getIndexSQL_Param = N'@objectID_Out        INT OUTPUT
                                     , @indexID_Out         INT OUTPUT
                                     , @databaseID_Out      INT OUTPUT
                                     , @databaseName_Out    NVARCHAR(128) OUTPUT
                                     , @fragmentation_Out   INT OUTPUT
                                     , @partitionNumber_Out INT OUTPUT
                                     , @pageCount_Out       INT OUTPUT
                                     , @p_minPageCount      INT
                                     , @p_maxPageCount      INT';

				execute sp_executesql @getIndexSQL, @getIndexSQL_Param, @p_minPageCount = @minPageCount, @p_maxPageCount = @maxPageCount, @objectID_Out = @objectID output, @indexID_Out = @indexID output, @databaseID_Out = @databaseID output, @databaseName_Out = @databaseName output, @fragmentation_Out = @fragmentation output, @partitionNumber_Out = @partitionNumber output, @pageCount_Out = @pageCount output;

				if @debugMode = 1
					raiserror('  Looking up the specifics for our index...', 0, 42) with nowait;

/**************************
 Look up index information 
**************************/

				select @updateSQL = N'UPDATE ids
                SET schemaName = QUOTENAME(s.name)
                    , objectName = QUOTENAME(o.name)
                    , indexName = QUOTENAME(i.name)
                FROM dbo.dba_indexDefragStatus AS ids
                INNER JOIN ' + @databaseName + '.sys.objects AS o
                    ON ids.objectID = o.[object_id]
                INNER JOIN ' + @databaseName + '.sys.indexes AS i
                    ON o.[object_id] = i.[object_id]
                    AND ids.indexID = i.index_id
                INNER JOIN ' + @databaseName + '.sys.schemas AS s
                    ON o.schema_id = s.schema_id
                WHERE o.[object_id] = ' + CAST(@objectID as varchar(10)) + '
                    AND i.index_id = ' + CAST(@indexID as varchar(10)) + '
                    AND i.type > 0
                    AND ids.databaseID = ' + CAST(@databaseID as varchar(10));

				execute sp_executesql @updateSQL;

/**********************
 Grab our object names 
**********************/

				select @objectName = objectName, 
					   @schemaName = schemaName, 
					   @indexName = indexName
				from dbo.dba_indexDefragStatus
				where objectID = @objectID
					  and indexID = @indexID
					  and databaseID = @databaseID;

				if @debugMode = 1
					raiserror('  Grabbing the partition COUNT...', 0, 42) with nowait;

/**************************************
 Determine if the index is partitioned 
**************************************/

				select @partitionSQL = 'SELECT @partitionCount_OUT = COUNT(*)
                                        FROM ' + @databaseName + '.sys.partitions
                                        WHERE object_id = ' + CAST(@objectID as varchar(10)) + '
                                            AND index_id = ' + CAST(@indexID as varchar(10)) + ';', 
					   @partitionSQL_Param = '@partitionCount_OUT INT OUTPUT';

				execute sp_executesql @partitionSQL, @partitionSQL_Param, @partitionCount_OUT = @partitionCount output;

				if @debugMode = 1
					raiserror('  Seeing IF there are any LOBs to be handled...', 0, 42) with nowait;

/*************************************
 Determine if the table contains LOBs 
*************************************/

				select @LOB_SQL = ' SELECT @containsLOB_OUT = COUNT(*)
                                FROM ' + @databaseName + '.sys.columns WITH (NoLock) 
                                WHERE [object_id] = ' + CAST(@objectID as varchar(10)) + '
                                   AND (system_type_id IN (34, 35, 99)
                                            OR max_length = -1);',

/********************************************************************************************************
  system_type_id --> 34 = IMAGE, 35 = TEXT, 99 = NTEXT
                                    max_length = -1 --> VARBINARY(MAX), VARCHAR(MAX), NVARCHAR(MAX), XML 
********************************************************************************************************/

					   @LOB_SQL_Param = '@containsLOB_OUT INT OUTPUT';

				execute sp_executesql @LOB_SQL, @LOB_SQL_Param, @containsLOB_OUT = @containsLOB output;

				if @debugMode = 1
					raiserror('  Checking for indexes that do NOT allow page locks...', 0, 42) with nowait;

/**********************************************************************************
 Determine if page locks are allowed; for those indexes, we need to always REBUILD 
**********************************************************************************/

				select @allowPageLockSQL = 'SELECT @allowPageLocks_OUT = COUNT(*)
                                        FROM ' + @databaseName + '.sys.indexes
                                        WHERE object_id = ' + CAST(@objectID as varchar(10)) + '
                                            AND index_id = ' + CAST(@indexID as varchar(10)) + '
                                            AND Allow_Page_Locks = 0;', 
					   @allowPageLockSQL_Param = '@allowPageLocks_OUT INT OUTPUT';

				execute sp_executesql @allowPageLockSQL, @allowPageLockSQL_Param, @allowPageLocks_OUT = @allowPageLocks output;

				if @debugMode = 1
					raiserror('  Building our SQL statements...', 0, 42) with nowait;

/*********************************************************************************
 IF there's not a lot of fragmentation, or if we have a LOB, we should REORGANIZE 
*********************************************************************************/

				if( @fragmentation < @rebuildThreshold
					or @containsLOB >= 1
					or @partitionCount > 1
				  )
				  and @allowPageLocks = 0
				begin

					set @sqlCommand = N'ALTER INDEX ' + @indexName + N' ON ' + @databaseName + N'.' + @schemaName + N'.' + @objectName + N' REORGANIZE';

/*********************************************************
 If our index is partitioned, we should always REORGANIZE 
*********************************************************/

					if @partitionCount > 1
						set @sqlCommand = @sqlCommand + N' PARTITION = ' + CAST(@partitionNumber as nvarchar(10));
				end;

/********************************************************************************
 If the index is heavily fragmented and doesn't contain any partitions or LOB's, 
               or if the index does not allow page locks, REBUILD it 
********************************************************************************/

				else
					if( @fragmentation >= @rebuildThreshold
						or @allowPageLocks <> 0
					  )
					  and ISNULL(@containsLOB, 0) != 1
					  and @partitionCount <= 1
					begin

/********************************************************
 Set online REBUILD options; requires Enterprise Edition 
********************************************************/

						if @onlineRebuild = 1
						   and @editionCheck = 1
							set @rebuildCommand = N' REBUILD WITH (ONLINE = ON';
						else
							set @rebuildCommand = N' REBUILD WITH (ONLINE = Off';

/*******************************
 Set sort operation preferences 
*******************************/

						if @sortInTempDB = 1
							set @rebuildCommand = @rebuildCommand + N', SORT_IN_TEMPDB = ON';
						else
							set @rebuildCommand = @rebuildCommand + N', SORT_IN_TEMPDB = Off';

/***************************************************************
 Set processor restriction options; requires Enterprise Edition 
***************************************************************/

						if @maxDopRestriction is not null
						   and @editionCheck = 1
							set @rebuildCommand = @rebuildCommand + N', MAXDOP = ' + CAST(@maxDopRestriction as varchar(2)) + N')';
						else
							set @rebuildCommand = @rebuildCommand + N')';

						set @sqlCommand = N'ALTER INDEX ' + @indexName + N' ON ' + @databaseName + N'.' + @schemaName + N'.' + @objectName + @rebuildCommand;
					end;
					else

/****************************************************************************
 Print an error message if any indexes happen to not meet the criteria above 
****************************************************************************/

						if @printCommands = 1
						   or @debugMode = 1
							raiserror('We are unable to defrag this index.', 0, 42) with nowait;

/****************************************
 Are we executing the SQL?  IF so, do it 
****************************************/

				if @executeSQL = 1
				begin

					set @debugMessage = 'Executing: ' + @sqlCommand;

/*********************************************************
 Print the commands we're executing if specified to do so 
*********************************************************/

					if @printCommands = 1
					   or @debugMode = 1
						raiserror(@debugMessage, 0, 42) with nowait;

/***********************************
 Grab the time for logging purposes 
***********************************/

					set @datetimestart = GETDATE();

/****************
 Log our actions 
****************/

					insert into dbo.dba_indexDefragLog (databaseID, 
														databaseName, 
														objectID, 
														objectName, 
														indexID, 
														indexName, 
														partitionNumber, 
														fragmentation, 
														page_count, 
														dateTimeStart, 
														sqlStatement) 
					select @databaseID, 
						   @databaseName, 
						   @objectID, 
						   @objectName, 
						   @indexID, 
						   @indexName, 
						   @partitionNumber, 
						   @fragmentation, 
						   @pageCount, 
						   @datetimestart, 
						   @sqlCommand;

					set @indexDefrag_id = SCOPE_IDENTITY();

/************************************************************************
 Wrap our execution attempt in a TRY/CATCH and log any errors that occur 
************************************************************************/

					begin try

/********************
 Execute our defrag! 
********************/

						execute sp_executesql @sqlCommand;
						set @dateTimeEnd = GETDATE();

/****************************************
 Update our log with our completion time 
****************************************/

						update dbo.dba_indexDefragLog
						set dateTimeEnd = @dateTimeEnd, durationSeconds = DATEDIFF(second, @datetimestart, @dateTimeEnd)
						where indexDefrag_id = @indexDefrag_id;
					end try
					begin catch

/**************************************
 Update our log with our error message 
**************************************/

						update dbo.dba_indexDefragLog
						set dateTimeEnd = GETDATE(), durationSeconds = -1, errorMessage = ERROR_MESSAGE()
						where indexDefrag_id = @indexDefrag_id;

						if @debugMode = 1
							raiserror('  An error has occurred executing this command! Please review the dba_indexDefragLog table for details.', 0, 42) with nowait;
					end catch;

/**************************************
 Just a little breather for the server 
**************************************/

					waitfor delay @defragDelay;

					update dbo.dba_indexDefragStatus
					set defragDate = GETDATE(), printStatus = 1
					where databaseID = @databaseID
						  and objectID = @objectID
						  and indexID = @indexID
						  and partitionNumber = @partitionNumber;
				end;
				else

/***********************************************************
 Looks like we're not executing, just printing the commands 
***********************************************************/

				begin
					if @debugMode = 1
						raiserror('  Printing SQL statements...', 0, 42) with nowait;

					if @printCommands = 1
					   or @debugMode = 1
						print ISNULL(@sqlCommand, 'error!');

					update dbo.dba_indexDefragStatus
					set printStatus = 1
					where databaseID = @databaseID
						  and objectID = @objectID
						  and indexID = @indexID
						  and partitionNumber = @partitionNumber;
				end;
			end;

/************************************************
 Do we want to output our fragmentation results? 
************************************************/

			if @printFragmentation = 1
			begin

				if @debugMode = 1
					raiserror('  Displaying a summary of our action...', 0, 42) with nowait;

				select databaseID, 
					   databaseName, 
					   objectID, 
					   objectName, 
					   indexID, 
					   indexName, 
					   partitionNumber, 
					   fragmentation, 
					   page_count, 
					   range_scan_count
				from dbo.dba_indexDefragStatus
				where defragDate >= @startdatetime
				order by defragDate;
			end;
		end try
		begin catch

			set @debugMessage = ERROR_MESSAGE() + ' (Line Number: ' + CAST(ERROR_LINE() as varchar(10)) + ')';
			print @debugMessage;
		end catch;

/*************************************************************************
 When everything is said and done, make sure to get rid of our temp table 
*************************************************************************/

		drop table #databaseList;
		drop table #processor;
		drop table #maxPartitionList;

		if @debugMode = 1
			raiserror('DONE!  Thank you for taking care of your indexes!  :)', 0, 42) with nowait;

		set nocount off;
		return 0;
	end;
end;