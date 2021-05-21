USE DBA;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE TRIGGER object_change_notification
ON DATABASE
FOR CREATE_TABLE, DROP_TABLE, ALTER_TABLE, CREATE_VIEW, DROP_VIEW, ALTER_VIEW, CREATE_PROCEDURE, DROP_PROCEDURE, ALTER_PROCEDURE
AS
DECLARE @Hostname VARCHAR(20) = HOST_NAME();
DECLARE @sys_usr CHAR(30);
SET @sys_usr = SYSTEM_USER;
DECLARE @executiontime DATETIME = GETDATE();
DECLARE @data XML = EVENTDATA();
DECLARE @eventType NVARCHAR(100)
    = CONCAT('EVENT: ', @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'), +CHAR(13));
DECLARE @TsqlCommand NVARCHAR(2000)
    = CONCAT('COMMAND:   ', @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(2000)'));
DECLARE @BodyMsg NVARCHAR(2100) = CONCAT(@eventType, @sys_usr, @Hostname, @executiontime, @TsqlCommand);

INSERT INTO DBA.dbo.AuditObject
SELECT @sys_usr,
       @Hostname,
       @executiontime,
       @data,
       @eventType,
       @TsqlCommand,
       @BodyMsg;
GO




USE DBA;
GO

CREATE PROCEDURE dbo.usp_AuditNotification
AS
DECLARE @Body VARCHAR(8000);
DECLARE @Qry VARCHAR(8000);

IF EXISTS (
    SELECT *
    FROM   DBA.dbo.AuditObject
    WHERE  CONVERT(DATE, executiontime) = CONVERT(DATE, GETDATE() - 1)
)
BEGIN
    DECLARE @tab CHAR(1) = CHAR(9);
    SET @Body = 'Hi All,';
    SET @Qry
        = 'set nocount on;
		select * from DBA.dbo.Audit_Object where convert(DATE,executiontime)=CONVERT(date,getdate()-1)';
    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'MAIL_Profile',
                                 @recipients = 'adil9025@gmail.com',
                                 --@blind_copy_recipients='mailid',
                                 @body = @Body,
                                 @query = @Qry,
                                 @subject = 'The following object(s) was/were changed',
                                 @attach_query_result_as_file = 1,
                                 @query_attachment_filename = 'AuditSheet.xls',
                                 @query_result_separator = @tab,
                                 @query_result_no_padding = 1;

END;