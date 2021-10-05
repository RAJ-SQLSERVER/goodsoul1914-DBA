/* 
First, you need to set up permanent sessions to collect data. 

You can use commands like these to do that, but I urge you to add some 
filters like above to cut down on the data collected. 

On busy servers, over-collection can cause performance issues.
*/
EXEC sp_HumanEvents @event_type = N'compiles', @keep_alive = 1;
EXEC sp_HumanEvents @event_type = N'recompiles', @keep_alive = 1;
EXEC sp_HumanEvents @event_type = N'query', @keep_alive = 1;
EXEC sp_HumanEvents @event_type = N'waits', @keep_alive = 1;
EXEC sp_HumanEvents @event_type = N'blocking', @keep_alive = 1;


/*
Once your sessions are set up, this is the command to tell sp_HumanEvents 
which database and schema to log data to. Table names are created internally, 
so don’t worry about those.
*/
EXEC sp_HumanEvents @output_database_name = N'YourDatabase', @output_schema_name = N'dbo';

/*
Ideally, you’ll stick this in an Agent Job, so you don’t need to rely on an SSMS window 
being open all the time. The job creation code linked is set to check in every 10 seconds, 
in case of errors.

Internally, this will run in its own loop with a WAITFOR of 5 seconds to flush data out.
*/