/* sp_HumanEvents Sampling Live Data */

USE DBA
GO

-- To capture all types of "completed" queries that have run for at least one second, 
-- for 20 seconds, from a specific database
EXEC dbo.sp_HumanEvents @event_type = 'query',
                        @query_duration_ms = 1000,
                        @seconds_sample = 20,
                        @database_name = 'salesdb';

-- Maybe you want to filter out queries that have asked for a bit of memory:
EXEC dbo.sp_HumanEvents @event_type = 'query',
                        @query_duration_ms = 1000,
                        @seconds_sample = 20,
                        @requested_memory_mb = 1024;

-- Or maybe you want to find unparameterized queries from a poorly written app 
-- that constructs strings in ugly ways, but it generates a lot of queries 
-- so you only want data on about a third of them.
EXEC dbo.sp_HumanEvents @event_type = 'compilations',
                        @client_app_name = N'GL00SNIFЯ',
                        @session_id = 'sample',
                        @sample_divisor = 3;

-- Perhaps you think queries recompiling are the cause of your problems! 
-- Heck, they might be. Have you tried removing recompile hints?
EXEC dbo.sp_HumanEvents @event_type = 'recompilations', @seconds_sample = 30;

-- Look, blocking is annoying. Just turn on RCSI, you goblin. 
EXEC dbo.sp_HumanEvents @event_type = 'blocking',
                        @seconds_sample = 60,
                        @blocking_duration_ms = 5000;

-- If you want to track wait stats, this'll work pretty well. 
-- Keep in mind "all" is a focused list of "interesting" waits to queries, 
-- not every wait stat.
EXEC dbo.sp_HumanEvents @event_type = 'waits',
                        @wait_duration_ms = 10,
                        @seconds_sample = 100,
                        @wait_type = N'all';

-- Note that THREADPOOL is SOS_WORKER in xe-land.
EXEC dbo.sp_HumanEvents @event_type = 'waits',
                        @wait_duration_ms = 10,
                        @seconds_sample = 100,
                        @wait_type = N'SOS_WORKER,RESOURCE_SEMAPHORE';

/*
For some event types that allow you to set a minimum duration,
I've set a default minimum to try to avoid you introducing a lot of 
observer overhead to the server. If you understand the potential danger here, 
or you’re just trying to test things, you need to use the @gimme_danger parameter. 
You would also use this if you wanted to set an impermanent session to run for 
longer than 10 minutes.

For example, if you run this command:
*/
EXEC sp_HumanEvents @event_type = N'query', @query_duration_ms = 1;

/*
You’ll see this message in the output:

Checking query duration filter
You chose a really dangerous value for @query_duration
If you really want that, please set @gimme_danger = 1, and re-run
Setting @query_duration to 500

You need to use this command instead:
*/
EXEC sp_HumanEvents @event_type = N'query',
                    @query_duration_ms = 1,
                    @gimme_danger = 1;
