/********************************************************************************
Author: David Fowler
Revision date: 05/10/2017
Version: 1
********************************************************************************/

select COUNT(*) --fn_dblog.*
from fn_dblog (null, null)
where operation in ('LOP_MODIFY_ROW', 'LOP_INSERT_ROWS', 'LOP_DELETE_ROWS')
	  and context in ('LCX_HEAP', 'LCX_CLUSTERED')
	  and [Transaction ID] =
(
	select fn_dblog.[Transaction ID]
	from sys.dm_tran_session_transactions as session_trans
		 join fn_dblog (null, null) on fn_dblog.[Xact ID] = session_trans.transaction_id
	where session_id = @@SPID
);