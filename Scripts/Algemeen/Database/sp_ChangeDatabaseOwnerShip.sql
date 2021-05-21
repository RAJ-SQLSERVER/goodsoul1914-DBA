use [master];
go

/**************************************************************************************
Author: Adrian Buckman
Revision date: 05/04/2019

Description: Produce a script that will provide ALTER statements to change the database
ownership to the new owner and also ALTER statements to revert back to the old owner

ww.sqlundercover.com 
**************************************************************************************/

create procedure sp_ChangeDatabaseOwnerShip
(
	@DBOwner nvarchar(128) = null, 
	@Help    bit           = 0) 
as
begin

	if @Help = 1
	begin
		print 'Parameters: @DBOwner NVARCHAR(128) - Set the new owner name here';
	end;

	if @Help = 0
	begin
		declare @UserSid varbinary = SUSER_SID(@DBOwner);

		if @UserSid is not null
		begin

			select distinct 
				   sys.databases.name as Databasename, 
				   COALESCE(SUSER_SNAME(sys.databases.owner_sid), '') as CurrentOwner, 
				   'ALTER AUTHORIZATION ON DATABASE::[' + sys.databases.name + '] TO [' + @DBOwner + '];' as ChangeToNewOwner, 
				   'ALTER AUTHORIZATION ON DATABASE::[' + sys.databases.name + '] TO [' + COALESCE(SUSER_SNAME(sys.databases.owner_sid), '') + '];' as RevertToOriginalOwner
			from sys.databases
				 left join sys.availability_databases_cluster as ADC on sys.databases.name = ADC.database_name
				 left join sys.dm_hadr_availability_group_states as st on st.group_id = ADC.group_id
				 left join master.sys.availability_groups as ag on st.group_id = ag.group_id
			where primary_replica = @@Servername
				  and sys.databases.owner_sid != @UserSid
				  or sys.databases.owner_sid != @UserSid
				  and sys.databases.state = 0
				  and sys.databases.source_database_id is null
				  and sys.databases.replica_id is null;
		end;
		else
		begin
			raiserror('No SID found for the owner name you have provided - please check the owner name and try again', 11, 1);
		end;
	end;
end;