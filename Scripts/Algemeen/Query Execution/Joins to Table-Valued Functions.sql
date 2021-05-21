/*	 Joins to Table-Valued Functions */
with xmlnamespaces('http://schemas.microsoft.com/sqlserver/2004/07/showplan' as p)
	 select st.text, 
			qp.query_plan
	 from (select top 50 *
		   from sys.dm_exec_query_stats
		   order by total_worker_time desc) as qs
		  cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
		  cross apply sys.dm_exec_query_plan(qs.plan_handle) as qp
	 where qp.query_plan.exist('//p:RelOp[contains(@LogicalOp, "Join")]/*/p:RelOp[(@LogicalOp[.="Table-valued function"])]') = 1;
go