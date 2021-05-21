SELECT audit_id,
	name,
	audit_guid,
	create_date,
	modify_date,
	principal_id,
	type,
	type_desc,
	on_failure,
	on_failure_desc,
	is_state_enabled,
	queue_delay,
	predicate
FROM sys.server_audits;

SELECT server_specification_id,
	name,
	create_date,
	modify_date,
	audit_guid,
	is_state_enabled
FROM sys.server_audit_specifications;

SELECT server_specification_id,
	audit_action_id,
	audit_action_name,
	class,
	class_desc,
	major_id,
	minor_id,
	audited_principal_id,
	audited_result,
	is_group
FROM sys.server_audit_specification_details;

SELECT database_specification_id,
	name,
	create_date,
	modify_date,
	audit_guid,
	is_state_enabled
FROM sys.database_audit_specifications;

SELECT database_specification_id,
	audit_action_id,
	audit_action_name,
	class,
	class_desc,
	major_id,
	minor_id,
	audited_principal_id,
	audited_result,
	is_group
FROM sys.database_audit_specification_details;

SELECT audit_id,
	name,
	audit_guid,
	create_date,
	modify_date,
	principal_id,
	type,
	type_desc,
	on_failure,
	on_failure_desc,
	is_state_enabled,
	queue_delay,
	predicate,
	max_file_size,
	max_rollover_files,
	max_files,
	reserve_disk_space,
	log_file_path,
	log_file_name
FROM sys.server_file_audits;

/*********************
 Read audit log files 
*********************/
SELECT event_time,
	action_id,
	statement,
	database_name,
	server_principal_name
FROM fn_get_audit_file('D:\SQLBackup\Audit-*.sqlaudit', DEFAULT, DEFAULT);
