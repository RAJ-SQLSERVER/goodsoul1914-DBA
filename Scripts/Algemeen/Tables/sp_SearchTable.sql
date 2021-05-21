if OBJECT_ID('SP_SearchTables', 'P') is not null
	drop procedure SP_SearchTables;
go

create procedure SP_SearchTables 
	@Tablenames      varchar(500), 
	@SearchStr       nvarchar(500), 
	@GenerateSQLOnly bit           = 0, 
	@SchemaNames     varchar(500)  = '%', 
	@SearchCollation sysname       = ''
as
begin

/********************************************************************************************************************************
	 Parameters and usage
	 
	 @Tablenames		-- Provide a single table name or multiple table name with comma seperated. 
	 If left blank , it will check for all the tables in the database
	 Provide wild card tables names with comma seperated
	 EX :'%tbl%,Dim%' -- This will search the table having names comtains "tbl" and starts with "Dim"
	 
	 @SearchStr		-- Provide the search string. Use the '%' to coin the search. Also can provide multiple search with comma seperated
	 EX : X%--- will give data staring with X
	 %X--- will give data ending with X
	 %X%--- will give data containig  X
	 %X%,Y%--- will give data containig  X or starting with Y
	 %X%,%,,% -- Use a double comma to search comma in the data
	 @GenerateSQLOnly -- Provide 1 if you only want to generate the SQL statements without seraching the database. 
	 By default it is 0 and it will search.
	 
	 @SchemaNames	-- Provide a single Schema name or multiple Schema name with comma seperated. 
	 If left blank , it will check for all the tables in the database
	 Provide wild card Schema names with comma seperated
	 EX :'%dbo%,Sales%' -- This will search the Schema having names comtains "dbo" and starts with "Sales"
	 
	 @SearchCollation -- Provide a valid collation to be used for searching.
	 If left blank , database default collation will be used.
	 EX : 'sql_latin1_general_cp1_cs_as' -- This will do a case sensitive search as "cs_as" collation has been provided.
	 
	 Samples :
	 
	 1. To search data in a table
	 
	 EXEC SP_SearchTables @Tablenames = 'T1'
	 ,@SearchStr  = '%TEST%'
	 
	 The above sample searches in table T1 with string containing TEST.
	 
	 2. To search in a multiple table
	 
	 EXEC SP_SearchTables @Tablenames = 'T2'
	 ,@SearchStr  = '%TEST%'
	 
	 The above sample searches in tables T1 & T2 with string containing TEST.
	 
	 3. To search in a all table
	 
	 EXEC SP_SearchTables @Tablenames = '%'
	 ,@SearchStr  = '%TEST%'
	 
	 The above sample searches in all table with string containing TEST.
	 
	 4. Generate the SQL for the Select statements
	 
	 EXEC SP_SearchTables @Tablenames		= 'T1'
	 ,@SearchStr		= '%TEST%'
	 ,@GenerateSQLOnly	= 1
	 
	 5. To Search in tables with specfic name
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%'
	 ,@SearchStr		= '%TEST%'
	 ,@GenerateSQLOnly	= 0
	 
	 6. To Search in multiple tables with specfic names
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%,Dim%'
	 ,@SearchStr		= '%TEST%'
	 ,@GenerateSQLOnly	= 0
	 
	 7. To specify multiple search strings
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%,Dim%'
	 ,@SearchStr		= '%TEST%,TEST1%,%TEST2'
	 ,@GenerateSQLOnly	= 0
	 
	 
	 8. To search comma itself in the tables use double comma ",,"
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%,Dim%'
	 ,@SearchStr		= '%,,%'
	 ,@GenerateSQLOnly	= 0
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%,Dim%'
	 ,@SearchStr		= '%with,,comma%'
	 ,@GenerateSQLOnly	= 0
	 
	 9. To Search by SchemaName
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%,Dim%'
	 ,@SearchStr		= '%,,%'
	 ,@GenerateSQLOnly	= 0
	 ,@SchemaNames		= '%dbo%,Sales%'
	 
	 10. To search using a Collation
	 
	 EXEC SP_SearchTables @Tablenames		= '%T1%,Dim%'
	 ,@SearchStr		= '%,,%'
	 ,@GenerateSQLOnly	= 0
	 ,@SchemaNames		= '%dbo%,Sales%'
	 ,@SearchCollation	= 'sql_latin1_general_cp1_cs_as'
********************************************************************************************************************************/

	set nocount on;

	declare @MatchFound bit;

	select @MatchFound = 0;

	declare @CheckTableNames table
	(
		Schemaname sysname, 
		Tablename  sysname);
	declare @SearchStringTbl table
	(
		SearchString varchar(500));
	declare @SQLTbl table
	(
		Tablename    sysname, 
		WHEREClause  nvarchar(max), 
		SQLStatement nvarchar(max), 
		Execstatus   bit);
	declare @SQL nvarchar(max);
	declare @TableParamSQL varchar(max);
	declare @SchemaParamSQL varchar(max);
	declare @TblSQL varchar(max);
	declare @tmpTblname sysname;
	declare @ErrMsg nvarchar(max);

	if LTRIM(RTRIM(@Tablenames)) = ''
	begin
		select @Tablenames = '%';
	end;

	if LTRIM(RTRIM(@SchemaNames)) = ''
	begin
		select @SchemaNames = '%';
	end;

	if CHARINDEX(',', @Tablenames) > 0
		select @TableParamSQL = 'SELECT ''' + REPLACE(@Tablenames, ',', '''as TblName UNION SELECT ''') + '''';
		else
		select @TableParamSQL = 'SELECT ''' + @Tablenames + ''' as TblName ';

	if CHARINDEX(',', @SchemaNames) > 0
		select @SchemaParamSQL = 'SELECT ''' + REPLACE(@SchemaNames, ',', '''as SchemaName UNION SELECT ''') + '''';
		else
		select @SchemaParamSQL = 'SELECT ''' + @SchemaNames + ''' as SchemaName ';

	select @TblSQL = 'SELECT SCh.NAME,T.NAME
							FROM SYS.TABLES T
							JOIN SYS.SCHEMAS SCh
							   ON SCh.SCHEMA_ID = T.SCHEMA_ID
							JOIN (' + @TableParamSQL + ') tblsrc
							 ON T.name LIKE tblsrc.tblname 
							JOIN (' + @SchemaParamSQL + ') schemasrc
							 ON SCh.name LIKE schemasrc.SchemaName 
							 
							 ';

	insert into @CheckTableNames (Schemaname, 
								  Tablename) 
	exec (@TblSQL);

	if not exists
	(
		select 1
		from @CheckTableNames
	) 
	begin
		select @ErrMsg = 'No tables are found in this database ' + DB_NAME() + ' for the specified filter';

		print @ErrMsg;

		return;
	end;

	if LTRIM(RTRIM(@SearchCollation)) <> ''
	begin
		if not exists
		(
			select 1
			from SYS.fn_helpcollations()
			where UPPER(NAME) = UPPER(@SearchCollation)
		) 
		begin
			select @ErrMsg = 'Invalid Collation (' + @SearchCollation + ').Please specify a valid collation or specify Blank to work with Default Collation.';

			print @ErrMsg;

			return;
		end;
	end;

	if LTRIM(RTRIM(@SearchStr)) = ''
	begin
		select @ErrMsg = 'Please specify the search string in @SearchStr Parameter';

		print @ErrMsg;

		return;
	end;
		else
	begin
		select @SearchStr = REPLACE(@SearchStr, ',,,', ',#DOUBLECOMMA#');

		select @SearchStr = REPLACE(@SearchStr, ',,', '#DOUBLECOMMA#');

		select @SearchStr = REPLACE(@SearchStr, '''', '''''');

		select @SQL = 'SELECT N''' + REPLACE(@SearchStr, ',', '''as SearchString UNION SELECT ''') + '''';

		insert into @SearchStringTbl (SearchString) 
		exec (@SQL);

		update @SearchStringTbl
		set SearchString = REPLACE(SearchString, '#DOUBLECOMMA#', ',');
	end;

	insert into @SQLTbl (Tablename, 
						 WHEREClause) 
	select QUOTENAME(SCh.name) + '.' + QUOTENAME(ST.NAME), 
	(
		select '[' + SC.Name + ']' + ' LIKE N''' + REPLACE(SearchSTR.SearchString, '''', '''''') + ''' OR ' + CHAR(10)
		from SYS.columns as SC
			 join SYS.types as STy on STy.system_type_id = SC.system_type_id
									  and STy.user_type_id = SC.user_type_id
			 cross join @SearchStringTbl as SearchSTR
		where STY.name in ('varchar', 'char', 'nvarchar', 'nchar', 'text')
			  and SC.object_id = ST.object_id
		order by SC.name for xml path('')
	)
	from SYS.tables as ST
		 join @CheckTableNames as chktbls on chktbls.Tablename = ST.name
		 join SYS.schemas as SCh on ST.schema_id = SCh.schema_id
									and Sch.name = chktbls.Schemaname
	where ST.name <> 'SearchTMP'
	group by ST.object_id, 
			 QUOTENAME(SCh.name) + '.' + QUOTENAME(ST.NAME);

	update @SQLTbl
	set SQLStatement = 'SELECT * INTO SearchTMP FROM ' + Tablename + ' WHERE ' + SUBSTRING(WHEREClause, 1, LEN(WHEREClause) - 5);

	delete from @SQLTbl
	where WHEREClause is null;

	while exists
	(
		select 1
		from @SQLTbl
		where ISNULL(Execstatus, 0) = 0
	) 
	begin
		select top 1 @tmpTblname = Tablename, 
					 @SQL = SQLStatement
		from @SQLTbl
		where ISNULL(Execstatus, 0) = 0;

		if LTRIM(RTRIM(@SearchCollation)) <> ''
		begin
			select @SQL = @SQL + CHAR(13) + ' COLLATE ' + @SearchCollation;
		end;

		if @GenerateSQLOnly = 0
		begin
			if OBJECT_ID('SearchTMP', 'U') is not null
				drop table SearchTMP;

			exec (@SQL);

			if exists
			(
				select 1
				from SearchTMP
			) 
			begin
				select Tablename = @tmpTblname, 
					   *
				from SearchTMP;

				select @MatchFound = 1;
			end;
		end;
			else
		begin
			print REPLICATE('-', 100);
			print @tmpTblname;
			print REPLICATE('-', 100);
			print REPLACE(@SQL, 'INTO SearchTMP', '');
		end;

		update @SQLTbl
		set Execstatus = 1
		where Tablename = @tmpTblname;
	end;

	if @MatchFound = 0
	begin
		select @ErrMsg = 'No Matches are found in this database ' + DB_NAME() + ' for the specified filter';

		print @ErrMsg;

		return;
	end;

	set nocount off;
end;
go