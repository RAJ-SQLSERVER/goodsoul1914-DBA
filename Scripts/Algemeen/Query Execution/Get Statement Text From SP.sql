select DEST.text, 
	   SUBSTRING(DEST.text, DEQS.statement_start_offset / 2 + 1, ( case deqs.statement_end_offset
																	   when -1 then DATALENGTH(dest.text)
																   else deqs.statement_end_offset
																   end - DEQS.statement_start_offset ) / 2 + 1) as statement_text, 
	   DEQS.*
from sys.dm_exec_query_stats as DEQS
	 cross apply sys.dm_exec_sql_text(DEQS.sql_handle) as DEST;