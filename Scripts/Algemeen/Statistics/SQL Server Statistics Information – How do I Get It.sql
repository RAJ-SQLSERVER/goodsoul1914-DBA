/*

Important Statistics Information

	- What statistics exist
	- Date they were last updated
	- Is there a filter?
	- Number of rows and the number of rows used for the sample
	- How many modifications since the last statistics update

These are all important in one way or another. Here is why each of these is important to look at.

What Statistics Exist � This is important to know because sometimes what statistics 
we think exist may not actually exist.  If the �Auto Create Statistics� database setting 
is turned off, then of course statistics would not be created other than manually or by 
creating an index.

Date They were last updates � This will help us understand if the statistics are being 
updated appropriately and as expected.

Is there a filter? � This will help us understand if the statistics are for the all the 
rows of the table or just a subset.

Number of Rows and the number of Rows used for the Sample � We need to review this to 
see if SQL Server is using an appropriate number of rows to update the statistics.

Number of Modifications since the last Statistics update � Understanding how frequently 
the column is modified will help us determine if the statistics update is happening appropriately.  
It is important to keep this in perspective. You can�t just look at this number, it is 
also important to look at the date last updated and the number of rows. 
If there are a high number of modifications but the statistics were last updated six 
months ago, there may not be an issue.  Although I might want to look to see why the 
statistics haven�t been updated for 6 months.

*/

USE AdventureWorks
GO

DBCC SHOW_STATISTICS('Person.Person', [IX_Person_LastName_FirstName_MiddleName]);
GO

DBCC SHOW_STATISTICS('Production.Product', [AK_Product_Name]) WITH STAT_HEADER
DBCC SHOW_STATISTICS('Production.Product', [AK_Product_ProductNumber]) WITH DENSITY_VECTOR
DBCC SHOW_STATISTICS('Person.Person', [IX_Person_LastName_FirstName_MiddleName]) WITH HISTOGRAM
GO

/*
	SYS.Stats

	Contains a row for each statistics object that exists for the tables, 
	indexes, and indexed views in the database.
*/

SELECT OBJECT_NAME(st.OBJECT_ID) AS "TableName",
       sp.stats_id,
       st.name AS "StatisticsName",
       ob.type,
       sc.column_id,
       co.name AS "ColumnName",
       st.filter_definition,
       sp.last_updated,
       sp.rows,
       sp.rows_sampled,
       CONVERT(DECIMAL(32, 2), sp.rows_sampled) / CONVERT(DECIMAL(32, 2), sp.rows) * 100 AS "SampleRate",
       sp.steps,
       sp.unfiltered_rows,
       sp.modification_counter,
       CONVERT(
                  DECIMAL(32, 2),
                  CASE
                      WHEN sp.modification_counter > 0 THEN
                          CONVERT(DECIMAL(32, 2), sp.modification_counter) / CONVERT(DECIMAL(32, 2), sp.rows)
                      ELSE
                          0
                  END
              ) * 100 AS "PercentModifications"
FROM sys.stats AS st
    INNER JOIN sys.stats_columns sc
        ON st.object_id = sc.object_id
           AND st.stats_id = sc.stats_id
    INNER JOIN sys.columns co
        ON sc.column_id = co.column_id
           AND sc.object_id = co.object_id
    INNER JOIN sysobjects ob
        ON sc.object_id = ob.id
    CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
WHERE ob.type = 'u'
-- AND CONVERT(DECIMAL(32,2),CASE WHEN sp.modification_counter > 0 
-- THEN CONVERT(DECIMAL(32,2),sp.modification_counter)/CONVERT(DECIMAL(32,2),sp.rows) 
-- ELSE 0 END) > .4
ORDER BY 1;
GO
