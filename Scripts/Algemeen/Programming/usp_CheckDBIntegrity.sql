-- table structure for SQL Server 2012, 2014, 2016 and 2017
CREATE TABLE dbo.dbcc_history
(
    Error INT NULL,
    Level INT NULL,
    State INT NULL,
    MessageText VARCHAR(7000) NULL,
    RepairLevel INT NULL,
    Status INT NULL,
    DbId INT NULL,
    DbFragId INT NULL,
    ObjectId INT NULL,
    IndexId INT NULL,
    PartitionID INT NULL,
    AllocUnitID INT NULL,
    RidDbId INT NULL,
    RidPruId INT NULL,
    [File] INT NULL,
    Page INT NULL,
    Slot INT NULL,
    RefDbId INT NULL,
    RefPruId INT NULL,
    RefFile INT NULL,
    RefPage INT NULL,
    RefSlot INT NULL,
    Allocation INT NULL,
    TimeStamp DATETIME NULL
        CONSTRAINT DF_dbcc_history_TimeStamp
            DEFAULT (GETDATE())
) ON [PRIMARY];
GO


CREATE PROC dbo.usp_CheckDBIntegrity @database_name sysname = NULL
AS
IF @database_name IS NULL -- Run against all databases
BEGIN
    DECLARE database_cursor CURSOR FOR
    SELECT db.name
    FROM   sys.databases AS db
    WHERE  db.name NOT IN ( 'master', 'model', 'msdb', 'tempdb' )
           AND db.state_desc = 'ONLINE'
           AND db.source_database_id IS NULL -- REAL DBS ONLY (Not Snapshots)
           AND db.is_read_only = 0;

    OPEN database_cursor;
    FETCH NEXT FROM database_cursor
    INTO @database_name;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbcc_history (Error,
                                  Level,
                                  State,
                                  MessageText,
                                  RepairLevel,
                                  Status,
                                  DbId,
                                  DbFragId,
                                  ObjectId,
                                  IndexId,
                                  PartitionId,
                                  AllocUnitId,
                                  RidDbId,
                                  RidPruId,
                                  [File],
                                  Page,
                                  Slot,
                                  RefDbId,
                                  RefPruId,
                                  RefFile,
                                  RefPage,
                                  RefSlot,
                                  Allocation)
        EXEC ('dbcc checkdb(''' + @database_name + ''') with tableresults');

        FETCH NEXT FROM database_cursor
        INTO @database_name;
    END;

    CLOSE database_cursor;
    DEALLOCATE database_cursor;
END;
ELSE -- run against a specified database (ie: usp_CheckDBIntegrity 'DB Name Here'
    INSERT INTO dbcc_history (Error,
                              Level,
                              State,
                              MessageText,
                              RepairLevel,
                              Status,
                              DbId,
                              DbFragId,
                              ObjectId,
                              IndexId,
                              PartitionId,
                              AllocUnitId,
                              RidDbId,
                              RidPruId,
                              [File],
                              Page,
                              Slot,
                              RefDbId,
                              RefPruId,
                              RefFile,
                              RefPage,
                              RefSlot,
                              Allocation)
    EXEC ('dbcc checkdb(''' + @database_name + ''') with tableresults');
GO


--EXEC usp_CheckDBIntegrity;
EXEC usp_CheckDBIntegrity 'Credit';


SELECT Error,
       LEVEL,
       DB_NAME(dbid) AS DBName,
       OBJECT_NAME(objectid, dbid) AS ObjectName,
       Messagetext,
       TimeStamp
FROM   dbcc_history;