if OBJECTPROPERTY(OBJECT_ID('dbo.sp_IndexStatistics'), N'IsProcedure') = 1
begin
	drop procedure dbo.sp_IndexStatistics;
	print 'Procedure sp_IndexStatistics dropped';
end;
go

set quoted_identifier on;
go
set ansi_nulls on;
go

create procedure dbo.sp_IndexStatistics

/*******************
 Declare Parameters 
*******************/

	@databaseName      varchar(256) = null, 
	@indexType         varchar(256) = null, 
	@minRowCount       int          = null, 
	@maxRowCount       int          = null, 
	@minSeekScanLookup int          = null, 
	@maxSeekScanLookup int          = null
as
begin

/*********************************************************************************************************
    NAME:           sp_IndexStatistics

    SYNOPSIS:       Retrieves information regarding indexes; will return drop SQL
                    statement for non-clustered indexes.

    DEPENDENCIES:   The following dependencies are required to execute this script:
                    - SQL Server 2005 or newer

    NOTES:          @databaseName - optional, specify a specific database to interrogate;
                    by default, all user databases will be returned

                    @indexType - optional, valid options are: 
                                    Clustered
                                    NonClustered
                                    Unique Clustered
                                    Unique NonClustered
                                    Heap
    
                    @minRowCount - optional, specify a minimum number of rows an index
                                    must cover
    
                    @maxRowCount - optional, specify a maximum number of rows an index
                                    must cover
    
                    @minSeekScanLookup - optional, min sum aggregation of index scans, 
                                    seeks, and look-ups.  Useful for finding unused indexes
    
                    @minSeekScanLookup - optional, max sum aggregation of index scans,  
                                    seeks, and look-ups.  Useful for finding unused indexes

    AUTHOR:         Michelle Ufford, http://sqlfool.com
    
    CREATED:        2008-07-11
    
    VERSION:        1.0

    LICENSE:        Apache License v2
    
    USAGE:          EXEC dbo.sp_IndexStatistics
                      @databaseName         = 'your_db'
                    , @indexType            = 'NonClustered'
                    , @minSeekScanLookup    = 0
                    , @maxSeekScanLookup    = 1000
                    , @minRowCount          = 0
                    , @maxRowCount          = 10000000;

    ----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------

 ---------------------------------------------------------------------------------------------------------
 --  DATE       VERSION     AUTHOR                  DESCRIPTION                                        --
 ---------------------------------------------------------------------------------------------------------
     20150619   1.0         Michelle Ufford         Open Sourced on GitHub
*********************************************************************************************************/

	set nocount on;
	set xact_abort on;

	begin

/******************
 Declare Variables 
******************/

		create table #indexStats
		(
			databaseName         varchar(256), 
			objectName           varchar(256), 
			indexName            varchar(256), 
			indexType            varchar(256), 
			user_seeks           int, 
			user_scans           int, 
			user_lookups         int, 
			user_updates         int, 
			total_seekScanLookup int, 
			rowCounts            int, 
			SQL_DropStatement    varchar(2000));

/**************************************
 Check for existing transactions;
       If one exists, exit with error. 
**************************************/

		if @@TranCount > 0
		begin

/***********************************************
 Log the fact that there were open transactions 
***********************************************/

			execute dbo.sp_LogError @errorType = 'app', @app_errorProcedure = 'sp_IndexStatistics', @app_errorMessage = 'Open transaction exists; sp_IndexStatistics proc will not execute.';
			print 'Open transactions exist!';
		end;
		else
		begin
			begin try

				execute sp_MSForEachDB 'Use [?]

        Declare @dbid int
            , @dbName varchar(100);

        Select @dbid = DB_ID()
            , @dbName = DB_Name();

        With indexSizeCTE (object_id, index_id, rowCounts) As
        (
            Select [object_id]
                , index_id
                , Sum([rows]) As ''rowCounts''
            From sys.partitions
            Group By [object_id]
                , index_id
        ) 

        Insert Into #indexStats
        Select  
                  @dbName
                , Object_Name(ix.[object_id]) as objectName
                , ix.name As ''indexName''
                , Case 
                    When ix.is_unique = 1 
                        Then ''UNIQUE ''
                    Else ''''
                  End + ix.type_desc As ''indexType''
                , ddius.user_seeks
                , ddius.user_scans
                , ddius.user_lookups
                , ddius.user_updates
                , ddius.user_seeks + ddius.user_scans + ddius.user_lookups
                , isc.rowCounts
                , Case 
                    When ix.type = 2 And ix.is_unique = 0
                        Then ''Drop Index '' + ix.name + '' On '' + @dbName + ''.dbo.'' + Object_Name(ddius.[object_id]) + '';''
                    When ix.type = 2 And ix.is_unique = 1
                        Then ''Alter Table '' + @dbName + ''.dbo.'' + Object_Name(ddius.[object_ID]) + '' Drop Constraint '' + ix.name + '';''
                    Else '' ''
                  End As ''SQL_DropStatement''
        From sys.indexes As ix
            Left Outer Join sys.dm_db_index_usage_stats ddius
                On ix.object_id = ddius.object_id
                    And ix.index_id = ddius.index_id
            Left Outer Join indexSizeCTE As isc
                On ix.object_id = isc.object_id
                    And ix.index_id = isc.index_id
        Where ddius.database_id = @dbid
            And ObjectProperty(ix.[object_id], N''IsUserTable'') = 1
        Order By (ddius.user_seeks + ddius.user_scans + ddius.user_lookups) Asc;
        ';

				select databaseName, 
					   objectName, 
					   indexName, 
					   indexType, 
					   user_seeks, 
					   user_scans, 
					   user_lookups, 
					   total_seekScanLookup, 
					   user_updates, 
					   rowCounts, 
					   SQL_DropStatement
				from #indexStats
				where databaseName = ISNULL(@databaseName, databaseName)
					  and indexType = ISNULL(@indexType, indexType)
					  and rowCounts between ISNULL(@minRowCount, rowCounts) and ISNULL(@maxRowCount, rowCounts)
					  and total_seekScanLookup between ISNULL(@minSeekScanLookup, total_seekScanLookup) and ISNULL(@maxSeekScanLookup, total_seekScanLookup)
					  and databaseName not in ('master', 'msdb', 'tempdb', 'model')
				order by total_seekScanLookup;
			end try
			begin catch

/***********************************
 Return an error message and log it 
***********************************/

				execute dbo.sp_LogError;
				print 'An error has occurred!';
			end catch;
		end;

/**********
 Clean up! 
**********/

		drop table #indexStats;

		set nocount off;
		return 0;
	end;
end;
go

set quoted_identifier off;
go
set ansi_nulls on;
go

if OBJECTPROPERTY(OBJECT_ID('dbo.sp_IndexStatistics'), N'IsProcedure') = 1
	raiserror('Procedure sp_IndexStatistics was successfully created.', 10, 1);
else
	raiserror('Procedure sp_IndexStatistics FAILED to create!', 16, 1);
go