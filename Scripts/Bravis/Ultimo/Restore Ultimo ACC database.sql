--
-- LET OP: zorg dat eerst de Ultimo servicehost uit staat!
--

use master
go

alter database UltimoAccept set single_user
go

restore database UltimoAccept
from disk = 'D:\SQLBackup\Ultimoprod.bak'
with replace, stats = 10
go

alter database UltimoAccept set multi_user
go

use UltimoAccept
go

--Importconnectoren uitzetten
update dba.importconnector 
set imcrecstatus = '1'

--Exportconnectoren uitzetten
update dba.ExportConnector 
set excrecstatus = '1'

--Email import uitzetten
update dba.EmailServerAccount 
set esarecstatus = '1'

--Scheduled workflows uitzetten
update dba.SSCHEDULEDWORKFLOW 
set SSWFLRECSTATUS = '0'

--
-- TODO: zet de Ultimo servicehost weer aan
--