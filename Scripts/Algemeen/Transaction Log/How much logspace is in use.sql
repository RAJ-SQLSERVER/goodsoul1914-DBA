DBCC SQLPERF(LOGSPACE);
GO


--SELECT primary_database FROM msdb..log_shipping_primary_databases;
--GO

--USE master;
--GO
--EXEC sp_delete_log_shipping_primary_secondary @primary_database = 'HIX_PRODUCTIE',
--                                              @secondary_server = 'GPHIXLS02',
--                                              @secondary_database = 'HIX_PRODUCTIE';
--GO


RESTORE DATABASE HIX_PRODUCTIE
    FROM DISK = N'\\gahixsql01.zkh.local\Share\HIX_BACKUP_VOORTESTACC.bak'
    WITH MOVE N'HIX_PRODUCTIE_Data'
             TO N'D:\SQLData\HIX_PRODUCTIE.mdf',
         MOVE N'HIX_PRODUCTIE_Log'
             TO N'E:\SQLLogs\HIX_PRODUCTIE.ldf',
         MOVE N'HIX_PRODUCTIE_MULTIMEDIA'
             TO N'D:\SQLData\HIX_PRODUCTIE_MM.ldf',
         REPLACE,
         STATS = 1,
         NORECOVERY;
GO