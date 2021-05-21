-- Tuning 'cost threshold for parallelism' from the Plan Cache
--
-- Blog post that explains this: http://bit.ly/Ohrqx7
--
-- I look at the high use count plans, and see if there is a missing index 
-- associated with those queries that is driving the cost up 
-- 
-- If I can tune the high execution queries to reduce their cost, I have a 
-- win either way. However, if you run this query, you will note that there 
-- are some really high cost queries that you may not get below the five 
-- value
--
-- If you can fix the high use plans to reduce their cost, and then increase 
-- the ‘cost threshold for parallelism’ based on the cost of your larger 
-- queries that may benefit from parallelism, having a couple of low use 
-- count plans that use parallelism doesn’t have as much of an impact to the 
-- server overall, at least based on my own personal experiences
------------------------------------------------------------------------------------------------

set transaction isolation level read uncommitted;
go

with xmlnamespaces(default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
	 select query_plan as CompleteQueryPlan, 
			n.value ('(@StatementText)[1]', 'VARCHAR(4000)') as StatementText, 
			n.value ('(@StatementOptmLevel)[1]', 'VARCHAR(25)') as StatementOptimizationLevel, 
			n.value ('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') as StatementSubTreeCost, 
			n.query ('.') as ParallelSubTreeXML, 
			ecp.usecounts, 
			ecp.size_in_bytes
	 from sys.dm_exec_cached_plans as ecp
		  cross apply sys.dm_exec_query_plan (plan_handle) as eqp
		  cross apply query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') as qn(n)
	 where n.query ('.') .exist ('//RelOp[@PhysicalOp="Parallelism"]') = 1;
go