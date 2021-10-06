USE [AdventureWorks2012];
GO

IF EXISTS(SELECT * 
		  FROM sys.server_event_sessions 
		  WHERE name=N'MonitorTempdbContention')
    DROP EVENT SESSION [MonitorTempdbContention] 
	ON SERVER;
GO

CREATE EVENT SESSION MonitorTempdbContention 
ON SERVER 
ADD EVENT sqlserver.latch_suspend_end(
    WHERE (	database_id=2 AND 
			duration>0 AND 
			(mode=3 OR 
				mode=4) AND 
			has_waiters=1 AND 
			(page_id<4 OR -- Initial allocation bitmap pages
				package0.divides_by_uint64(page_id, 8088) OR --PFS pages
				package0.divides_by_uint64(page_id, 511232) OR  --GAM Pages
				page_id=511233 OR  --2nd SGAM page 4GB-8GB
				page_id=1022465 OR --3rd SGAM page 8GB-12GB
				page_id=1533697 OR --4th SGAM page 12GB-16GB
				page_id=2044929 OR --5th SGAM page 16GB-20GB
				page_id=2556161 OR --6th SGAM page 20GB-24GB
				page_id=3067393 OR --7th SGAM page 24GB-28GB
				page_id=3578625) --8th SGAM page 28GB-32GB
			)
		)
ADD TARGET package0.ring_buffer,
ADD TARGET package0.histogram(
	SET filtering_event_name=N'sqlserver.latch_suspend_end',
		source=N'page_id',
		source_type=0);
GO
-- Start the event session
ALTER EVENT SESSION [MonitorTempdbContention]
ON SERVER
STATE=START;
GO

