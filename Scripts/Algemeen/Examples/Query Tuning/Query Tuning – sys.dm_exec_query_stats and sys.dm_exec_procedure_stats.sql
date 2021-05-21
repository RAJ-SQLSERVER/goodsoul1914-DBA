set statistics time, io on;

use AdventureWorks2014;
go

dbcc freeproccache;

select *
from sys.dm_exec_query_stats;
select *
from sys.dm_exec_procedure_stats;
go

alter proc salesdetails
as
begin
	select *
	from Sales.SalesOrderHeader;
	select *
	from Sales.SalesOrderDetail;
end;
go

exec salesdetails;
go

--SQL Server Execution Times:
--   CPU time = 94 ms,  elapsed time = 1399 ms.

-- SQL Server Execution Times:
--   CPU time = 141 ms,  elapsed time = 2090 ms.


select DEST.text, 
	   DEPS.*
from sys.dm_exec_query_stats as DEPS
	 cross apply sys.dm_exec_sql_text(DEPS.sql_handle) as DEST;

select (94 + 141)
select (43694 + 129150)/1000  


select DEST.text, 
	   DEPS.*
from sys.dm_exec_procedure_stats as DEPS
	 cross apply sys.dm_exec_sql_text(DEPS.sql_handle) as DEST;


select DEST.text, 
	   SUBSTRING(DEST.text, DEQS.statement_start_offset / 2 + 1, ( case deqs.statement_end_offset
																	   when -1 then DATALENGTH(dest.text)
																   else deqs.statement_end_offset
																   end - DEQS.statement_start_offset ) / 2 + 1) as statement_text, 
	   DEQS.*
from sys.dm_exec_query_stats as DEQS
	 cross apply sys.dm_exec_sql_text(DEQS.sql_handle) as DEST;
