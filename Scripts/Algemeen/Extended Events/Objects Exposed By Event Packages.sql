-- Returns a row for each object that is exposed by an event package. 
-- Objects can be one of the following:
--
--	* Events indicate points of interest in an execution path. All events contain information about 
--		a point of interest.
--	* Actions are run synchronously when events fire. An action can append run time data to an event.
--	* Targets consume events, either synchronously on the thread that fires the event or 
--		asynchronously on a system-provided thread.
--	* Predicate sources retrieve values from event sources for use in comparison operations. 
--		Predicate comparisons compare specific data types and return a Boolean value.
--	* Types encapsulate the length and characteristics of the byte collection, which is required in 
--		order to interpret the data.
--
---------------------------------------------------------------------------------------------------

select xp.name as PkgName, 
	   xo.name as ObjName, 
	   xo.description, 
	   xo.object_type, 
	   xo.type_name
from sys.dm_xe_objects as xo
	 inner join sys.dm_xe_packages as xp on xo.package_guid = xp.guid;
go