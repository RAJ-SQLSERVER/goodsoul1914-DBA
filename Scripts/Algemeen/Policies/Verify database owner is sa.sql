declare @object_set_id int;
exec msdb.dbo.sp_syspolicy_add_object_set 
	@object_set_name = N'Verify database owner is sa_ObjectSet', 
	@facet = N'Database', 
	@object_set_id = @object_set_id output;
select @object_set_id;

declare @target_set_id int;
exec msdb.dbo.sp_syspolicy_add_target_set 
	@object_set_name = N'Verify database owner is sa_ObjectSet', 
	@type_skeleton = N'Server/Database', 
	@type = N'DATABASE', 
	@enabled = True, 
	@target_set_id = @target_set_id output;
select @target_set_id;

exec msdb.dbo.sp_syspolicy_add_target_set_level 
	@target_set_id = @target_set_id, 
	@type_skeleton = N'Server/Database', 
	@level_name = N'Database', 
	@condition_name = N'User database', 
	@target_set_level_id = 0;
go

declare @policy_id int;
exec msdb.dbo.sp_syspolicy_add_policy 
	@name = N'Verify database owner is sa', 
	@condition_name = N'Check database owner is sa', 
	@policy_category = N'', 
	@description = N'', 
	@help_text = N'', 
	@help_link = N'', 
	@schedule_uid = N'22fb5846-1b94-431a-96bc-c2bf077b0534', 
	@execution_mode = 4, 
	@is_enabled = True, 
	@policy_id = @policy_id output, 
	@root_condition_name = N'', 
	@object_set = N'Verify database owner is sa_ObjectSet';
select @policy_id;
go