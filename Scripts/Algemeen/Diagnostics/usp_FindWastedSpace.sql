IF OBJECTPROPERTY(OBJECT_ID('dbo.usp_FindWastedSpace'), N'IsProcedure') IS NULL
BEGIN
    EXECUTE ('Create Procedure dbo.usp_FindWastedSpace As Print ''Hello World!''');
    RAISERROR('Procedure usp_FindWastedSpace created.', 10, 1);
END;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.usp_FindWastedSpace
    @databaseName sysname = 'AdventureWorks',
    @tableName sysname = 'Sales.SalesOrderDetail',
    @percentGrowth TINYINT = 10, /* allow for up to 10% growth by default */
    @displayUnit CHAR(2) = 'GB', /* KB, MB, GB, or TB */
    @debug BIT = 1
AS
BEGIN

    /*********************************************************************************************************
    NAME:           usp_FindWastedSpace

    SYNOPSIS:       Finds wasted space on a database and/or table

    DEPENDENCIES:   The following dependencies are required to execute this script:
                    - SQL Server 2005 or newer

    AUTHOR:         Michelle Ufford, http://sqlfool.com
    
    CREATED:        2011-03-14
    
    VERSION:        1.0

    LICENSE:        Apache License v2

    ----------------------------------------------------------------------------
    DISCLAIMER: 
    This code and information are provided "AS IS" without warranty of any kind,
    either expressed or implied, including but not limited to the implied 
    warranties or merchantability and/or fitness for a particular purpose.
    ----------------------------------------------------------------------------

 ---------------------------------------------------------------------------------------------------------
 --  DATE       VERSION     AUTHOR                  DESCRIPTION                                        --
 ---------------------------------------------------------------------------------------------------------
     20150619   1.0         Michelle Ufford         Open Sourced on GitHub
*********************************************************************************************************/

    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET ANSI_PADDING ON;
    SET ANSI_WARNINGS ON;
    SET ARITHABORT ON;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET NUMERIC_ROUNDABORT OFF;

    BEGIN

        /***************************************************
         Make sure our environment is clean and ready to go 
        ***************************************************/

        IF EXISTS (SELECT object_id FROM tempdb.sys.tables WHERE name = '##values')
            DROP TABLE ##values;

        IF EXISTS
        (
            SELECT object_id
            FROM   tempdb.sys.tables
            WHERE  name = '##definition'
        )
            DROP TABLE ##definition;

        IF EXISTS
        (
            SELECT object_id
            FROM   tempdb.sys.tables
            WHERE  name = '##spaceRequired'
        )
            DROP TABLE ##spaceRequired;

        IF EXISTS
        (
            SELECT object_id
            FROM   tempdb.sys.tables
            WHERE  name = '##results'
        )
            DROP TABLE ##results;

        DECLARE @sqlStatement_getColumnList    NVARCHAR(MAX),
                @sqlStatement_values           NVARCHAR(MAX),
                @sqlStatement_columns          NVARCHAR(MAX),
                @sqlStatement_tableDefinition1 NVARCHAR(MAX),
                @sqlStatement_tableDefinition2 NVARCHAR(MAX),
                @sqlStatement_tableDefinition3 NVARCHAR(MAX),
                @sqlStatement_spaceRequired    NVARCHAR(MAX),
                @sqlStatement_results          NVARCHAR(MAX),
                @sqlStatement_displayResults   NVARCHAR(MAX),
                @sqlStatement_total            NVARCHAR(MAX),
                @currentRecord                 INT,
                @growthPercentage              FLOAT;

        DECLARE @columnList TABLE
        (
            id INT IDENTITY(1, 1),
            table_id INT,
            columnName VARCHAR(128),
            user_type_id TINYINT,
            max_length SMALLINT,
            columnStatus TINYINT
        );

        /*******************************************************************
         Initialize variables
         I'm doing it this way to support 2005 environments, too 
        *******************************************************************/

        SELECT @sqlStatement_tableDefinition1 = N'',
               @sqlStatement_tableDefinition2 = N'',
               @sqlStatement_tableDefinition3 = N'',
               @sqlStatement_spaceRequired = N'Select ',
               @sqlStatement_results = N'Select ',
               @sqlStatement_displayResults = N'',
               @sqlStatement_total = N'Select ''Total'', Null, ',
               @sqlStatement_values = N'Select ',
               @sqlStatement_columns = N'Select ',
               @growthPercentage = 1 + @percentGrowth / 100.0;

        SET @sqlStatement_getColumnList
            = N'
            Select c.object_id As [table_id]
                , c.name
                , t.user_type_id
                , c.max_length
                , 0 /* not yet columnStatus */
            From ' + @databaseName + N'.sys.columns As c
            Join ' + @databaseName
                      + N'.sys.types As t 
                On c.user_type_id = t.user_type_id
            Where c.object_id = IsNull(Object_Id(''' + @databaseName + N'.' + @tableName
                      + N'''), c.object_id)
                And t.user_type_id In (48, 52, 56, 127, 167, 175, 231, 239);';

        IF @debug = 1
        BEGIN
            SELECT @sqlStatement_getColumnList;
        END;

        INSERT INTO @columnList
        EXECUTE sp_executesql @sqlStatement_getColumnList;

        IF @debug = 1
        BEGIN
            SELECT *
            FROM   @columnList;
        END;

        /********************************************************************
         Begin our loop.  We're going to run through this for every column.  
        ********************************************************************/

        WHILE EXISTS (SELECT * FROM @columnList WHERE columnStatus = 0)
        BEGIN

            /*********************************************
             Grab a column that hasn't been processed yet 
            *********************************************/

            SELECT   TOP (1)
                     @currentRecord = id
            FROM     @columnList
            WHERE    columnStatus = 0
            ORDER BY id;

            /******************************************************************************
             First, let's build the statement we're going to use to get our min/max values 
            ******************************************************************************/

            SELECT @sqlStatement_values
                = @sqlStatement_values
                  + CASE
                        WHEN user_type_id IN ( 48, 52, 56, 127 ) THEN
                            'Max(' + columnName + ') As [' + columnName + '], ' + 'Min(' + columnName + ') As [min'
                            + columnName + '], '
                        ELSE
                            'Max(Len(' + columnName + ')) As [' + columnName + '], ' + 'Avg(Len(' + columnName
                            + ')) As [avg' + columnName + '], '
                    END
            FROM   @columnList
            WHERE  id = @currentRecord;

            /*********************************************************************************************************
             Next, let's build the statement that's going to show us how much space the column is currently consuming 
            *********************************************************************************************************/

            SELECT @sqlStatement_columns
                = @sqlStatement_columns + CASE
                                              WHEN user_type_id = 48 THEN
                                                  '1'                                 -- tinyint
                                              WHEN user_type_id = 52 THEN
                                                  '2'                                 -- smallint
                                              WHEN user_type_id = 56 THEN
                                                  '4'                                 -- int
                                              WHEN user_type_id = 127 THEN
                                                  '8'                                 -- bigint
                                              WHEN user_type_id IN ( 167, 175 ) THEN
                                                  CAST(max_length AS VARCHAR(10))     -- varchar or char
                                              ELSE
                                                  CAST(max_length * 2 AS VARCHAR(10)) -- nvarchar or nchar
                                          --Else '0'
                                          END + N' As [' + columnName + N'], '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /*************************************************
             This section is used to build a table definition 
            *************************************************/

            SELECT @sqlStatement_tableDefinition1
                = @sqlStatement_tableDefinition1 + N'[' + columnName + N'] ' + CASE
                                                                                   WHEN user_type_id = 48 THEN
                                                                                       'tinyint'
                                                                                   WHEN user_type_id = 52 THEN
                                                                                       'smallint'
                                                                                   WHEN user_type_id = 56 THEN
                                                                                       'int'
                                                                                   WHEN user_type_id = 127 THEN
                                                                                       'bigint'
                                                                                   ELSE
                                                                                       'smallint'
                                                                               END + N', '
                  + CASE
                        WHEN user_type_id IN ( 48, 52, 56, 127 ) THEN
                            '[min'
                        ELSE
                            '[avg'
                    END + columnName + N'] ' + CASE
                                                   WHEN user_type_id = 48 THEN
                                                       'tinyint'
                                                   WHEN user_type_id = 52 THEN
                                                       'smallint'
                                                   WHEN user_type_id = 56 THEN
                                                       'int'
                                                   WHEN user_type_id = 127 THEN
                                                       'bigint'
                                                   ELSE
                                                       'smallint'
                                               END + N', '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /***********************************
             More dynamic table definition code 
            ***********************************/

            SELECT @sqlStatement_tableDefinition2
                = @sqlStatement_tableDefinition2 + N'[' + columnName + N'] ' + CASE
                                                                                   WHEN user_type_id = 48 THEN
                                                                                       'tinyint'
                                                                                   WHEN user_type_id = 52 THEN
                                                                                       'smallint'
                                                                                   WHEN user_type_id = 56 THEN
                                                                                       'int'
                                                                                   WHEN user_type_id = 127 THEN
                                                                                       'bigint'
                                                                                   ELSE
                                                                                       'smallint'
                                                                               END + N', '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /*******************************************
             And yet more dynamic table definition code 
            *******************************************/

            SELECT @sqlStatement_tableDefinition3
                = @sqlStatement_tableDefinition3 + columnName + N' smallint, ' + columnName + N'_bytes bigint, '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /**********************************************************************************************************
             This is where we see how much space we actually need, based on our min/max values.
             This is where we consider the % of growth that we expect to see in a reasonable period of time. 
            **********************************************************************************************************/

            SELECT @sqlStatement_spaceRequired
                = @sqlStatement_spaceRequired
                  + CASE
                        WHEN user_type_id IN ( 48, 52, 56, 127 ) THEN
                            'Case When ([' + columnName + '] * ' + CAST(@growthPercentage AS VARCHAR(5))
                            + ') <= 255 
                                And [min'                                              + columnName
                            + '] >= 0 
                                    Then 1
                           When (['                                                    + columnName + '] * '
                            + CAST(@growthPercentage AS VARCHAR(5))
                            + ') <= 32768 
                                And [min'                                              + columnName
                            + '] >= -32768 
                                    Then 2
                           When (['                                                    + columnName + '] * '
                            + CAST(@growthPercentage AS VARCHAR(5))
                            + ') <= 2147483647 
                                And [min'                                              + columnName
                            + '] >= -2147483647 
                                    Then 4
                           Else 8 End '
                        ELSE
                            columnName
                    END + N' As [' + columnName + N'], '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /**************************************************************************************
             This is where the analysis occurs to tell us how much space we're potentially wasting 
            **************************************************************************************/

            SELECT @sqlStatement_results
                = @sqlStatement_results + N'd.[' + columnName + N'] - sr.[' + columnName + N'] As [' + columnName
                  + N'], ' + N'(d.[' + columnName + N'] - sr.[' + columnName + N']) * rowCnt As [bytes], '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /***************************************************
             This is where we get our pretty results table from 
            ***************************************************/

            SELECT @sqlStatement_displayResults
                = @sqlStatement_displayResults + N'Select ''' + columnName + N''' As [columnName] ' + N', '
                  + columnName + N' As [byteReduction] '
                  -- + ', ' + columnName + '_bytes As [estimatedSpaceSavings] '
                  + N', ' + columnName + N'_bytes / 1024.0 / 1024.0 As [estimatedSpaceSavings] ' + N' From ##results'
                  + N' Union All '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /************************************************
             And lastly, this is where we get our total from 
            ************************************************/

            SELECT @sqlStatement_total = @sqlStatement_total + N'([' + columnName + N'_bytes] / 1024.0 / 1024.0) + '
            FROM   @columnList
            WHERE  id = @currentRecord;

            /***************************************************************
             Mark the column as processed so we can move on to the next one 
            ***************************************************************/

            UPDATE @columnList
            SET    columnStatus = 1
            WHERE  id = @currentRecord;
        END;

        SELECT @sqlStatement_values
            = @sqlStatement_values + N' Count(*) As [rowCnt], 1 As [id] From ' + @databaseName + N'.' + @tableName
              + N' Option (MaxDop 1);',
               @sqlStatement_columns
                   = @sqlStatement_columns + N' ' + CAST(@currentRecord AS VARCHAR(4)) + N' As [columnCnt], 1 As [id];';

        SET @sqlStatement_tableDefinition1
            = N'Create Table ##values(' + @sqlStatement_tableDefinition1 + N' rowCnt bigint, id tinyint)';

        SET @sqlStatement_tableDefinition2
            = N'Create Table ##definition(' + @sqlStatement_tableDefinition2 + N' columnCnt bigint, id tinyint)';

        SET @sqlStatement_tableDefinition3
            = N'Create Table ##results(' + @sqlStatement_tableDefinition3 + N' id tinyint)';

        SET @sqlStatement_spaceRequired
            = @sqlStatement_spaceRequired + N'1 As [id] Into ##spaceRequired From ##values;';

        SET @sqlStatement_results
            = @sqlStatement_results
              + N'1 As [id] From ##definition As d Join ##spaceRequired As sr On d.id = sr.id Join ##values As v On d.id = v.id;';

        SET @sqlStatement_displayResults = @sqlStatement_displayResults + @sqlStatement_total + N'0 From ##results';

        /*****************************************************************
         Print our dynamic SQL statements in case we need to troubleshoot 
        *****************************************************************/

        IF @debug = 1
        BEGIN
            SELECT @sqlStatement_values AS "@sqlStatement_values",
                   @sqlStatement_columns AS "@sqlStatement_columns",
                   @sqlStatement_tableDefinition1 AS "@sqlStatement_tableDefinition1",
                   @sqlStatement_tableDefinition2 AS "@sqlStatement_tableDefinition2",
                   @sqlStatement_spaceRequired AS "@sqlStatement_spaceRequired",
                   @sqlStatement_results AS "@sqlStatement_results",
                   @sqlStatement_displayResults AS "@sqlStatement_displayResults",
                   @sqlStatement_total AS "@sqlStatement_total";
        END;

        SELECT @sqlStatement_tableDefinition1 AS "Table Definition 1";
        EXECUTE sp_executesql @sqlStatement_tableDefinition1;

        SELECT @sqlStatement_tableDefinition2 AS "Table Definition 2";
        EXECUTE sp_executesql @sqlStatement_tableDefinition2;

        SELECT @sqlStatement_tableDefinition3 AS "Table Definition 3";
        EXECUTE sp_executesql @sqlStatement_tableDefinition3;

        SELECT @sqlStatement_values AS "Insert 1";
        INSERT INTO ##values
        EXECUTE sp_executesql @sqlStatement_values;

        SELECT @sqlStatement_columns AS "Insert 2";
        INSERT INTO ##definition
        EXECUTE sp_executesql @sqlStatement_columns;

        SELECT @sqlStatement_spaceRequired AS "Execute space required";
        EXECUTE sp_executesql @sqlStatement_spaceRequired;

        SELECT @sqlStatement_results AS "Execute results";
        INSERT INTO ##results
        EXECUTE sp_executesql @sqlStatement_results;

        /*****************************************************
         Output our table values for troubleshooting purposes 
        *****************************************************/

        IF @debug = 1
        BEGIN
            SELECT 'definition' AS "tableType",
                   *
            FROM   ##definition AS y;
            SELECT 'values' AS "tableType",
                   *
            FROM   ##values AS x;
            SELECT 'spaceRequired' AS "tableType",
                   *
            FROM   ##spaceRequired;
            SELECT 'results' AS "tableType",
                   *
            FROM   ##results;
        END;

        SELECT @sqlStatement_displayResults AS "Final results";
        EXECUTE sp_executesql @sqlStatement_displayResults;

        /******************
         Clean up our mess 
        ******************/

        --Drop Table ##values;
        --Drop Table ##definition;
        --Drop Table ##spaceRequired;
        --Drop Table ##results;

        SET NOCOUNT OFF;
        RETURN 0;
    END;
END;
GO

SET QUOTED_IDENTIFIER OFF;
GO