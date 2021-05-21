/*

!!!! Read all comments before proceeding !!!!

Purpose: 
	This code finds all tables that have indexes with ALLOW_PAGE_LOCKS turned off and inserts those tables into 
	Minion.SettingsTable with the correct pre and post code to turn ALLOW_PAGE_LOCKS on and then back off again 
	once the table is done.

Requirements: 
	You need to run this code from the DB in question.  
	**The insert stmt is fully qualified so you have to change the DBName in the insert stmt.
	Remove or comment out the line "DROP TABLE #TablesWithPageLocks". It's there as a failsafe.
	***Also, don't forget to change the other tables parameters to what you need.  These are changed in the insert statement.

IMPORTANT:
	Remember, once you insert a row into the SettingsTable table all that table's settings come from that row.  
	This completely overrides the database-level settings.

Of course, you can run this without the insert stmt if you just want to investigate if any indexes have this condition.
You could fairly easily wrap this in a powershell to run it against multiple boxes and multiple databases.

Change Log
	Minion Reindex 1.3 - Now excludes Clustered ColumnStore indexes from the query.
*/


With PrePostCodeAll(object_id, stmt_before, stmt_after) as
(
      Select  
            t.object_id,
            'ALTER index ' + QUOTENAME(i.name) + ' ON ' + SCHEMA_NAME(t.schema_id) + '.' + QUOTENAME(t.name) + ' SET (ALLOW_PAGE_LOCKS = ON)' as stmt_before,
            'ALTER index ' + QUOTENAME(i.name) + ' ON ' + SCHEMA_NAME(t.schema_id) + '.' + QUOTENAME(t.name) + ' SET (ALLOW_PAGE_LOCKS = OFF)' as stmt_after 
      from sys.tables t
      INNER JOIN sys.indexes i
            ON i.object_id = t.object_id
      WHERE allow_page_locks = 0
		AND i.[type] NOT IN (5,6)
),PrePostCode(object_id, PreCode, PostCode) as 
(
      SELECT      DISTINCT object_id ,
            PreCode = 'USE ' + QuoteName(DB_NAME()) + ';' +
                        (SELECT stmt_before + ';'
                        FROM  PrePostCodeAll AS B2
                        WHERE B2.object_id = B1.object_id   
                        ORDER BY stmt_before
                        FOR XML     PATH('')
                        ),
            PostCode = 'USE ' + QuoteName(DB_NAME()) + ';' +
                        ( SELECT    stmt_after + ';'
                        FROM PrePostCodeAll AS B2
                        WHERE B2.object_id = B1.object_id   
                        ORDER BY stmt_before
                        FOR XML     PATH('')
                        )                       
      FROM PrePostCodeAll AS B1
)  
Select
      DB_NAME() as DBName ,  
      SCHEMA_NAME(t.schema_id) as SchemaName , 
      t.name as TableName, 
      p.object_id, 
      p.PreCode, 
      p.PostCode
INTO #TablesWithPageLocks
FROM PrePostCode p
INNER JOIN sys.tables t
      ON t.object_id = p.object_id;

SELECT * FROM #TablesWithPageLocks
DROP TABLE #TablesWithPageLocks      
      
--------------------------------------------
--!-- Change the DBName as appropriate --!--
-------------------------------------------- 
INSERT DBName.Minion.IndexSettingsTable (DBName, SchemaName, TableName, Exclude, ReindexGroupOrder, ReindexOrder, ReorgThreshold, RebuildThreshold, AllowPageLocks, TablePreCode, TablePostCode)
SELECT 
      DBName,
      SchemaName,
      TableName,
      0, --Exclude
      0, --ReindexGroupOrder
      0, --ReindexOrder
      10, --ReorgThreshold,
      20, --RebuildThreshold
      'ON',
      PreCode,
      PostCode
FROM #TablesWithPageLocks;

