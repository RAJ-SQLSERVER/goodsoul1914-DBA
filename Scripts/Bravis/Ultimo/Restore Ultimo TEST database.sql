--
-- LET OP: zorg dat eerst de Ultimo servicehost uit staat!
--

use master
go

backup database UltimoTest
to disk = 'D:\SQLBackup\UltimoTest.bak'
with format, stats = 10

alter database UltimoTest set single_user
go

restore database UltimoTest
from disk = 'D:\SQLBackup\Ultimoprod.bak'
with replace, stats = 10
go

alter database UltimoTest set multi_user
go

use UltimoTest

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