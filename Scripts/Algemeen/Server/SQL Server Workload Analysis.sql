select 
	a.name, 
	connections = (select 
					   COUNT(*)
				   from master..sysprocesses as b
				   where a.dbid = b.dbid), 
	blocked_users = (select 
						 COUNT(*)
					 from master..sysprocesses as b
					 where a.dbid = b.dbid
						   and blocked <> 0), 
	total_memory = ISNULL( (select 
								SUM(memusage)
							from master..sysprocesses as b
							where a.dbid = b.dbid), 0), 
	total_io = ISNULL( (select 
							SUM(physical_io)
						from master..sysprocesses as b
						where a.dbid = b.dbid), 0), 
	total_cpu = ISNULL( (select 
							 SUM(cpu)
						 from master..sysprocesses as b
						 where a.dbid = b.dbid), 0), 
	total_waittime = ISNULL( (select 
								  SUM(waittime)
							  from master..sysprocesses as b
							  where a.dbid = b.dbid), 0), 
	dbccs = ISNULL( (select 
						 COUNT(*)
					 from master..sysprocesses as b
					 where a.dbid = b.dbid
						   and UPPER(b.cmd) like '%DBCC%'), 0), 
	bcp_running = ISNULL( (select 
							   COUNT(*)
						   from master..sysprocesses as b
						   where a.dbid = b.dbid
								 and UPPER(b.cmd) like '%BCP%'), 0), 
	backup_restore_running = ISNULL( (select 
										  COUNT(*)
									  from master..sysprocesses as b
									  where a.dbid = b.dbid
											and UPPER(b.cmd) like '%BACKUP%'
											or UPPER(b.cmd) like '%RESTORE%'), 0)
from master.dbo.sysdatabases as a;