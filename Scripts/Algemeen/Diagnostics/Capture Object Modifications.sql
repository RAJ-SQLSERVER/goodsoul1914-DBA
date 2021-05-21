create event session [CaptureObjectModifications] on server add event sqlserver.object_altered(action(
    sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id, sqlserver.database_name, sqlserver.server_principal_name, sqlserver.session_id, sqlserver.sql_text)), add event sqlserver.object_created(action(
    sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id, sqlserver.database_name, sqlserver.server_principal_name, sqlserver.session_id, sqlserver.sql_text)), add event sqlserver.object_deleted(action(
    sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id, sqlserver.database_name, sqlserver.server_principal_name, sqlserver.session_id, sqlserver.sql_text)) add target package0.ring_buffer(set max_events_limit = 0, max_memory = 102400);
go

/*********
 Query it 
*********/

with raw_data(t)
as (select CONVERT(xml, target_data)
    from sys.dm_xe_sessions as s
    inner join sys.dm_xe_session_targets as st on s.address = st.event_session_address
    where s.name = 'CaptureObjectModifications'
        and st.target_name = 'ring_buffer'),

xml_data(ed)
as (select e.query ('.')
    from raw_data
    cross apply t.nodes ('RingBufferTarget/event') as x(e))

select * --FROM xml_data;
from (select 
        timestamp = ed.value ('(event/@timestamp)[1]', 'datetime'), 
        database_id = ed.value ('(event/data[@name="database_id"]/value)[1]', 'int'), 
        database_name = ed.value ('(event/action[@name="database_name"]/value)[1]', 'nvarchar(128)'), 
        object_type = ed.value ('(event/data[@name="object_type"]/text)[1]', 'nvarchar(128)'), 
        object_id = ed.value ('(event/data[@name="object_id"]/value)[1]', 'int'), 
        object_name = ed.value ('(event/data[@name="object_name"]/value)[1]', 'nvarchar(128)'), 
        session_id = ed.value ('(event/action[@name="session_id"]/value)[1]', 'int'), 
        login = ed.value ('(event/action[@name="server_principal_name"]/value)[1]', 'nvarchar(128)'), 
        client_hostname = ed.value ('(event/action[@name="client_hostname"]/value)[1]', 'nvarchar(128)'), 
        client_app_name = ed.value ('(event/action[@name="client_app_name"]/value)[1]', 'nvarchar(128)'), 
        sql_text = ed.value ('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)'), 
        phase = ed.value ('(event/data[@name="ddl_phase"]/text)[1]', 'nvarchar(128)')
    from xml_data) as x
where phase = 'Commit'
order by 
    timestamp;
