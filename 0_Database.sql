/****************************************************************************/
/*							 DBA Framework									*/
/*                                                                          */
/*						Written by Mark Boomaars							*/
/*					 http://www.bravisziekenhuis.nl							*/
/*                        m.boomaars@bravis.nl								*/
/*																			*/
/*							  2021-03-24									*/
/****************************************************************************/
/*                  Setup script for the creation of						*/
/*				    the DBA database and some tables                        */
/****************************************************************************/

DECLARE @SqlToExecute NVARCHAR(MAX);
DECLARE @InstanceDefaultDataPath SQL_VARIANT = SERVERPROPERTY ('InstanceDefaultDataPath');
DECLARE @InstanceDefaultLogPath SQL_VARIANT = SERVERPROPERTY ('InstanceDefaultLogPath');

IF NOT EXISTS (SELECT name FROM master.sys.databases WHERE name = N'DBA')
BEGIN
    SET @SqlToExecute = N'
    CREATE DATABASE [DBA] 
	ON PRIMARY
           (
               NAME = N''DBA'',
               FILENAME = N''' + CONVERT (NVARCHAR(255), @InstanceDefaultDataPath)
                        + N'DBA.mdf'',
               SIZE = 1048576KB,
               MAXSIZE = UNLIMITED,
               FILEGROWTH = 524288KB
           )
    LOG ON
        (
            NAME = N''DBA_log'',
            FILENAME = N''' + CONVERT (NVARCHAR(255), @InstanceDefaultLogPath)
                        + N'DBA_log.ldf'',
            SIZE = 262144KB,
            MAXSIZE = 2048GB,
            FILEGROWTH = 65536KB
        );';

    EXEC sp_executesql @SqlToExecute;
END;
GO

-------------------------------------------------------------------------------
-- Set recovery mode to SIMPLE
-------------------------------------------------------------------------------

ALTER DATABASE DBA SET RECOVERY SIMPLE;
GO

-------------------------------------------------------------------------------
-- Start using the new database
-------------------------------------------------------------------------------

USE DBA;
GO

EXEC sp_changedbowner 'sa';
GO

