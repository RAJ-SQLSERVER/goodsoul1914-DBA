/*******************************************************************************************************************
By: Jonathan Kehayias
Posted on: September 21, 2011 5:35 pm
https://www.sqlskills.com/blogs/jonathan/finding-what-queries-in-the-plan-cache-use-a-specific-index/
*******************************************************************************************************************/

set transaction isolation level read uncommitted;

declare @IndexName as nvarchar(128) = N'[PK_Users_Id]',
		@lb as        nchar(1)      = N'[', 
		@rb as        nchar(1)      = N']';

-- Make sure the name passed is appropriately quoted
if LEFT(@IndexName, 1) <> '['
   and RIGHT(@IndexName, 1) <> ']'
	set @IndexName = QUOTENAME(@IndexName);

-- Handle the case where the left or right was quoted manually but not the opposite side
if LEFT(@IndexName, 1) <> '['
	set @IndexName = '[' + @IndexName;
if RIGHT(@IndexName, 1) <> ']'
	set @IndexName = @IndexName + ']';

-- Dig into the plan cache and find all plans using this index
with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select stmt.value('(@StatementText)[1]', 'varchar(max)') as SqlText, 
			obj.value('(@Database)[1]', 'varchar(128)') as DatabaseName, 
			obj.value('(@Schema)[1]', 'varchar(128)') as SchemaName, 
			obj.value('(@Table)[1]', 'varchar(128)') as TableName, 
			obj.value('(@Index)[1]', 'varchar(128)') as IndexName, 
			obj.value('(@IndexKind)[1]', 'varchar(128)') as IndexKind, 
			cp.plan_handle as PlanHandle, 
			query_plan as QueryPlan
	 from sys.dm_exec_cached_plans as cp
		  cross apply sys.dm_exec_query_plan(plan_handle) as qp
		  cross apply query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') as batch(stmt)
		  cross apply stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') as idx(obj) option(maxdop 1, recompile);