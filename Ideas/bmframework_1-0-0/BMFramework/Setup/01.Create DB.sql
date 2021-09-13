/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                          Creating the Database                           */
/****************************************************************************/
SET NOEXEC OFF;
GO

-- This script creates DBA database. You can use existing database. 
-- Make sure that Service Broker is enabled 
--
-- You should configure the database files and filegroups according to the best practices

IF EXISTS (
    SELECT *
    FROM sys.configurations
    WHERE name = N'blocked process threshold (s)'
          AND value = 0
)
BEGIN
    RAISERROR ('Blocked Process Threshold is not set', 16, 1) WITH NOWAIT;
    RAISERROR ('You can enable it with the following statement', 0, 1) WITH NOWAIT;
    RAISERROR (
        N'
sp_configure ''show advanced options'', 1;
go
reconfigure;
go
sp_configure ''blocked process threshold'', 10; -- time in seconds
go
reconfigure;
go',
        0,
        1
    ) WITH NOWAIT;
    SET NOEXEC ON;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DBA')
BEGIN
    RAISERROR ('Creating Database DBA', 0, 1) WITH NOWAIT;
    CREATE DATABASE DBA;
    --COLLATE Latin1_General_BIN2; -- testing purposes
    EXEC sp_executesql N'alter database DBA set enable_broker;
		alter database DBA set recovery simple;';
END;
GO
