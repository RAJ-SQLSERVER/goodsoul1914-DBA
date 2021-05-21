--	Queries with implicit conversion
--	http://sqlblog.com/blogs/jonathan_kehayias/archive/2010/01/08/finding-implicit-column-conversions-in-the-plan-cache.aspx
set nocount on;
set transaction isolation level read uncommitted;
declare @dbname sysname;
set @dbname = QUOTENAME(DB_NAME());

with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select DB_NAME(st.dbid) as dbName, 
			stmt.value('(@StatementText)[1]', 'varchar(max)') as SQLStatement, 
			t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)') as SchemaName, 
			t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)') as TableName, 
			t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)') as ColumnName, 
			ic.DATA_TYPE as ConvertFrom, 
			ic.CHARACTER_MAXIMUM_LENGTH as ConvertFromLength, 
			t.value('(@DataType)[1]', 'varchar(128)') as ConvertTo, 
			t.value('(@Length)[1]', 'int') as ConvertToLength, 
			query_plan
	 from sys.dm_exec_cached_plans as cp
		  inner join sys.dm_exec_query_stats as qs on cp.plan_handle = qs.plan_handle
		  cross apply sys.dm_exec_query_plan(cp.plan_handle) as qp
		  cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
		  cross apply query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') as batch(stmt)
		  cross apply stmt.nodes('.//Convert[@Implicit="1"]') as n(t)
		  join INFORMATION_SCHEMA.COLUMNS as ic on QUOTENAME(ic.TABLE_SCHEMA) = t.value('(ScalarOperator/Identifier/ColumnReference/@Schema)[1]', 'varchar(128)')
												   and QUOTENAME(ic.TABLE_NAME) = t.value('(ScalarOperator/Identifier/ColumnReference/@Table)[1]', 'varchar(128)')
												   and ic.COLUMN_NAME = t.value('(ScalarOperator/Identifier/ColumnReference/@Column)[1]', 'varchar(128)')
	 where t.exist('ScalarOperator/Identifier/ColumnReference[@Database=sql:variable("@dbname")][@Schema!="[sys]"]') = 1;