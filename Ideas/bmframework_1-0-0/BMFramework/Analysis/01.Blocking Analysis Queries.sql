/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                       Blocking Analysis Queries                          */
/****************************************************************************/

USE DBA;
GO

-- Find 10 queries that were blocked the most based on plan_hash
WITH Data AS
(
    SELECT TOP 10 i.BlockedPlanHash,
                  COUNT (*) AS "Blocking Counts",
                  SUM (WaitTime) AS "Total Wait Time (ms)"
    FROM dbo.BlockedProcessesInfo AS i
    GROUP BY i.BlockedPlanHash
    ORDER BY SUM (WaitTime) DESC
)
SELECT d.*,
       q.BlockedSql
FROM Data AS d
CROSS APPLY (
    SELECT TOP 1 BlockedSql
    FROM dbo.BlockedProcessesInfo AS i2
    WHERE i2.BlockedPlanHash = d.BlockedPlanHash
    ORDER BY EventDate DESC
) AS q;
GO

-- Find 10 queries that were blocked the most based on query_hash
;WITH Data AS
 (
     SELECT TOP 10 i.BlockedQueryHash,
                   COUNT (*) AS "Blocking Counts",
                   SUM (WaitTime) AS "Total Wait Time (ms)"
     FROM dbo.BlockedProcessesInfo AS i
     GROUP BY i.BlockedQueryHash
     ORDER BY SUM (WaitTime) DESC
 )
SELECT d.*,
       q.BlockedSql
FROM Data AS d
CROSS APPLY (
    SELECT TOP 1 BlockedSql
    FROM dbo.BlockedProcessesInfo AS i2
    WHERE i2.BlockedQueryHash = d.BlockedQueryHash
    ORDER BY EventDate DESC
) AS q;
GO

-- Get list of objects which suffer from I* waits
;WITH Objects (DBID, ObjID, WaitTime) AS
 (
     SELECT LTRIM (RTRIM (SUBSTRING (b.Resource, 8, o.DBSeparator - 8))),
            SUBSTRING (b.Resource, o.DBSeparator + 1, o.ObjectLen),
            b.WaitTime
     FROM dbo.BlockedProcessesInfo AS b
     CROSS APPLY (
         SELECT CHARINDEX (':', Resource, 8) AS "DBSeparator",
                CHARINDEX (':', Resource, CHARINDEX (':', Resource, 8) + 1) - CHARINDEX (':', Resource, 8) - 1 AS "ObjectLen"
     ) AS o
     WHERE LEFT(b.Resource, 6) = 'OBJECT'
           AND LEFT(b.BlockedLockMode, 1) = 'I'
 )
SELECT DB_NAME (DBID) AS "database",
       OBJECT_NAME (ObjID, DBID) AS "table",
       COUNT (*) AS "# of events",
       SUM (WaitTime) / 1000 AS "Wait Time(Sec)"
FROM Objects
GROUP BY DB_NAME (DBID),
         OBJECT_NAME (ObjID, DBID);
