/***********************************************************************************

Created By: Jen McCown
Creation Date: 10/3/2014


Purpose: This query lists all indexes that have not been maintained in the last 
	[@days] days.

Discussion: Pull index info for the database from sys.indexes (we will need
	to make this into a dynamic query, to account for different databases).

	Pull index maintenance history from Minion.IndexMaintLogDetails.

	Then, return everything from sys.indexes that doesn't exist in 
	IndexMaintLogDetails (where date > date - @days).

Variables:
-----------

    @days - How recently to look for index maintenance activity.
    

Tables:
--------

Revision History:
	* Solution 1
	The first pass solution for this task. 

	This is a sample query, not yet runnable on separate databases. Will need to 
	modify to use T-SQL, and place in a "for each database" cursor. 

***********************************************************************************/

DECLARE	@days SMALLINT = 3;

WITH	CTE
		  AS ( SELECT	tableID ,
						SchemaName ,
						IndexID 
						-- , Op
			   FROM		Minion.IndexMaintLogDetails
			   WHERE	OpBeginDateTime > GETDATE() - @days
			 )
	SELECT	s.NAME AS SchemaName ,
			o.NAME AS TableName ,
			o.object_id AS TableID ,
			i.NAME AS IndexName ,
			i.index_id
	FROM	sys.objects AS o
			JOIN sys.schemas AS s ON o.SCHEMA_ID = s.SCHEMA_ID
			JOIN sys.indexes AS i ON o.object_id = i.OBJECT_ID
			LEFT OUTER JOIN CTE ON CTE.tableID = o.OBJECT_ID
								   AND CTE.SchemaName = s.NAME
								   AND CTE.IndexID = i.index_id
	WHERE	CTE.tableID IS NULL
			AND o.is_ms_shipped = 0; -- Do we want to exclude MS shipped objects? 
