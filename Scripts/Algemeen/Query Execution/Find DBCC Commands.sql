select DB_NAME(ST.dbid) as DBName, 
	   qs.execution_count, 
	   qs.query_hash, 
	   st.text
from sys.dm_exec_query_stats as qs
	 cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
where st.text like '%DBCC%'
	  and ( DB_NAME(ST.dbid) not in ('master', 'tempdb')
			or dbid is null
		  )
	  and st.text not like '%blitz%'
	  and st.text not like '%uhtdba%';