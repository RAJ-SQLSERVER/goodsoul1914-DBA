/***************************************************************************
				Get Top Query Plans with Warnings from Cache
				--------------------------------------------
Author: Eitan Blumin | https://www.eitanblumin.com
Change Log:
	2020-01-29 - Added a few more warnings from sp_BlitzCache: https://www.brentozar.com/blitzcache/
	2020-01-12 - First version
****************************************************************************/

DECLARE @MinimumSubTreeCost FLOAT = 30,
        @MinUseCount INT = 1,
        @Top INT = 5;
WITH XMLNAMESPACES
(
    DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan',
    N'http://schemas.microsoft.com/sqlserver/2004/07/showplan' AS p
)
SELECT TOP (@Top)
       *
FROM
(
    SELECT CP.cacheobjtype,
           CP.objtype,
           objdb = DB_NAME(QPMain.dbid),
           objschema = OBJECT_SCHEMA_NAME(QPMain.objectid, QPMain.dbid),
           objname = OBJECT_NAME(QPMain.objectid, QPMain.dbid),
           CP.usecounts,
           CP.refcounts,
           QPMain.dbid,
           QPMain.objectid,
           QPMain.query_plan,
           statement_query_plan = QP.query_plan.query('.'),
           statement_Text = QP.query_plan.value('(@StatementText)[1]', 'VARCHAR(4000)'),
           statement_subtree_cost = QP.query_plan.value('(@StatementSubTreeCost)[1]', 'FLOAT'),
           HasParallelism = QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Parallelism"][1])'),
           WarningTypes = STUFF(
                          (
                              SELECT ', ' + warning
                              FROM
                              (
                                  SELECT DISTINCT
                                         CAST(node_xml.query('local-name(.)') AS VARCHAR(1000)) AS warning
                                  FROM QP.query_plan.nodes('//Warnings/*') AS W(node_xml)
                                  UNION ALL
                                  SELECT 'HasClusteredIndexScan'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Clustered Index Scan"][1])') = 1
                                  UNION ALL
                                  SELECT 'HasIndexScan'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Index Scan"][1])') = 1
                                  --SELECT 'HasIndexScan' WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Index Scan"][@EstimateRows * @AvgRowSize > 5000.0][1])') = 1
                                  UNION ALL
                                  SELECT 'HasTableScan'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Table Scan"][1])') = 1
                                  UNION ALL
                                  SELECT 'HasKeyLookup'
                                  WHERE QP.query_plan.query('.').exist('data(//IndexScan[@Lookup="1"][1])') = 1
                                  UNION ALL
                                  SELECT 'HasRIDLookup'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="RID Lookup"][1])') = 1
                                  UNION ALL
                                  SELECT 'HasTableSpool'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Table Spool"][1])') = 1
                                  UNION ALL
                                  SELECT 'HasIndexSpool'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[@PhysicalOp="Index Spool"][1])') = 1
                                  UNION ALL
                                  SELECT 'HasMissingIndexes'
                                  WHERE QP.query_plan.query('.').exist('data(//MissingIndexes[1])') = 1
                                  UNION ALL
                                  SELECT 'SortOperator'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[(@PhysicalOp[.="Sort"])])') = 1
                                  UNION ALL
                                  SELECT 'UserFunctionFilter'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp/Filter/Predicate/ScalarOperator/Compare/ScalarOperator/UserDefinedFunction[1])') = 1
                                  UNION ALL
                                  SELECT 'HasRemoteQuery'
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[(@PhysicalOp[contains(., "Remote")])])') = 1
                                  UNION ALL
                                  SELECT 'CompileMemoryLimitExceeded'
                                  WHERE QP.query_plan.query('.').exist('data(//StmtSimple/@StatementOptmEarlyAbortReason[.="MemoryLimitExceeded"])') = 1
                                  UNION ALL
                                  SELECT TOP 1
                                         'NonSargeableScalarFunction'
                                  FROM QP.query_plan.nodes('//RelOp/IndexScan/Predicate/ScalarOperator/Compare/ScalarOperator') AS ca(x)
                                  WHERE (
                                            ca.x.query('.').exist('//ScalarOperator/Intrinsic/@FunctionName') = 1
                                            OR ca.x.query('.').exist('//ScalarOperator/IF') = 1
                                        )
                                  UNION ALL
                                  SELECT TOP 1
                                         'NonSargeableExpressionWithJoin'
                                  FROM QP.query_plan.nodes('//RelOp//ScalarOperator') AS ca(x)
                                  WHERE QP.query_plan.query('.').exist('data(//RelOp[contains(@LogicalOp, "Join")])') = 1
                                        AND ca.x.query('.').exist('//ScalarOperator[contains(@ScalarString, "Expr")]') = 1
                                  UNION ALL
                                  SELECT TOP 1
                                         'NonSargeableLIKE'
                                  FROM QP.query_plan.nodes('//RelOp/IndexScan/Predicate/ScalarOperator') AS ca(x)
                                      CROSS APPLY ca.x.nodes('//Const') AS co(x)
                                  WHERE ca.x.query('.').exist('//ScalarOperator/Intrinsic/@FunctionName[.="like"]') = 1
                                        AND
                                        (
                                            (
                                                co.x.value('substring(@ConstValue, 1, 1)', 'VARCHAR(100)') <> 'N'
                                                AND co.x.value('substring(@ConstValue, 2, 1)', 'VARCHAR(100)') = '%'
                                            )
                                            OR
                                            (
                                                co.x.value('substring(@ConstValue, 1, 1)', 'VARCHAR(100)') = 'N'
                                                AND co.x.value('substring(@ConstValue, 3, 1)', 'VARCHAR(100)') = '%'
                                            )
                                        )
                              ) AS w
                              FOR XML PATH('')
                          ),
                          1,
                          2,
                          ''
                               ),
           MissingIndexes = QP.query_plan.query('//MissingIndexes')
    --,MemoryGrantInfo = QP.query_plan.query('//MemoryGrantInfo')
    --,OptimizerHardwareDependentProperties = QP.query_plan.query('//OptimizerHardwareDependentProperties')
    --,StatementSetOptions = QP.query_plan.query('//StatementSetOptions')
    FROM sys.dm_exec_cached_plans AS CP
        CROSS APPLY sys.dm_exec_query_plan(CP.plan_handle) AS QPMain
        CROSS APPLY QPMain.query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS QP(query_plan)
    WHERE CP.usecounts >= @MinUseCount
) AS q
WHERE WarningTypes <> ''
      AND statement_subtree_cost >= @MinimumSubTreeCost
ORDER BY statement_subtree_cost DESC,
         usecounts DESC;