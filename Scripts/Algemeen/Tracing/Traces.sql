-- Querying sys.traces for the default trace characteristics.
select *
from sys.traces
where is_default = 1;
go

-- Events collected by the default trace.
select distinct 
	   e.trace_event_id, 
	   e.name
from sys.fn_trace_geteventinfo (1) as t
	 join sys.trace_events as e on t.eventID = e.trace_event_id;
go

-- Reading a trace file using sys.fn_trace_gettable.
declare @FileName nvarchar(260);
select @FileName = SUBSTRING(path, 0, LEN(path) - CHARINDEX('\', REVERSE(path)) + 1) + '\Log.trc'
from sys.traces
where is_default = 1;

select loginname, 
	   hostname, 
	   applicationname, 
	   databasename, 
	   objectName, 
	   starttime, 
	   e.name as EventName, 
	   databaseid
from sys.fn_trace_gettable (@FileName, default) as gt
	 inner join sys.trace_events as e on gt.EventClass = e.trace_event_id
where( gt.EventClass = 47 -- Object:Deleted Event from sys.trace_events
	   or gt.EventClass = 164
	 ) -- Object:Altered Event from sys.trace_events
	 and gt.EventSubClass = 0
	 and gt.DatabaseID = DB_ID('AdventureWorks2017');
go