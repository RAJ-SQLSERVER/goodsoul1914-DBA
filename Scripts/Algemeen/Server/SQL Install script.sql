-- Sets the default locations of the Enable the Database Mail feature on the server

USE master;
GO

EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                          N'Software\Microsoft\MSSQLServer\MSSQLServer',
                          N'DefaultData',
                          REG_SZ,
                          N'D:\SQLData';
GO

EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                          N'Software\Microsoft\MSSQLServer\MSSQLServer',
                          N'DefaultLog',
                          REG_SZ,
                          N'D:\SQLLogs';
GO

-- Enable Agent XPs zodat SQL Server Agent weer werkt.

USE master;
GO

sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

sp_configure 'Agent XPs', 1;
GO

RECONFIGURE;
GO

-- Enable AWE en configureer max geheugen gebruik SQL (hier 3 GB)

EXEC sys.sp_configure N'max server memory (MB)', N'12000';
GO

EXEC sys.sp_configure N'awe enabled', N'1';
GO

RECONFIGURE WITH OVERRIDE;
GO

-- Max Degree of parallelism op 1 zetten indien er meerdere CPU's aanwezig zijn

EXEC sys.sp_configure N'max degree of parallelism', N'6';
GO

RECONFIGURE WITH OVERRIDE;
GO

-- Enable the Database Mail feature on the server

USE master;
GO

sp_configure 'show advanced options', 1;
GO

RECONFIGURE WITH OVERRIDE;
GO

sp_configure 'Database Mail XPs', 1;
GO

RECONFIGURE;
GO

-- Enable the Command Shell feature on the server

sp_configure 'xp_cmdshell', 1;
GO

RECONFIGURE;
GO

USE msdb;
GO

-- Create a Database Mail account

EXECUTE msdb.dbo.sysmail_add_account_sp @account_name = '[SERVERNAAM] Alert Mail Account',
                                        @description = '[SERVERNAAM] Alert Mail Account',
                                        @email_address = '[SERVERNAAM]@bravis.nl',
                                        @replyto_address = 'no-reply@bravis.nl',
                                        @display_name = '[SERVERNAAM]',
                                        @mailserver_name = 'mail.zkh.local';

-- Create a Database Mail profile

EXECUTE msdb.dbo.sysmail_add_profile_sp @profile_name = '[SERVERNAAM] Alert Mail Profile',
                                        @description = '[SERVERNAAM] Alert Mail Profile';

-- Add the account to the profile

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp @profile_name = '[SERVERNAAM] Alert Mail Profile',
                                               @account_name = '[SERVERNAAM] Alert Mail Account',
                                               @sequence_number = 1;

-- Grant access to the profile to all users in the msdb database

EXECUTE msdb.dbo.sysmail_add_principalprofile_sp @profile_name = '[SERVERNAAM] Alert Mail Profile',
                                                 @principal_name = 'public',
                                                 @is_default = 1;

-- Create the Operator accounts

EXEC msdb.dbo.sp_add_operator @name = N'Database Administrator',
                              @enabled = 1,
                              @pager_days = 0,
                              @email_address = N'DBA@bravis.nl';
GO

-- Als de mail goed ingesteld is wordt er een melding verstuurd naar de Operators met de status vermelding.

EXECUTE msdb.dbo.sp_notify_operator @name = N'Database Administrator',
                                    @body = N'Op SQL Server [SERVERNAAM] is de Database Mail ingesteld en is met deze mail succesvol getest.';
GO

--Activering van de Alert mail op de SQL Server Agent

EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder = 1;
GO

EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                     N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                     N'UseDatabaseMail',
                                     N'REG_DWORD',
                                     1;
GO

EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                     N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                     N'DatabaseMailProfile',
                                     N'REG_SZ',
                                     N'[SERVERNAAM] Alert Mail Profile';
GO