/*
 Well, our task is to easily capture SQL Server stored procedure calls for debugging. 
 We just need to track a specific procedure call and nothing more. 
 We will avoid collecting additional, unnecessary data and, therefore, we will choose 
 an option that best suits our needs and captures only our problem-related information.
*/

-------------------------------------------------------------------------------
-- Create a test emvironment
-------------------------------------------------------------------------------
USE master;
GO

CREATE DATABASE TestDB;
GO

USE TestDB;
GO

CREATE TABLE dbo.TestTable
(
    ID INT PRIMARY KEY,
    Val CHAR(1) NULL
);
GO

INSERT INTO dbo.TestTable
(
    ID,
    Val
)
VALUES
(1, 'A'),
(2, 'B'),
(3, 'C');
GO

CREATE PROCEDURE uspInsertData
    @pID INT,
    @pVal CHAR(1),
    @ResCode VARCHAR(10) OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.TestTable(ID, Val)
        VALUES(@pID, @pVal);

        COMMIT;

        SET @ResCode = 'OK';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        SET @ResCode = 'Error';
    END CATCH;
END;
GO


-------------------------------------------------------------------------------
-- Create the Extended Event
-------------------------------------------------------------------------------
CREATE EVENT SESSION [uspInsertData_Capture] ON SERVER 
ADD EVENT sqlserver.rpc_completed(SET collect_data_stream=(1)
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[like_i_sql_unicode_string]([sqlserver].[sql_text],N'%uspInsertData%')))),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[like_i_sql_unicode_string]([sqlserver].[sql_text],N'%uspInsertData%')))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.database_id,sqlserver.database_name,sqlserver.server_principal_name,sqlserver.session_id)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[like_i_sql_unicode_string]([sqlserver].[sql_text],N'%uspInsertData%'))))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


-------------------------------------------------------------------------------
-- Test it out
-------------------------------------------------------------------------------
DECLARE @ResCode varchar(10) 
  
EXEC dbo.uspInsertData 
  @pID = 5, 
  @pVal = N'E', 
  @ResCode = @ResCode OUTPUT 
  
SELECT @ResCode as "@ResCode" 
GO

