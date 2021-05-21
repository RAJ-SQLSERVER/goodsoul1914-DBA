/**************************************************************************************
	Author		:	Brahmanand Shukla
	Date		:	28-Oct-2019
	Purpose		:	T-SQL script to purge all the tables including foreign key references

	-- Change History
	Date		:	10-Dec-2019
	Reason		:	Implemented the feedback from Mike Vessey - Reset the identity after DELETE.
					Fixed the bug - There was a bug in choosing between TRUNCATE and DELETE.
**************************************************************************************/
WITH cte_All_Tables_With_Foreign_Key
	-- Get all the tables having foreign key. Ignore the self-referencing.
AS (
	SELECT PAR_SCH.name AS Parent_Schema_Name,
		PAR_TAB.name AS Parent_Table_Name,
		REF_SCH.name AS Referenced_Schema_Name,
		REF_TAB.name AS Referenced_Table_Name,
		FK.parent_object_id AS parent_object_id,
		FK.referenced_object_id AS referenced_object_id
	FROM sys.foreign_keys AS FK
	INNER JOIN sys.tables AS PAR_TAB ON PAR_TAB.object_id = FK.parent_object_id
	INNER JOIN sys.schemas AS PAR_SCH ON PAR_SCH.schema_id = PAR_TAB.schema_id
	INNER JOIN sys.tables AS REF_TAB ON REF_TAB.object_id = FK.referenced_object_id
	INNER JOIN sys.schemas AS REF_SCH ON REF_SCH.schema_id = REF_TAB.schema_id
	WHERE FK.type = 'F'
		AND FK.parent_object_id <> referenced_object_id
		AND PAR_TAB.type = 'U'
		AND REF_TAB.type = 'U'
	),
cte_Find_All_Referenced_Tables_In_Sequence
	/******************************************************************************
	Recursive CTE :
	 
	Find the sequence of each referenced table. 
	For e.g Table1 is referenced with Table2 and Table2 is referenced with Table3 
	then Table3 should be assigned Sequence as 1, 
	Table2 should be assigned Sequence as 2 
	and Table1 should be assigned Sequence as 3
******************************************************************************/
AS (
	SELECT FK1.Parent_Schema_Name,
		FK1.Parent_Table_Name,
		FK1.Referenced_Schema_Name,
		FK1.Referenced_Table_Name,
		FK1.parent_object_id,
		FK1.referenced_object_id,
		1 AS Iteration_Sequence_No
	FROM cte_All_Tables_With_Foreign_Key AS FK1
	LEFT JOIN cte_All_Tables_With_Foreign_Key AS FK2 ON FK1.parent_object_id = FK2.referenced_object_id
	WHERE FK2.parent_object_id IS NULL
	
	UNION ALL
	
	SELECT FK.Parent_Schema_Name,
		FK.Parent_Table_Name,
		FK.Referenced_Schema_Name,
		FK.Referenced_Table_Name,
		FK.parent_object_id,
		FK.referenced_object_id,
		CTE.Iteration_Sequence_No + 1 AS Iteration_Sequence_No
	FROM cte_All_Tables_With_Foreign_Key AS FK
	INNER JOIN cte_Find_All_Referenced_Tables_In_Sequence AS CTE ON FK.parent_object_id = CTE.referenced_object_id
	WHERE FK.referenced_object_id <> CTE.parent_object_id
	)
	/***************************************************************
	Get the distinct parent tables with their Iteration Sequence No
***************************************************************/
	,
cte_Unique_Parent_Tables_With_References
AS (
	SELECT DISTINCT Parent_Schema_Name,
		Parent_Table_Name,
		parent_object_id,
		Iteration_Sequence_No
	FROM cte_Find_All_Referenced_Tables_In_Sequence
	),
cte_All_Tables
	/***********************************************************************************
	Merge all tables (such as Tables with Foreign Key and Tables without Foreign Key). 
***********************************************************************************/
AS (
	SELECT SCH.name AS TABLE_SCHEMA,
		TAB.name AS TABLE_NAME,
		ISNULL(STGB.Iteration_Sequence_No, ISNULL(MITRN.Max_Iteration_Sequence_No, 0) + 1) AS ITERATION_SEQUENCE_NO,
		CASE 
			WHEN EXISTS (
					SELECT 1
					FROM cte_All_Tables_With_Foreign_Key
					WHERE referenced_object_id = TAB.object_id
					)
				THEN 1
			ELSE 0
			END AS TABLE_HAS_REFERENCE
	FROM sys.tables AS TAB
	INNER JOIN sys.schemas AS SCH ON SCH.schema_id = TAB.schema_id
	LEFT JOIN cte_Unique_Parent_Tables_With_References AS STGB ON STGB.parent_object_id = TAB.object_id
	OUTER APPLY (
		SELECT MAX(Iteration_Sequence_No) AS Max_Iteration_Sequence_No
		FROM cte_Unique_Parent_Tables_With_References
		) AS MITRN
	WHERE TAB.type = 'U'
		AND TAB.name NOT LIKE 'sys%'
	)
/******************************************************************************************
	Output : 
	Table Schema, Table Name and T-SQL script to purge the table data.
	TRUNCATE is being used whereever there is no foreign key reference or else DELETE is used.
******************************************************************************************/
SELECT TBL_SEQ.TABLE_SCHEMA AS TABLE_SCHEMA,
	TBL_SEQ.TABLE_NAME AS TABLE_NAME,
	TBL_SEQ.Iteration_Sequence_No,
	CASE 
		WHEN ROW_NUMBER() OVER (
				ORDER BY TBL_SEQ.Iteration_Sequence_No ASC
				) = 1
			THEN 'SET NOCOUNT ON;'
		ELSE ''
		END + CHAR(13) + CHAR(10) + CASE 
		WHEN TBL_SEQ.TABLE_HAS_REFERENCE = 0
			THEN 'TRUNCATE TABLE ' + QUOTENAME(TBL_SEQ.TABLE_SCHEMA) + '.' + QUOTENAME(TBL_SEQ.TABLE_NAME) + ';'
		ELSE 'DELETE FROM ' + QUOTENAME(TBL_SEQ.TABLE_SCHEMA) + '.' + QUOTENAME(TBL_SEQ.TABLE_NAME) + ';' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10) + 'DBCC CHECKIDENT (''' + QUOTENAME(TBL_SEQ.TABLE_SCHEMA) + '.' + QUOTENAME(TBL_SEQ.TABLE_NAME) + ''', RESEED, 1);'
		END + CHAR(13) + CHAR(10) + 'GO' AS TSQL_SCRIPT
FROM cte_All_Tables AS TBL_SEQ
ORDER BY TBL_SEQ.Iteration_Sequence_No ASC,
	TBL_SEQ.TABLE_SCHEMA ASC,
	TBL_SEQ.TABLE_NAME ASC
OPTION (MAXRECURSION 0);
