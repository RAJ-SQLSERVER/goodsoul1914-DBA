use master;
go

/***********************************
 Create a stored procedure skeleton 
***********************************/

if OBJECTPROPERTY(OBJECT_ID('dbo.sp_MissingIndexesProc_sp'), N'IsProcedure') is null
begin
	execute ('Create Procedure dbo.sp_MissingIndexesProc_sp As Print ''Hello World!''');
	raiserror('Procedure sp_MissingIndexesProc_sp created.', 10, 1);
end;
go

/************************************
 Drop our table if it already exists 
************************************/

if exists
(
	select Object_ID
	from sys.tables
	where name = N'sp_MissingIndexesProc'
) 
begin
	drop table dbo.sp_MissingIndexesProc;
	print 'sp_MissingIndexesProc table dropped!';
end;

/*****************
 Create our table 
*****************/

create table dbo.sp_MissingIndexesProc
(
	missingIndexSP_id   int identity(1, 1) not null, 
	databaseName        varchar(128) not null, 
	databaseID          int not null, 
	objectName          varchar(128) not null, 
	objectID            int not null, 
	query_plan          xml not null, 
	executionDate       smalldatetime not null, 
	statementExecutions int not null
							constraint PK_missingIndexStoredProc primary key clustered (missingIndexSP_id));

print 'sp_MissingIndexesProc Table Created';

/***********************
 Configure our settings 
***********************/

set ansi_nulls on;
set quoted_identifier on;
go

alter procedure dbo.sp_MissingIndexesProc_sp

/*******************
 Declare Parameters 
*******************/

	@lastExecuted_inDays int = 7, 
	@minExecutionCount   int = 1, 
	@logResults          bit = 1, 
	@displayResults      bit = 0
as
begin

/*********************************************************************************************************
    NAME:           sp_MissingIndexesProc_sp

    SYNOPSIS:       Retrieves stored procedures with missing indexes in their cached query plans.
                
                    @lastExecuted_inDays = number of days old the cached query plan
                                       can be to still appear in the results;
                                       the HIGHER the number, the longer the
                                       execution time.

                    @minExecutionCount = minimum number of executions the cached
                                     query plan can have to still appear 
                                     in the results; the LOWER the number,
                                     the longer the execution time.

                    @logResults = store results in sp_MissingIndexesProc
                
                    @displayResults = return results to the caller

    DEPENDENCIES:   The following dependencies are required to execute this script:
                    - SQL Server 2005 or newer

    NOTES:          This is not 100% guaranteed to catch all missing indexes in
                    a stored procedure.  It will only catch it if the stored proc's
                    query plan is still in cache.  Run regularly to help minimize
                    the chance of missing a proc.

    AUTHOR:         Michelle Ufford, http://sqlfool.com
    
    CREATED:        2009-09-03
    
    VERSION:        1.0

    LICENSE:        Apache License v2
    
    USAGE:          Exec dbo.sp_MissingIndexesProc_sp
                      @lastExecuted_inDays  = 30
                    , @minExecutionCount    = 5
                    , @logResults           = 1
                    , @displayResults       = 1;

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
	set ansi_padding on;
	set ansi_warnings on;
	set arithabort on;
	set concat_null_yields_null on;
	set numeric_roundabort off;

	begin

/******************
 Declare Variables 
******************/

		declare @currentDateTime smalldatetime;

		set @currentDateTime = GETDATE();

		declare @plan_handles table
		(
			plan_handle         varbinary(64) not null, 
			statementExecutions int not null);

		create table #missingIndexes
		(
			databaseID          int not null, 
			objectID            int not null, 
			query_plan          xml not null, 
			statementExecutions int not null);

		create clustered index CIX_temp_missingIndexes on #missingIndexes (databaseID, objectID);

		begin try

/*****************************
 Perform some data validation 
*****************************/

			if @logResults = 0
			   and @displayResults = 0
			begin

/***********************************************
 Log the fact that there were open transactions 
***********************************************/

				execute dbo.sp_LogError @errorType = 'app', @app_errorProcedure = 'sp_MissingIndexesProc_sp', @app_errorMessage = '@logResults = 0 and @displayResults = 0; no action taken, exiting stored proc.', @forceExit = 1, @returnError = 1;
			end;

			begin transaction;

/**********************************************************************
 Retrieve distinct plan handles to minimize dm_exec_query_plan lookups 
**********************************************************************/

			insert into @plan_handles
			select plan_handle, 
				   SUM(execution_count) as 'executions'
			from sys.dm_exec_query_stats
			where last_execution_time > DATEADD(day, -@lastExecuted_inDays, @currentDateTime)
			group by plan_handle
			having SUM(execution_count) > @minExecutionCount;

			with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

/*********************************************************
 Retrieve our query plan's XML if there's a missing index 
*********************************************************/

				 insert into #missingIndexes
				 select deqp.dbid, 
						deqp.objectid, 
						deqp.query_plan, 
						ph.statementExecutions
				 from @plan_handles as ph
					  cross apply sys.dm_exec_query_plan(ph.plan_handle) as deqp
				 where deqp.query_plan.exist('//MissingIndex/@Database') = 1
					   and deqp.objectid is not null;

/************************************************
 Do we want to store the results of our process? 
************************************************/

			if @logResults = 1
			begin
				insert into dbo.sp_MissingIndexesProc
				execute sp_msForEachDB 'Use ?; 
                                    Select ''?''
                                        , mi.databaseID
                                        , Object_Name(o.object_id)
                                        , o.object_id
                                        , mi.query_plan
                                        , GetDate()
                                        , mi.statementExecutions
                                    From sys.objects As o 
                                    Join #missingIndexes As mi 
                                        On o.object_id = mi.objectID 
                                    Where databaseID = DB_ID();';
			end;

/******************************************
 We're not logging it, so let's display it 
******************************************/

			else
			begin
				execute sp_msForEachDB 'Use ?; 
                                    Select ''?''
                                        , mi.databaseID
                                        , Object_Name(o.object_id)
                                        , o.object_id
                                        , mi.query_plan
                                        , GetDate()
                                        , mi.statementExecutions
                                    From sys.objects As o 
                                    Join #missingIndexes As mi 
                                        On o.object_id = mi.objectID 
                                    Where databaseID = DB_ID();';
			end;

/*********************************************
 See above; this part will only work if we've 
           logged our data. 
*********************************************/

			if @displayResults = 1
			   and @logResults = 1
			begin
				select *
				from dbo.sp_MissingIndexesProc
				where executionDate >= @currentDateTime;
			end;

/*******************************************
 If you have an open transaction, commit it 
*******************************************/

			if @@TranCount > 0
				commit transaction;
		end try
		begin catch

/****************************************
 Whoops, there was an error... rollback! 
****************************************/

			if @@TranCount > 0
				rollback transaction;

/***********************************
 Return an error message and log it 
***********************************/

			execute dbo.sp_LogError;
		end catch;

/**********
 Clean-Up! 
**********/

		drop table #missingIndexes;

		set nocount off;
		return 0;
	end;
end;
go

set quoted_identifier off;
go