/****************************************************************************/
/*							 DBA Framework									*/
/*                                                                          */
/*						Written by Mark Boomaars							*/
/*					https://www.bravisziekenhuis.nl							*/
/*                        m.boomaars@bravis.nl								*/
/*																			*/
/*							  2021-03-24									*/
/****************************************************************************/
/*						   Create all tables								*/
/****************************************************************************/

IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = N'DBA_Config')
BEGIN
    CREATE TABLE dbo.DBA_Config ([Key] VARCHAR(64) NOT NULL, Value VARCHAR(256) NULL) ON [PRIMARY];

    INSERT dbo.DBA_Config ([Key], Value)
    VALUES (N'CleanupTimeSpanValue', N'365');

    INSERT dbo.DBA_Config ([Key], Value)
    VALUES (N'LastMonitoredDateTime', NULL);

    INSERT dbo.DBA_Config ([Key], Value)
    VALUES (N'LastMonitoredTimeSpanDefault', N'31');
END;


IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = N'DBA_ServerLogging')
BEGIN
    CREATE TABLE dbo.DBA_ServerLogging (
        SQLInstance sysname       NOT NULL,
        LogDate     DATETIME      NULL,
        ProcessInfo VARCHAR(100)  NULL,
        LogType     VARCHAR(50)   NOT NULL,
        LogText     VARCHAR(4000) NULL
    );
END;


IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = N'DBA_ServerLogging_Exclusions')
BEGIN
    CREATE TABLE dbo.DBA_ServerLogging_Exclusions (
        Text        VARCHAR(200) NOT NULL,
        SQLInstance sysname      NULL,
        StartHour   SMALLINT     NULL,
        EndHour     SMALLINT     NULL
    );

    TRUNCATE TABLE dbo.DBA_ServerLogging_Exclusions;

    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'RESTORE VERIFYONLY%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'BACKUP LOG %', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'DBCC CHECKDB (%) WITH NO_INFOMSGS, ALL_ERRORMSGS%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'DBCC TRACE% (3604)%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'BACKUP DATABASE %', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Login succeeded%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%DBID: % File Header for File Id: % was read with state%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Error: %, Severity: %, State:%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Database backed up. Database:%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%DBCC CHECKDB (%) WITH all_errormsgs, no_infomsgs executed by % found 0 errors and repaired 0 errors%',
            NULL,
            NULL,
            NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%DBCC TRACE%, server process ID (SPID) %. This is an informational message only; no user action is required%',
            NULL,
            NULL,
            NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%The operating system returned the error ''''21(The device is not ready.)'''' while attempting ''''GetDiskFreeSpace'''' on %',
            NULL,
            NULL,
            NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%informational message%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%found 0 errors and repaired 0 errors%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%The log shipping secondary database%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%UTC adjustment:%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%(c) Microsoft Corporation%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%All rights reserved%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Server process ID is %', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%System Manufacturer:%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Starting up database %', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Parallel redo is started for database%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%Parallel redo is shutdown for database%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%CLR%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'%SQLTELEMETRY%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'[INFO]%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'DBID: % No DEK update for File Id: % while existing DEK is null%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'Refresh DEK for DBID: % File Id: % - Copying encryption state%', NULL, NULL, NULL);
    INSERT dbo.DBA_ServerLogging_Exclusions (Text, SQLInstance, StartHour, EndHour)
    VALUES (N'The DEK is already set for DBID = % file id %', NULL, NULL, NULL);
END;

