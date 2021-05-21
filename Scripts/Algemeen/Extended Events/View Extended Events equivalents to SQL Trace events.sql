/****************************************************************************
 View Extended Events equivalents to SQL Trace events using Query Editor 

 If you want to use Extended Events to collect event data that is equivalent 
 to SQL Trace event classes and columns, it is useful to understand how the 
 SQL Trace events map to Extended Events events and actions. 
****************************************************************************/

use MASTER;
go

select distinct 
    tb.trace_event_id, 
    te.name as 'Event Class', 
    em.package_name as 'Package', 
    em.xe_event_name as 'XEvent Name', 
    tb.trace_column_id, 
    tc.name as 'SQL Trace Column', 
    am.xe_action_name as 'Extended Events action'
from sys.trace_events as te
left join sys.trace_xe_event_map as em on te.trace_event_id = em.trace_event_id
left join sys.trace_event_bindings as tb on em.trace_event_id = tb.trace_event_id
left join sys.trace_columns as tc on tb.trace_column_id = tc.trace_column_id
left join sys.trace_xe_action_map as am on tc.trace_column_id = am.trace_column_id
order by 
    te.name, 
    tc.name;