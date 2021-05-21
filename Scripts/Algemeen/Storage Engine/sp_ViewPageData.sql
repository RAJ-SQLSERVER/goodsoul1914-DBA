if OBJECTPROPERTY(OBJECT_ID('dbo.sp_ViewPageData'), N'IsProcedure') is null
begin
	execute ('Create Procedure dbo.sp_ViewPageData As Print ''Hello World!''');
	raiserror('Procedure sp_ViewPageData created.', 10, 1);
end;
go

set ansi_nulls on;
set quoted_identifier on;
go

alter procedure dbo.sp_ViewPageData

/*******************
 Declare Parameters 
*******************/

	@databaseName varchar(128), 
	@tableName    varchar(128) = null, -- database.schema.tableName 
	@indexName    varchar(128) = null, 
	@fileNumber   int          = null, 
	@pageNumber   int          = null, 
	@printOption  int          = 3, -- 0, 1, 2, or 3 
	@pageType     char(4)      = 'Leaf' -- Leaf, Root, or IAM
as
begin

/*********************************************************************************************************
    NAME:           sp_ViewPageData

    SYNOPSIS:       Retrieves page data for the specified table/page.

    DEPENDENCIES:   The following dependencies are required to execute this script:
                    - SQL Server 2005 or newer
                    
    NOTES:          Can pass either the table name or the pageID, but must pass one, or
                    you'll end up with no results. 
                    If the table name is passed, it will return the first page.
    
                    @tableName must be '<databaseName>.<schemaName>.<tableName>' in order to
                        function correctly.  When called within the same database, the database
                        prefix may be omitted.  
            
                    @printOption can be one of following values:
                        0 - print just the page header
                        1 - page header plus per-row hex dumps and a dump of the page slot array
                        2 - page header plus whole page hex dump
                        3 - page header plus detailed per-row interpretation
                        
                    Page Options borrowed from: 
                    https://blogs.msdn.com/sqlserverstorageengine/archive/2006/06/10/625659.aspx
            
                    @pageType must be one of the following values:
                        Leaf - returns the first page of the leaf level of your index or heap
                        Root - returns the root page of your index
                        IAM - returns the index allocation map chain for your index or heap
            
                    Conversions borrowed from:
                    http://sqlskills.com/blogs/paul/post/Inside-The-Storage-Engine-
                    sp_AllocationMetadata-putting-undocumented-system-catalog-views-to-work.aspx

    AUTHOR:         Michelle Ufford, http://sqlfool.com
    
    CREATED:        2009-05-06
    
    VERSION:        1.0

    LICENSE:        Apache License v2
    
    USAGE:          EXEC dbo.sp_ViewPageData
                      @databaseName = 'AdventureWorks'
                    , @tableName    = 'AdventureWorks.Sales.SalesOrderDetail'
                    , @indexName    = 'IX_SalesOrderDetail_ProductID'
                    --, @fileNumber   = 1
                    --, @pageNumber   = 38208
                    , @printOption  = 3
                    , @pageType     = 'Root';

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

		declare @fileID        int, 
				@pageID        int, 
				@sqlStatement  nvarchar(1200), 
				@sqlParameters nvarchar(255), 
				@errorMessage  varchar(100);

		begin try

			if @fileNumber is null
			   and @pageNumber is null
			   and @tableName is null
			begin
				set @errorMessage = 'You must provide either a file/page number, or a table name!';
				raiserror(@errorMessage, 16, 1);
			end;

			if @pageType not in('Leaf', 'Root', 'IAM')
			begin
				set @errorMessage = 'You have entered an invalid page type; valid options are "Leaf", "Root", or "IAM"';
				raiserror(@errorMessage, 16, 1);
			end;

			if @fileNumber is null
			   or @pageNumber is null
			begin

				set @sqlStatement = case
										when @pageType = 'Leaf' then 'Select Top 1 @p_fileID = Convert (varchar(6), Convert (int, 
                    SubString (au.first_page, 6, 1) +
                    SubString (au.first_page, 5, 1)))
                , @p_pageID = Convert (varchar(20), Convert (int, 
                     SubString (au.first_page, 4, 1) +
                     SubString (au.first_page, 3, 1) +
                     SubString (au.first_page, 2, 1) +
                     SubString (au.first_page, 1, 1)))'
										when @pageType = 'Root' then 'Select Top 1 @p_fileID = Convert (varchar(6), Convert (int, 
                    SubString (au.root_page, 6, 1) +
                    SubString (au.root_page, 5, 1)))
                , @p_pageID = Convert (varchar(20), Convert (int, 
                     SubString (au.root_page, 4, 1) +
                     SubString (au.root_page, 3, 1) +
                     SubString (au.root_page, 2, 1) +
                     SubString (au.root_page, 1, 1)))'
										when @pageType = 'IAM' then 'Select Top 1 @p_fileID = Convert (varchar(6), Convert (int, 
                    SubString (au.first_iam_page, 6, 1) +
                    SubString (au.first_iam_page, 5, 1)))
                , @p_pageID = Convert (varchar(20), Convert (int, 
                     SubString (au.first_iam_page, 4, 1) +
                     SubString (au.first_iam_page, 3, 1) +
                     SubString (au.first_iam_page, 2, 1) +
                     SubString (au.first_iam_page, 1, 1)))'
									end + 'From ' + QUOTENAME(PARSENAME(@databaseName, 1)) + '.sys.indexes AS i
            Join ' + QUOTENAME(PARSENAME(@databaseName, 1)) + '.sys.partitions AS p
                On i.[object_id] = p.[object_id]
                And i.index_id = p.index_id
            Join ' + QUOTENAME(PARSENAME(@databaseName, 1)) + '.sys.system_internals_allocation_units AS au
                On p.hobt_id = au.container_id
            Where p.[object_id] = Object_ID(@p_tableName)
                And au.first_page > 0x000000000000 ' + case
														   when @indexName is null then ';'
													   else 'And i.name = @p_indexName;'
													   end;

				set @sqlParameters = '@p_tableName varchar(128)
                                , @p_indexName varchar(128)
                                , @p_fileID int OUTPUT
                                , @p_pageID int OUTPUT';

				execute sp_executeSQL @sqlStatement, @sqlParameters, @p_tableName = @tableName, @p_indexName = @indexName, @p_fileID = @fileID output, @p_pageID = @pageID output;
			end;
			else
			begin
				select @fileID = @fileNumber, 
					   @pageID = @pageNumber;
			end;

			dbcc traceon(3604);
			dbcc page(@databaseName, @fileID, @pageID, @printOption);
			dbcc traceoff(3604);
		end try
		begin catch

			print @errorMessage;
		end catch;

		set nocount off;
		return 0;
	end;
end;
go

set quoted_identifier off;
go