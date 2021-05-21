-- ============================================================
-- Create Event Notifications for Deadlock Graphs
-- ============================================================
-- Change databases to new database

use [Playground];
go

-- Create a table to old the deadlock graphs as collected

create table dbo.CapturedDeadlocks
(
	RowID         int identity primary key, 
	DeadlockGraph xml, 
	VictimPlan    xml, 
	ContribPlan   xml, 
	EntryDate     datetime default GETDATE());
go

--  Create the Activation Stored Procedure to Process the Queue

if exists
(
	select *
	from dbo.sysobjects
	where id = OBJECT_ID(N'[dbo].[sp_ProcessDeadlockGraphs]')
		  and OBJECTPROPERTY(id, N'IsProcedure') = 1
) 
	drop procedure dbo.sp_ProcessDeadlockGraphs;
go

set ansi_nulls on;
go

set quoted_identifier on;
go

create procedure dbo.sp_ProcessDeadlockGraphs
with execute as owner
as
begin

	declare @message_body xml;
	declare @message_sequence_number int;
	declare @dialog uniqueidentifier;
	declare @email_message nvarchar(max);

	while 1 = 1
	begin
		begin transaction;

		-- Receive the next available message FROM the queue

		waitfor(
		receive top (1) -- just handle one message at a time
		@message_body = CAST(message_body as xml), 
		@message_sequence_number = message_sequence_number from dbo.DeadlockGraphQueue), timeout 1000;  -- if the queue is empty for one second, give UPDATE AND GO away
		-- If we didn't get anything, bail out
		if @@ROWCOUNT = 0
		begin
			rollback transaction;
			break;
		end;

		-- validate that this is a DEADLOCK_GRAPH event
		if @message_body.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(128)') != 'DEADLOCK_GRAPH'
			return;

		declare @deadlock    xml, 
				@victim      varchar(50), 
				@victimplan  xml, 
				@contribplan xml;

		select @deadlock = @message_body.query('/EVENT_INSTANCE/TextData/*');

		select @victim = @deadlock.value('(deadlock-list/deadlock/@victim)[1]', 'varchar(50)');

		-- Get the victim plan
		select @victimplan = query_plan
		from sys.dm_exec_query_stats as qs
			 cross apply sys.dm_exec_query_plan(plan_handle)
		where sql_handle = @deadlock.value('xs:hexBinary(substring((
		deadlock-list/deadlock/process-list/process[@id=sql:variable("@victim")]/executionStack/frame/@sqlhandle)[1], 
		3))', 'varbinary(max)');

		-- Get the contributing query plan
		select @contribplan = query_plan
		from sys.dm_exec_query_stats as qs
			 cross apply sys.dm_exec_query_plan(plan_handle)
		where sql_handle = @deadlock.value('xs:hexBinary(substring((
		deadlock-list/deadlock/process-list/process[@id!=sql:variable("@victim")]/executionStack/frame/@sqlhandle)[1],
		 3))', 'varbinary(max)');

		insert into dbo.CapturedDeadlocks (DeadlockGraph, 
										   VictimPlan, 
										   ContribPlan) 
		values(
			@deadlock, @victimplan, @contribplan);

		select @email_message = CONVERT(nvarchar(max), @deadlock);
		exec msdb.dbo.sp_send_dbmail @profile_name = 'Gmail Notification Account', -- your defined email profile 
		@recipients = 'fakeaddress@gmail.com', -- your email
		@subject = 'Deadlock Notification', @body = @email_message;

		--  Commit the transaction.  At any point before this, we could roll 
		--  back - the received message would be back on the queue AND the response
		--  wouldn't be sent.
		commit transaction;
	end;
end;
go

-- Sign the procedure with the certificate's private key

add signature to OBJECT::sp_ProcessDeadlockGraphs by certificate [DBMailCertificate] with password = '$tr0ngp@$$w0rd';
go

--  Create a service broker queue to hold the events

create queue DeadlockGraphQueue with 
	status = on, 
	activation (procedure_name = sp_ProcessDeadlockGraphs, max_queue_readers = 1, execute as owner); 
go

--  Create a service broker service receive the events

create service [DeadlockGraphService] on queue DeadlockGraphQueue
([http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]);
go

create route [DeadlockGraphRoute]
with service_name = 'DeadlockGraphService',
	 address = 'LOCAL';
go

create event notification CaptureDeadlockGraphs on server with fan_in for deadlock_graph to service 'DeadlockGraphService', 'current database';
go

/******************************************************
--  Cleanup objects
DROP EVENT NOTIFICATION CaptureDeadlockGraphs ON SERVER
DROP ROUTE DeadlockGraphRoute
DROP SERVICE DeadlockGraphService
DROP QUEUE DeadlockGraphQueue 
******************************************************/