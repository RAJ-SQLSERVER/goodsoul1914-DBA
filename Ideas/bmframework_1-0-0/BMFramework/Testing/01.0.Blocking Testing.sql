/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                                 Testing                                  */
/*                    Testing Blocking Event Notification                   */
/****************************************************************************/


-- Testing approach:
-- 1. Test with queue activation disabled. 
--		Emulate blocking condition
--		See that event has been captured in SB queue
--		Call Activation Proc manually (in context of the caller) making sure that event has been processed
-- 2. Enable activation 
--		Emulate blocking condition
--		See that event has been processed and data is in the table


-- Initial Setup
USE tempdb;
GO

CREATE TABLE dbo.Data (
    ID    INT NOT NULL,
    Value INT NOT NULL,
    CONSTRAINT PK_Data
        PRIMARY KEY CLUSTERED (ID)
);
GO

INSERT INTO dbo.Data
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4);
GO

USE DBA;
GO

-- Test case 1 (activation disabled)
-- Should return multiple events
SELECT *
FROM dbo.BlockedProcessNotificationQueue;
GO

-- Should run without issues and populate data in the table
EXEC dbo.SB_BlockedProcessReport_Activation;
SELECT *
FROM dbo.BlockedProcessesInfo;
GO

-- Enabling Activation
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

-- Test 2: Repeat blocking condition and see that data is populated and WaitTime updated
SELECT *
FROM dbo.BlockedProcessesInfo;
GO
