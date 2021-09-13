/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                         Enable Queue Activation                          */
/****************************************************************************/

USE DBA;
GO

ALTER QUEUE dbo.BlockedProcessNotificationQueue
WITH STATUS = ON,
     RETENTION = OFF,
     ACTIVATION (
         STATUS = ON,
         PROCEDURE_NAME = dbo.SB_BlockedProcessReport_Activation,
         MAX_QUEUE_READERS = 1,
         EXECUTE AS OWNER
     );
GO

ALTER QUEUE dbo.DeadlockNotificationQueue
WITH STATUS = ON,
     RETENTION = OFF,
     ACTIVATION (
         STATUS = ON,
         PROCEDURE_NAME = dbo.SB_DeadlockEvent_Activation,
         MAX_QUEUE_READERS = 1,
         EXECUTE AS OWNER
     );
GO