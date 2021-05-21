RESTORE FILELISTONLY   
FROM DISK = N'\\gpspreportsql01\SQLBackup\GPSPREPORTSQL01\SpeechReport\FULL\GPSPREPORTSQL01_SpeechReport_FULL_20200226_232028.bak'  
go


restore database SpeechReportQueryTmp
from disk = '\\gpspreportsql01\SQLBackup\GPSPREPORTSQL01\SpeechReport\FULL\GPSPREPORTSQL01_SpeechReport_FULL_20200226_232028.bak'
with
	move N'SpeechReport' to N'D:\MSSQL\Data\SpeechReportQueryTmp.mdf',
	move N'SpeechReportData1' to N'D:\MSSQL\Data\SpeechReportQueryTmpData1.ndf',
	move N'SpeechReportFile1' to N'D:\MSSQL\Data\SpeechReportQueryTmpFile1.ndf',
	move N'SpeechReportLog1' to N'D:\MSSQL\Data\SpeechReportQueryTmpLog1.ldf',
	recovery,
	stats
go
