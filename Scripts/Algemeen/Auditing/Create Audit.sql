USE [master];
GO

/*************
 Create audit 
*************/
CREATE SERVER AUDIT [Bravis Audit G-100-A] TO FILE (
	FILEPATH = N'D:\SQLBackup',
	MAXSIZE = 50 MB,
	MAX_ROLLOVER_FILES = 2,
	RESERVE_DISK_SPACE = OFF
	)
	WITH (
			QUEUE_DELAY = 1000,
			ON_FAILURE = CONTINUE
			);
GO

/**********************************
 Create server audit specification 
**********************************/
CREATE SERVER AUDIT SPECIFICATION [Bravis failed login]
FOR SERVER AUDIT [Bravis Audit G-100-A] ADD (failed_login_group);
GO

/***********************
 Look at the audit file 
***********************/
SELECT statement
FROM fn_get_audit_file('D:\SQLBackup\Bravis%5Audit%5G-100-A_1924DC75-0B33-44F0-B4C1-C85C1628E7B0_0_132366290932210000.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id = 'LGIF';
GO


