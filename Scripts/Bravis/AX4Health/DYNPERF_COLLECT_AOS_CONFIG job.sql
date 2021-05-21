USE [msdb]
GO

/****** Object:  Job [DYNPERF_COLLECT_AOS_CONFIG]    Script Date: 11-5-2020 16:49:14 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 11-5-2020 16:49:14 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DYNPERF_COLLECT_AOS_CONFIG', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COLLECT AOS CONFIG]    Script Date: 11-5-2020 16:49:14 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COLLECT AOS CONFIG', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'ActiveScripting', 
		@command=N'strSQLInstance = "gpax4hsql01"
strAXDataBase = "AX4HEALTH_PROD"

strSQLInstanceDPA = "gpax4hsql01"
strDataBaseDPA = "DynamicsPerf"


Const HKLM          = &H80000002
Const adInteger     = 3
Const adVarWChar    = 202
Const adlongVarWChar= 203
Const adParamInput  = &H0001
Const adCmdText     = &H0001
const REG_SZ        = 1
const REG_EXPAND_SZ = 2
const REG_BINARY    = 3
const REG_DWORD     = 4
const REG_MULTI_SZ  = 7

Dim objConnection
Dim objRecordset
Dim objCommandEvt
Dim objCommandReg


Dim objConnectionDPA
Dim objRecordsetDPA
Dim objCommandEvtDPA
Dim objCommandRegDPA



Dim prmEvt1
Dim prmEvt2
Dim prmEvt3
Dim prmEvt4
Dim prmEvt5
Dim prmEvt6

Dim prmReg1
Dim prmReg2
Dim prmReg3
Dim prmReg4
Dim prmReg5
Dim prmReg6
Dim prmReg7
Dim prmReg8


Dim strAOS
Dim strRecordset

strRecordset = "SELECT SUBSTRING(SERVERID,(CHARINDEX(''@'',SERVERID)+1), (LEN(SERVERID)-CHARINDEX(''@'',SERVERID)))FROM SYSSERVERCONFIG"

Set objConnection=CreateObject("ADODB.Connection") 
Set objRecordset=CreateObject("ADODB.Recordset")
set objCommandEvt=CreateObject("ADODB.command")
set objCommandReg=CreateObject("ADODB.command")


Set objConnectionDPA=CreateObject("ADODB.Connection") 
Set objRecordsetDPA=CreateObject("ADODB.Recordset")
set objCommandEvtDPA=CreateObject("ADODB.command")
set objCommandRegDPA=CreateObject("ADODB.command")




objConnection.Provider="SQLOLEDB"
objConnection.Properties("Data Source").Value = strSQLInstance
objConnection.Properties("Initial Catalog").Value = strAXDatabase
objConnection.Properties("Integrated Security").Value = "SSPI"

objConnection.Open


objConnectionDPA.Provider="SQLOLEDB"
objConnectionDPA.Properties("Data Source").Value = strSQLInstanceDPA
objConnectionDPA.Properties("Initial Catalog").Value = strDatabaseDPA
objConnectionDPA.Properties("Integrated Security").Value = "SSPI"

objConnectionDPA.Open



objCommandEvtDPA.ActiveConnection=objConnectionDPA
objCommandEvtDPA.CommandType=adCmdText
objCommandEvtDPA.CommandText="INSERT INTO DynamicsPerf..AOS_EVENTLOG VALUES (?,?,?,?,?,?)"

Set prmEvt1=objCommandEvtDPA.CreateParameter ("", adVarWChar,adParamInput,23)
Set prmEvt2=objCommandEvtDPA.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmEvt3=objCommandEvtDPA.CreateParameter ("", adInteger,adParamInput)
Set prmEvt4=objCommandEvtDPA.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmEvt5=objCommandEvtDPA.CreateParameter ("", adlongVarWChar,adParamInput,32768)
Set prmEvt6=objCommandEvtDPA.CreateParameter ("", adVarWChar,adParamInput,255)

objCommandEvtDPA.Parameters.Append prmEvt1
objCommandEvtDPA.Parameters.Append prmEvt2
objCommandEvtDPA.Parameters.Append prmEvt3
objCommandEvtDPA.Parameters.Append prmEvt4
objCommandEvtDPA.Parameters.Append prmEvt5
objCommandEvtDPA.Parameters.Append prmEvt6

objCommandRegDPA.ActiveConnection=objConnectionDPA
objCommandRegDPA.CommandType=adCmdText
objCommandRegDPA.CommandText="INSERT INTO DynamicsPerf..AOS_REGISTRY VALUES (?,?,?,?,?,?,?,?)"

Set prmReg1=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg2=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,5)
Set prmReg3=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg4=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,25)
Set prmReg5=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg6=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,1)
Set prmReg7=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg8=objCommandRegDPA.CreateParameter ("", adVarWChar,adParamInput,8000)

objCommandRegDPA.Parameters.Append prmReg1
objCommandRegDPA.Parameters.Append prmReg2
objCommandRegDPA.Parameters.Append prmReg3
objCommandRegDPA.Parameters.Append prmReg4
objCommandRegDPA.Parameters.Append prmReg5
objCommandRegDPA.Parameters.Append prmReg6
objCommandRegDPA.Parameters.Append prmReg7
objCommandRegDPA.Parameters.Append prmReg8

objConnectionDPA.Execute "SET DATEFORMAT MDY"
objConnectionDPA.Execute "TRUNCATE TABLE DynamicsPerf..AOS_EVENTLOG"
objConnectionDPA.Execute "TRUNCATE TABLE DynamicsPerf..AOS_REGISTRY"

objRecordset.Open strRecordset, objConnection


Do While Not objRecordset.EOF


				strAOS =  objRecordset.Fields(0) 


				On Error Resume Next

				Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strAOS & "\root\cimv2")
				if Err.Number <> 0 then
							set objWMIService = nothing
							err.clear
				Else
				Set objWMIService = Nothing


				AOSevt(strAOS)
				AOSreg(strAOS)

		end IF
		on error goto 0
		objRecordset.MoveNext 
Loop

Set objConnection=nothing
Set objRecordset=nothing
set objCommandEvt=nothing
set objCommandReg=nothing


Set objConnectionDPA=nothing
Set objRecordsetDPA=nothing
set objCommandEvtDPA=nothing
set objCommandRegDPA=nothing



Sub AOSevt(strAOS)
  
    Const CONVERT_TO_LOCAL_TIME = True
    Set dtmStartDate = CreateObject("WbemScripting.SWbemDateTime")
    DateToCheck = CDate(DATE - 14)
    dtmStartDate.SetVarDate DateToCheck, CONVERT_TO_LOCAL_TIME
    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strAOS & "\root\cimv2")
    Set colLoggedEvents = objWMIService.ExecQuery _
	    ("Select * from Win32_NTLogEvent Where Logfile = ''Application'' and (eventtype = 1 or eventtype = 2 or (eventtype = 3 and eventcode = 149)) and  TimeWritten >= ''" & dtmStartDate & "''")
    For Each objEvent in colLoggedEvents
        prmEvt1.value=cUTC2Lt(objEvent.TimeWritten)
        prmEvt2.value=objEvent.ComputerName
        prmEvt3.value=objEvent.EventCode
        prmEvt4.value=objEvent.Type
        prmEvt5.value=left(objEvent.Message, 256)
        prmEvt6.value=objEvent.SourceName
        objCommandEvtDPA.Execute
    Next	
End Sub

Sub AOSreg(strAOS)
    Const HKLM = &H80000002
    Set ObjReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & StrAOS & "\root\default:StdRegProv")
    StrKeyPath = "System\CurrentControlSet\Services\Dynamics Server"
    ObjReg.EnumKey HKLM, StrKeyPath, ArrVersions
    For Each StrVersion In ArrVersions
        ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion, ArrInstances
        If IsArray(ArrInstances) Then
            For Each StrInstance In ArrInstances 
                objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "InstanceName", strInstanceName 
                objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "Current", strCurrentConfig 
                objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "ProductVersion", strProductVersion 
                ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, ArrConfigs
                    For Each StrConfig In ArrConfigs
                        If StrConfig = StrCurrentConfig Then
                            strActive = "Y"
                        Else
                            strActive = "N"
                        End if
                        ObjReg.EnumValues HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, ArrValueNames,  ArrValueTypes
                        For I=0 To UBound(arrValueNames) 
                            StrValueName = arrValueNames(I)           
                            Select Case arrValueTypes(I)
                                Case REG_SZ
                                    objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_EXPAND_SZ
                                    objReg.GetExpandedStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_BINARY
                                     objReg.GetBinaryValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_DWORD
                                     objReg.GetDWORDValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                                Case REG_MULTI_SZ
                                     objReg.GetMultiStringValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
                            End Select        
                            prmReg1.value=StrAOS
                            prmReg2.value=StrVersion
                            prmReg3.value=strInstanceName
                            prmReg4.value=StrProductVersion
                            prmReg5.value=StrConfig
                            prmReg6.value=strActive
                            prmReg7.value=StrValueName
                            prmReg8.value=StrValue
                            objCommandRegDPA.Execute
                        Next
                    Next
            Next
        End If
    Next
End Sub

Function cUTC2Lt(WMITime)
''   Convert UTC Time from Event Log to DateTime format compatible with SQL Server DateTime data type
   	Dim strDate, strTime
   	Dim yyyy : yyyy = left(WMITime,4) ''year
   	Dim mm   : mm = mid(WMITime,5,2)  ''month
   	Dim dd   : dd = mid(WMITime,7,2)  ''day
   	Dim hh   : hh = mid(WMITime,9,2)  ''hour
   	Dim mn   : mn = mid(WMITime,11,2) ''minutes
   	Dim ss   : ss = mid(WMITime,13,2) ''seconds
   	Dim ms   : ms = mid(WMITime,16,6) ''microseconds
 ''  	strDate = mm & "-" & dd & "-" & yyyy
	strDate = yyyy & "-" & mm & "-" & dd
      	strTime = hh & ":" & mn & ":" & ss
      	cUTC2Lt = strDate & " " & strTime
End Function


', 
		@database_name=N'VBScript', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DAILY', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150919, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'098a5935-b897-4b13-8123-9bea9aff916d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


