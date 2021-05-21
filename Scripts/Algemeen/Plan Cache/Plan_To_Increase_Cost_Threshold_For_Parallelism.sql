/*
Author: Eitan Blumin, (t: @EitanBlumin | b: eitanblumin.com)
Date: February, 2018
Description:

The data returned by the script would be a list of execution plans,
their respective SQL statements, the Sub-Tree cost of the statements, and their usecounts.

Using this script, you will be able to identify execution plans that use parallelism, 
which may stop using parallelism if you change “cost threshold for parallelism” to a value
higher than their respective sub-tree cost.

More info:
https://eitanblumin.com/2018/11/06/planning-to-increase-cost-threshold-for-parallelism-like-a-smart-person
*/

DECLARE @MinUseCount          INT   = 10, -- Set minimum use count to ignore rarely-used plans
        @CurrentCostThreshold FLOAT = 5,  -- Serves as minimum sub-tree cost
        @MaxSubTreeCost       FLOAT = 30; -- Set the maximum sub-tree cost, plans with higher cost than this wouldn't normally interest us

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT @CurrentCostThreshold = CONVERT(FLOAT, value_in_use)
FROM   sys.configurations
WHERE  name = 'cost threshold for parallelism';

WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT   *
FROM
         (
             SELECT      ecp.plan_handle,
                         query_plan AS "CompleteQueryPlan",
                         n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS "StatementText",
                         n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS "StatementSubTreeCost",
                         n.query('.') AS "ParallelSubTreeXML",
                         ecp.usecounts,
                         ecp.size_in_bytes,
                         ROW_NUMBER() OVER (PARTITION BY n.value('(@StatementText)[1]', 'VARCHAR(4000)')
                                            ORDER BY ecp.usecounts DESC
                                           ) AS "RankPerText"
             FROM        sys.dm_exec_cached_plans AS ecp
             CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp
             CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n)
             WHERE       n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1
                         AND ecp.usecounts > @MinUseCount
                         AND n.value('(@StatementSubTreeCost)[1]', 'float')
                         BETWEEN @CurrentCostThreshold AND @MaxSubTreeCost
         ) AS Q
WHERE    RankPerText = 1 -- This would filter out duplicate statements, returning only those with the highest usecount
ORDER BY usecounts DESC;