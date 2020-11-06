USE DBA
GO



EXEC dbo.sp_PressureDetector;



EXEC dbo.sp_WhoIsActive @get_task_info = 2, @get_additional_info = 1;

EXEC dbo.sp_WhoIsActive @get_locks = 1;

EXEC dbo.sp_WhoIsActive @find_block_leaders = 1,
                        @sort_order = '[blocked_session_count] DESC';



EXEC dbo.sp_HumanEvents @event_type = N'compiles',
                        @keep_alive = 1,
                        @debug = 0;

EXEC dbo.sp_HumanEvents @event_type = N'recompiles',
                        @keep_alive = 1,
                        @debug = 0;

EXEC dbo.sp_HumanEvents @event_type = N'query',
                        @keep_alive = 1,
                        @debug = 0;

EXEC dbo.sp_HumanEvents @event_type = N'waits',
                        @keep_alive = 1,
                        @debug = 0;

EXEC dbo.sp_HumanEvents @event_type = N'blocking',
                        @keep_alive = 1,
                        @debug = 0;



EXEC dbo.sp_HumanEvents @debug = 0,
                        @output_database_name = N'DBA',
                        @output_schema_name = N'dbo';

