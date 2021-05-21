if OBJECTPROPERTY(OBJECT_ID('dbo.sp_LogError'), N'IsProcedure') = 1
begin
	drop procedure dbo.sp_LogError;
	print 'Procedure sp_LogError dropped';
end;
go
 
if OBJECTPROPERTY(OBJECT_ID('dbo.ErrorLog'), N'IsTable') is null
begin

	create table dbo.ErrorLog
	(
		errorLog_id    int identity(1, 1), 
		errorType      char(3) constraint DF_errorLog_errorType default 'sys', 
		errorDate      datetime constraint DF_errorLog_errorDate default GETDATE(), 
		errorLine      int, 
		errorMessage   nvarchar(4000), 
		errorNumber    int, 
		errorProcedure nvarchar(126), 
		procParameters nvarchar(4000), 
		errorSeverity  int, 
		errorState     int, 
		databaseName   nvarchar(255)
		constraint PK_errorLog_errorLogID primary key clustered (errorLog_id));

	print 'Table ErrorLog created';

end;
go


set ansi_nulls on;
set ansi_padding on;
set ansi_warnings on;
set arithabort on;
set concat_null_yields_null on;
set nocount on;
set numeric_roundabort off;
set quoted_identifier on;
go
 
create procedure dbo.sp_LogError
(
    
/*******************
 Declare Parameters 
*******************/

	@errorType          char(3)        = 'sys', 
	@app_errorProcedure varchar(50)    = '', 
	@app_errorMessage   nvarchar(4000) = '', 
	@procParameters     nvarchar(4000) = '', 
	@userFriendly       bit            = 0, 
	@forceExit          bit            = 1, 
	@returnError        bit            = 1) 
as
begin

/****************************************************************************
    Name:       sp_LogError
 
    Author:     Michelle F. Ufford, http://sqlfool.com
 
    Purpose:    Retrieves error information and logs in the 
                        ErrorLog table.
 
        @errorType = options are "app" or "sys"; "app" are custom 
                application errors, i.e. business logic errors;
                "sys" are system errors, i.e. PK errors
 
        @app_errorProcedure = stored procedure name, 
                needed for app errors
 
        @app_errorMessage = custom app error message
 
        @procParameters = optional; log the parameters that were passed
                to the proc that resulted in an error
 
        @userFriendly = displays a generic error message if = 1
 
        @forceExit = forces the proc to rollback and exit; 
                mostly useful for application errors.
 
        @returnError = returns the error to the calling app if = 1
 
    Called by:	Another stored procedure
 
    Date        Initials    Description
	----------------------------------------------------------------------------
    2008-12-16  MFU         Initial Release
****************************************************************
    Exec dbo.sp_LogError
        @errorType          = 'app'
      , @app_errorProcedure = 'someTableInsertProcName'
      , @app_errorMessage   = 'Some app-specific error message'
      , @userFriendly       = 1
      , @forceExit          = 1
      , @returnError        = 1;
****************************************************************************/

	set nocount on;
	set xact_abort on;

	begin
 
    /******************
 Declare Variables 
******************/

		declare @errorNumber         int, 
				@errorProcedure      varchar(50), 
				@dbName              sysname, 
				@errorLine           int, 
				@errorMessage        nvarchar(4000), 
				@errorSeverity       int, 
				@errorState          int, 
				@errorReturnMessage  nvarchar(4000), 
				@errorReturnSeverity int, 
				@currentDateTime     smalldatetime;

		declare @errorReturnID table
		(
			errorID varchar(10));
 
    /*********************
 Initialize Variables 
*********************/

		select @currentDateTime = GETDATE();
 
    /**************************
 Capture our error details 
**************************/

		if @errorType = 'sys'
		begin
 
        /*****************************************
 Get our system error details and hold it 
*****************************************/

			select @errorNumber = ERROR_NUMBER(), 
				   @errorProcedure = ERROR_PROCEDURE(), 
				   @dbName = DB_NAME(), 
				   @errorLine = ERROR_LINE(), 
				   @errorMessage = ERROR_MESSAGE(), 
				   @errorSeverity = ERROR_SEVERITY(), 
				   @errorState = ERROR_STATE();

		end;
		else
		begin
 
    	/*********************************************
 Get our custom app error details and hold it 
*********************************************/

			select @errorNumber = 0, 
				   @errorProcedure = @app_errorProcedure, 
				   @dbName = DB_NAME(), 
				   @errorLine = 0, 
				   @errorMessage = @app_errorMessage, 
				   @errorSeverity = 0, 
				   @errorState = 0;

		end;
 
    /*****************************
 And keep a copy for our logs 
*****************************/

		insert into dbo.ErrorLog (errorType, 
									  errorDate, 
									  errorLine, 
									  errorMessage, 
									  errorNumber, 
									  errorProcedure, 
									  procParameters, 
									  errorSeverity, 
									  errorState, 
									  databaseName) 
		output Inserted.errorLog_id
			   into @errorReturnID
		values(
			@errorType, @currentDateTime, @errorLine, @errorMessage, @errorNumber, @errorProcedure, @procParameters, @errorSeverity, @errorState, @dbName);
 
    /**************************************************************
 Should we display a user friendly message to the application? 
**************************************************************/

		if @userFriendly = 1
			select @errorReturnMessage = 'An error has occurred in the database (' + errorID + ')'
			from @errorReturnID;
		else
			select @errorReturnMessage = @errorMessage;
 
    /*********************************************
 Do we want to force the application to exit? 
*********************************************/

		if @forceExit = 1
			select @errorReturnSeverity = 15;
		else
			select @errorReturnSeverity = @errorSeverity;
 
    /*******************************************************
 Should we return an error message to the calling proc? 
*******************************************************/

		if @returnError = 1
			raiserror(@errorReturnMessage, @errorReturnSeverity, 1) with nowait;

		set nocount off;
		return 0;

	end;
end;
go