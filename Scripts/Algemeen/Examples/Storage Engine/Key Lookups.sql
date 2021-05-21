-- Include actual plan and execute

select SalesOrderID, 
	   CarrierTrackingNumber, 
	   OrderQty, 
	   ProductID, 
	   UnitPrice, 
	   ModifiedDate
from Sales.SalesOrderDetail
where ModifiedDate > '2014-01-01'
	  and ProductID = 722;
go -- Table 'SalesOrderDetail'. Scan count 1, logical reads 1211	  
	  
-- Create covering index

create nonclustered index IX_SalesOrderDetail_ProductID on Sales.SalesOrderDetail
(ProductID asc) 
	include (CarrierTrackingNumber, UnitPrice, ModifiedDate, OrderQty) with (drop_existing = on, allow_page_locks = on) on [PRIMARY];

-- Include actual plan and execute

select SalesOrderID, 
	   CarrierTrackingNumber, 
	   OrderQty, 
	   ProductID, 
	   UnitPrice, 
	   ModifiedDate
from Sales.SalesOrderDetail
where ModifiedDate > '2014-01-01'
	  and ProductID = 722;
go -- Table 'SalesOrderDetail'. Scan count 1, logical reads 7	  

-- Restore original index

create nonclustered index IX_SalesOrderDetail_ProductID on Sales.SalesOrderDetail
(ProductID asc) 
	with (drop_existing = on, allow_page_locks = on) on [PRIMARY];
	  
-- Hunting down Key Lookups inside the Plan Cache

set transaction isolation level read uncommitted;
with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select n.value('(@StatementText)[1]', 'VARCHAR(4000)') as sql_text, 
			n.query('.'), 
			i.value('(@PhysicalOp)[1]', 'VARCHAR(128)') as PhysicalOp, 
			i.value('(./IndexScan/Object/@Database)[1]', 'VARCHAR(128)') as DatabaseName, 
			i.value('(./IndexScan/Object/@Schema)[1]', 'VARCHAR(128)') as SchemaName, 
			i.value('(./IndexScan/Object/@Table)[1]', 'VARCHAR(128)') as TableName, 
			i.value('(./IndexScan/Object/@Index)[1]', 'VARCHAR(128)') as IndexName, 
			i.query('.'), 
			STUFF(
	 (
		 select distinct 
				', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
		 from i.nodes('./OutputList/ColumnReference') as t(cg) for xml path('')
	 ), 1, 2, '') as output_columns, 
			STUFF(
	 (
		 select distinct 
				', ' + cg.value('(@Column)[1]', 'VARCHAR(128)')
		 from i.nodes('./IndexScan/SeekPredicates/SeekPredicateNew//ColumnReference') as t(cg) for xml path('')
	 ), 1, 2, '') as seek_columns, 
			i.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]', 'VARCHAR(4000)') as Predicate, 
			cp.usecounts, 
			query_plan
	 from
	 (
		 select plan_handle, 
				query_plan
		 from
		 (
			 select distinct 
					plan_handle
			 from sys.dm_exec_query_stats with(nolock)
		 ) as qs
		 outer apply sys.dm_exec_query_plan(qs.plan_handle) as tp
	 ) as tab(plan_handle, query_plan)
	 inner join sys.dm_exec_cached_plans as cp on tab.plan_handle = cp.plan_handle
	 cross apply query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/*') as q(n)
	 cross apply n.nodes('.//RelOp[IndexScan[@Lookup="1"] and IndexScan/Object[@Schema!="[sys]"]]') as s(i) option(recompile, maxdop 1);