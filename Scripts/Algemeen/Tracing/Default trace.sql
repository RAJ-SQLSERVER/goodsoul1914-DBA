-- get the current trace rollover file
SELECT *     
FROM ::fn_trace_getinfo(0)
GO

USE [master]
GO

CREATE DATABASE TraceDB
GO

SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('D:\SQLData\MSSQL15.MSSQLSERVER\MSSQL\Log\log_21.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename = 'TraceDB' AND
      objectname IS NULL AND --filter by objectname
      e.category_id = 5 AND --category 5 is objects
      e.trace_event_id = 46 
      --trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj
GO

USE [TraceDB]
GO

CREATE TABLE [dbo].[MyTable](
    [id] [int] IDENTITY(1,1) NOT NULL,
    [sometext] [char](3) NULL
) ON [PRIMARY]
GO

SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('D:\SQLData\MSSQL15.MSSQLSERVER\MSSQL\Log\log_21.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename = 'TraceDB' AND
      objectname = 'MyTable' AND --filter by objectname
      e.category_id = 5 AND --category 5 is objects
      e.trace_event_id = 46
      --trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj
GO


USE [TraceDB]
GO
ALTER TABLE MyTable
ADD col INT
GO


SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('D:\SQLData\MSSQL15.MSSQLSERVER\MSSQL\Log\log_21.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename = 'TraceDB' AND
      objectname = 'MyTable' AND --filter by objectname
      e.category_id = 5 AND --category 5 is objects
      e.trace_event_id = 164 
      --trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj


USE [TraceDB]
GO
DROP TABLE MyTable


SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name as [CategoryName],
     textdata,
     starttime,
     eventclass,
     eventsubclass,--0=begin,1=commit
     e.name as EventName
FROM ::fn_trace_gettable('D:\SQLData\MSSQL15.MSSQLSERVER\MSSQL\Log\log_21.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename = 'TraceDB' AND
      objectname = 'MyTable' --AND --filter by objectname
      --e.category_id = 5 AND --category 5 is objects
      --e.trace_event_id = 47 
      --trace_event_id: 46=Create Obj,47=Drop Obj,164=Alter Obj
ORDER BY starttime
go


/*
The query below will pull all trace data using the log auto growth event. 
Note: You will not have any log growth for TraceDb because we have not done 
in large inserts to make the log grow. You should apply this query to 
another database where you want to monitor log growth.
*/
SELECT 
     loginname,
     loginsid,
     spid,
     hostname,
     applicationname,
     servername,
     databasename,
     objectName,
     e.category_id,
     cat.name,
     textdata,
     starttime,
     endtime,
     duration,
     eventclass,
     eventsubclass,
     e.name as EventName
FROM ::fn_trace_gettable('D:\SQLData\MSSQL15.MSSQLSERVER\MSSQL\Log\log_21.trc',0)
     INNER JOIN sys.trace_events e
          ON eventclass = trace_event_id
     INNER JOIN sys.trace_categories AS cat
          ON e.category_id = cat.category_id
WHERE databasename = 'TraceDB' AND
      e.category_id = 2 AND --category 2 is database
      e.trace_event_id = 93 --93=Log File Auto Grow
GO


--list of events 
SELECT *
FROM sys.trace_events

--list of categories 
SELECT *
FROM sys.trace_categories

--list of subclass values
SELECT *
FROM sys.trace_subclass_values

--Get trace Event Columns
SELECT 
     t.EventID,
     t.ColumnID,
     e.name AS Event_Descr,
     c.name AS Column_Descr
FROM ::fn_trace_geteventinfo(1) t
     INNER JOIN sys.trace_events e 
          ON t.eventID = e.trace_event_id
     INNER JOIN sys.trace_columns c 
          ON t.columnid = c.trace_column_id


--References:

--List of available events:
--http://blogs.technet.com/vipulshah/archive/2007/04/16/default-trace-in-sql-server-2005.aspx

--How to enable default trace:
--http://msdn.microsoft.com/en-us/library/ms175513(SQL.90).aspx