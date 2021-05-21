-- Get compiled plans with params from the plan cache
-- ------------------------------------------------------------------------------------------------

select cvalue.DBName, 
	   cvalue.ObjectName, 
	   SUBSTRING(cvalue.text, cvalue.statement_start_offset, cvalue.statement_end_offset) as sql_text, 
	   cvalue.query_plan, 
	   pc.compiled.value ('@Column', 'nvarchar(128)') as Parameterlist, 
	   pc.compiled.value ('@ParameterCompiledValue', 'nvarchar(128)') as [compiled Value]
from
(
	select OBJECT_NAME(est.objectid) as ObjectName, 
		   DB_NAME(est.dbid) as DBName, 
		   eqs.plan_handle, 
		   eqs.query_hash, 
		   est.text, 
		   eqp.query_plan, 
		   eqs.statement_start_offset / 2 + 1 as statement_start_offset, 
		   ( case
				 when eqs.statement_end_offset = -1 then LEN(CONVERT(nvarchar(max), est.text)) * 2
				 else eqs.statement_end_offset
			 end - eqs.statement_start_offset ) / 2 as statement_end_offset, 
		   TRY_CONVERT( xml, SUBSTRING(etqp.query_plan, CHARINDEX('<ParameterList>', etqp.query_plan), CHARINDEX('</ParameterList>', etqp.query_plan) + LEN('</ParameterList>') - CHARINDEX('<ParameterList>', etqp.query_plan))) as Parameters
	from sys.dm_exec_query_stats as eqs
		 cross apply sys.dm_exec_sql_text (eqs.sql_handle) as est
		 cross apply sys.dm_exec_text_query_plan (eqs.plan_handle, eqs.statement_start_offset, eqs.statement_end_offset) as etqp
		 cross apply sys.dm_exec_query_plan (eqs.plan_handle) as eqp
	where est.ENCRYPTED <> 1
) as cvalue
outer apply cvalue.parameters.nodes ('//ParameterList/ColumnReference') as pc(compiled);
go