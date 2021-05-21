/***********************************************************************************

Created By: Jen McCown
Creation Date: 10/3/2014


Purpose: This query determines how much longer the in-progress reindex will take.

Discussion: It looks at the tables and indexes that are being done in the 
	current run and compare them with the last run of that table/index 
	combo so it knows how long it took last time. 
	
	Add all those up and tell us which tables are left, and how long 
	each one will take as well as a total time for the entire rest of the job.

	This isn't a perfect predictor, of course, but just a "best guess" estimate.
	Note also that if an index is being maintained now, but wasn't in the last
	run, then it won't show up in the estimate.


Variables:
-----------

    @DBName - Database name for which we estaimte reindex time.
    

Tables:
--------

Revision History:
	* Solution 1
	The first pass solution for this task. 

	This is a sample query, so it takes a @DBName variable; for a "per db" estimate, this query 
	should in future use the database current to the cursor.

	This basically says, “anything that’s in the IndexTableFrag table must be up for reindexing”. 
	So, we look at the last round of reindexing for this database, and get the duration for each 
	table-index pair that matches between now and then. 

***********************************************************************************/

--------------------------------
-- Solution 1, simple case:
--------------------------------
DECLARE	@DBname SYSNAME = 'Minion';

SELECT	MLog.ExecutionDateTime ,
		MLog.DBName ,
		MLog.TableName ,
		MLog.IndexName ,
		MLog.OpBeginDateTime ,
		MLog.OpEndDateTime ,
		DATEDIFF(second, MLog.OpBeginDateTime, OpEndDateTime) AS DurationSec ,
		DATEDIFF(ms, MLog.OpBeginDateTime, OpEndDateTime) AS DurationMS ,
		SUM(DATEDIFF(ms, MLog.OpBeginDateTime, OpEndDateTime)) OVER ( ) AS SUMDurationMS
FROM	Minion.IndexMaintLogDetails AS MLog
		JOIN Minion.IndexTableFrag AS Frag ON Frag.DBName = MLog.DBName
											  AND Frag.SchemaName = MLog.SchemaName
											  AND Frag.TableName = MLog.TableName
											  AND Frag.IndexName = MLog.IndexName
WHERE	MLog.ExecutionDateTime = ( SELECT	MAX(executionDateTime)
								   FROM		Minion.IndexMaintLog
								   WHERE	DBName = @DBname
								 )
		AND MLog.DBName = @DBname;






