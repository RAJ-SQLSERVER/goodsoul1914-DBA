/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                       Setting Up Event Notifications                     */
/****************************************************************************/


-- Script does not enable activation on service broker queues. 
-- Set-up security and test framework first

USE DBA;
GO

IF EXISTS (
    SELECT *
    FROM sys.services
    WHERE name = 'BlockedProcessNotificationService'
)
    DROP SERVICE BlockedProcessNotificationService;

IF EXISTS (
    SELECT *
    FROM sys.service_queues AS q
    JOIN sys.schemas AS s
        ON q.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND q.name = 'BlockedProcessNotificationQueue'
)
    DROP QUEUE dbo.BlockedProcessNotificationQueue;

IF EXISTS (
    SELECT *
    FROM master.sys.server_event_notifications
    WHERE name = 'BlockedProcessNotificationEvent'
)
    DROP EVENT NOTIFICATION BlockedProcessNotificationEvent
    ON SERVER;

IF EXISTS (SELECT * FROM sys.services WHERE name = 'DeadlockNotificationService')
    DROP SERVICE DeadlockNotificationService;
IF EXISTS (
    SELECT *
    FROM sys.service_queues AS q
    JOIN sys.schemas AS s
        ON q.schema_id = s.schema_id
    WHERE s.name = 'dbo'
          AND q.name = 'DeadlockNotificationQueue'
)
    DROP QUEUE dbo.DeadlockNotificationQueue;

IF EXISTS (
    SELECT *
    FROM master.sys.server_event_notifications
    WHERE name = 'DeadlockNotificationEvent'
)
    DROP EVENT NOTIFICATION DeadlockNotificationEvent
    ON SERVER;
GO

CREATE QUEUE dbo.BlockedProcessNotificationQueue
WITH STATUS = ON;
GO

CREATE SERVICE BlockedProcessNotificationService
ON QUEUE dbo.BlockedProcessNotificationQueue
([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO

CREATE EVENT NOTIFICATION BlockedProcessNotificationEvent ON SERVER FOR BLOCKED_PROCESS_REPORT TO SERVICE 'BlockedProcessNotificationService', 'current database';
GO

CREATE QUEUE dbo.DeadlockNotificationQueue
WITH STATUS = ON;
GO

CREATE SERVICE DeadlockNotificationService
ON QUEUE dbo.DeadlockNotificationQueue
([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
GO

CREATE EVENT NOTIFICATION DeadlockNotificationEvent ON SERVER FOR DEADLOCK_GRAPH TO SERVICE 'DeadlockNotificationService', 'current database';
GO

/*
alter queue dbo.BlockedProcessNotificationQueue
with 
	status = ON,
	retention = OFF,
	activation
	(
		Status = ON,
		Procedure_Name = dbo.SB_BlockedProcessReport_Activation,
		MAX_QUEUE_READERS = 1, 
		EXECUTE AS OWNER
	);
go

alter queue dbo.DeadlockNotificationQueue
with 
	status = ON,
	retention = OFF,
	activation
	(
		Status = ON,
		Procedure_Name = dbo.SB_DeadlockEvent_Activation,
		max_queue_readers = 1, 
		execute as owner
	);
go
*/

