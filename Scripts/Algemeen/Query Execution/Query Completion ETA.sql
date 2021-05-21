/****************************************************************************/
/*							Bravis Ziekenhuis								*/
/*                                                                          */
/*                    http://www.bravisziekenhuis.nl                        */
/*                         m.boomaars@bravis.nl                             */
/****************************************************************************/
/*						   sys.dm_exec_requests							    */
/*                      Estimated Completion Time                           */
/****************************************************************************/

-- Get estimated query completion time for the current database
------------------------------------------------------------------------------

select session_id, 
	   request_id, 
	   start_time, 
	   DATEADD(ms, estimated_completion_time, GETDATE()) as estimated_end_time, 
	   percent_complete, 
	   status, 
	   command, 
	   dop, 
	   last_wait_type, 
	   blocking_session_id, 
	   EST.text
from
	sys.dm_exec_requests as ER
cross apply
	sys.dm_exec_sql_text
	( ER.sql_handle ) as EST
where ER.database_id = DB_ID() and 
	  session_id <> @@SPID;


-- Seeing a Count of All Active SQL Server Wait Types
------------------------------------------------------------------------------

select COALESCE(wait_type, 'None') as wait_type, 
	   COUNT(*) as Total
from sys.dm_exec_requests
where not status in ('Background', 'Sleeping')
group by wait_type
order by Total desc;


-- Determine what types of locks these active requests were trying to obtain
------------------------------------------------------------------------------

select L.request_session_id, 
	   L.resource_type, 
	   L.resource_subtype, 
	   L.request_mode, 
	   L.request_type
from
	sys.dm_tran_locks as L
join
	sys.dm_exec_requests as DER on L.request_session_id = DER.session_id
where DER.wait_type = 'CXPACKET';