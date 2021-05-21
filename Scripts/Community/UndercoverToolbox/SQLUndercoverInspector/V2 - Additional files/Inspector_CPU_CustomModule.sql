﻿/*********************************************
Description: CPU Custom module for the Inspector
			 Collect CPU % and report when % over CPU Thresholds which can be configured by changing the values for CPUThreshold in [Inspector].[Settings]
Author: Adrian Buckman
Revision date: 15/12/2020
Credit: David Fowler for the CPU collection query body as this was a snippt taken from a stored procedure he had called sp_CPU_Time

� www.sqlundercover.com 

MIT License
------------
 
Copyright 2020 Sql Undercover
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

*********************************************/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;

DECLARE @MonitorHourStart INT = 0; -- 0 to 23
DECLARE @MonitorHourEnd INT = 23; -- 0 to 23
DECLARE @Revisiondate DATETIME = '20201215';
DECLARE @InspectorBuild DECIMAL(4,2);
DECLARE @LinkedServername NVARCHAR(128);
DECLARE @SQLstmt NVARCHAR(4000);
DECLARE @InspectorBuildString VARCHAR(6); 



IF SCHEMA_ID(N'Inspector') IS NOT NULL
BEGIN 

	SET @InspectorBuild = (SELECT TRY_CAST([Value] AS DECIMAL(4,2)) FROM [Inspector].[Settings] WHERE [Description] = 'InspectorBuild');
	SET @LinkedServername = (SELECT UPPER(TRY_CAST([Value] AS NVARCHAR(128))) FROM [Inspector].[Settings] WHERE [Description] = 'LinkedServername');

	SET @InspectorBuildString = CAST(@InspectorBuild AS VARCHAR(6));

	/* Minimum Inspector version check */
	IF (@InspectorBuild < 2.4)
	BEGIN 
		RAISERROR('Your Inspector version (%s) does not meet the minimum build required required: 2.4',11,0,@InspectorBuildString);
		RETURN;
	END 
	
	IF ((@MonitorHourStart NOT BETWEEN 0 AND 23) OR (@MonitorHourEnd NOT BETWEEN 0 AND 23))
	BEGIN 
		RAISERROR('@MonitorHourStart and @MonitorHourEnd must be between 0 and 23',11,0);
		RETURN;
	END
	
	
	IF (@LinkedServername IS NOT NULL) AND NOT EXISTS(SELECT 1 FROM sys.servers WHERE [name] = @LinkedServername)
	BEGIN 
		RAISERROR('Linked server name is incorrect',11,0,@LinkedServername);
		RETURN;
	END 

	IF OBJECT_ID('Inspector.ServerSettingThresholds') IS NULL 
	BEGIN 
		RAISERROR('Inspector ServerSettingThresholds table not found - please double check you are using the correct database and the Inspector base install is up to date',11,0);
		RETURN;
	END 

	IF OBJECT_ID('Inspector.GetServerModuleThreshold') IS NULL 
	BEGIN 
		RAISERROR('Inspector GetServerModuleThreshold function not found - please double check you are using the correct database and the Inspector base install is up to date',11,0);
		RETURN;
	END

	IF OBJECT_ID('Inspector.MonitorHours') IS NULL 
	BEGIN 
		RAISERROR('Inspector MonitorHours table not found - please double check you are using the correct database and the Inspector base install is up to date',11,0);
		RETURN;
	END 	
	
	
IF OBJECT_ID('Inspector.CPU',N'U') IS NULL 
BEGIN 
	CREATE TABLE [Inspector].[CPU] (
	Servername NVARCHAR(128),
	Log_Date DATETIME,
	EventTime DATETIME,
	SystemCPUUtilization INT,
	SQLCPUUtilization INT,
	OtherCPU AS SystemCPUUtilization-SQLCPUUtilization
	);
END

IF OBJECT_ID('Inspector.PSCPUStage',N'U') IS NULL
BEGIN 
	CREATE TABLE [Inspector].[PSCPUStage](
	[Servername] [nvarchar](128) NULL,
	[Log_Date] [datetime] NULL,
	[EventTime] [datetime] NULL,
	[SystemCPUUtilization] [int] NULL,
	[SQLCPUUtilization] [int] NULL
	);
END
	

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID('Inspector.CPU',N'U') AND [name] = N'CIX_CPU_EventTime')
BEGIN 
	CREATE CLUSTERED INDEX [CIX_CPU_EventTime] ON [Inspector].[CPU] (EventTime ASC);
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID('Inspector.CPU',N'U') AND [name] = N'IX_CPU_Servername')
BEGIN 
	CREATE NONCLUSTERED INDEX [IX_CPU_Servername] ON [Inspector].[CPU] (Servername ASC);
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID('Inspector.PSCPUStage',N'U') AND [name] = N'CIX_PSCPUStage_EventTime')
BEGIN 
	CREATE CLUSTERED INDEX [CIX_PSCPUStage_EventTime] ON [Inspector].[PSCPUStage] ([EventTime] ASC);
END


IF NOT EXISTS(SELECT 1 FROM [Inspector].[Settings] WHERE [Description] = 'CPUHistoryRetentionInDays')
BEGIN 
	INSERT INTO [Inspector].[Settings] ([Description],[Value])
	VALUES('CPUHistoryRetentionInDays','7');
END

IF NOT EXISTS(SELECT 1 FROM [Inspector].[Settings] WHERE [Description] = 'CPUThresholdWarningHighlight')
BEGIN 
	INSERT INTO [Inspector].[Settings] ([Description],[Value])
	VALUES('CPUThresholdWarningHighlight','90');
END

IF NOT EXISTS(SELECT 1 FROM [Inspector].[Settings] WHERE [Description] = 'CPUThresholdAdvisoryHighlight')
BEGIN 
	INSERT INTO [Inspector].[Settings] ([Description],[Value])
	VALUES('CPUThresholdAdvisoryHighlight','85');
END

IF NOT EXISTS(SELECT 1 FROM [Inspector].[Settings] WHERE [Description] = 'CPUThresholdInfoHighlight')
BEGIN 
	INSERT INTO [Inspector].[Settings] ([Description],[Value])
	VALUES('CPUThresholdInfoHighlight','75');
END

IF NOT EXISTS(SELECT 1 FROM [Inspector].[Settings] WHERE [Description] = 'CPUBreachedConsecutiveCount')
BEGIN
	INSERT INTO [Inspector].[Settings] ([Description],[Value])
	VALUES ('CPUBreachedConsecutiveCount',NULL);
END

/* We want to make sure your previous config is copied to the new table otherwise we will pop a default row in the new MonitorHours table, we will be dropping CPUConfig */
IF OBJECT_ID('Inspector.CPUConfig') IS NOT NULL 
BEGIN
EXEC sp_executesql N'
IF EXISTS (SELECT 1 FROM [Inspector].[CPUConfig]) 
BEGIN 
	--Grouping to ensure we only get one row per server as the new table will not accept duplicates so assuming the MAX Start and MIN End for the narrowest window
	INSERT INTO [Inspector].[MonitorHours] (Servername,Modulename,MonitorHourStart,MonitorHourEnd)
	SELECT 
	[Servername],
	''CPU'',
	MAX([MonitorHourStart]),
	MIN([MonitorHourEnd])
	FROM [Inspector].[CPUConfig]
	WHERE NOT EXISTS (SELECT 1 FROM [Inspector].[MonitorHours] WHERE [CPUConfig].[Servername] = [MonitorHours].[Servername] AND [MonitorHours].[Modulename] = ''CPU'')
	GROUP BY 
	[Servername];
END';
END


EXEC sp_executesql N'INSERT INTO [Inspector].[MonitorHours] ([Servername],[Modulename],[MonitorHourStart],[MonitorHourEnd])
SELECT [Servername],''CPU'',@MonitorHourStart,@MonitorHourEnd 
FROM [Inspector].[CurrentServers]
WHERE [IsActive] = 1
AND NOT EXISTS (SELECT 1 
			FROM [Inspector].[MonitorHours]
			WHERE [MonitorHours].[Servername] = [CurrentServers].[Servername]
			AND [Modulename] = ''CPU''
			);',
N'@MonitorHourStart INT, @MonitorHourEnd INT',
@MonitorHourStart = @MonitorHourStart,
@MonitorHourEnd = @MonitorHourEnd;


IF OBJECT_ID('Inspector.CPUInsert',N'P') IS NULL 
BEGIN 
	EXEC('CREATE PROCEDURE [Inspector].[CPUInsert] AS');
END 

IF OBJECT_ID('Inspector.CPUInsert',N'P') IS NOT NULL
BEGIN 

IF @LinkedServername IS NULL 
BEGIN 
SET @SQLstmt = N'ALTER PROCEDURE [Inspector].[CPUInsert]
AS
BEGIN 
--Revision date: 07/12/2019
	DECLARE @ts_now BIGINT
	DECLARE @Frequency INT 
	DECLARE @CPUHistoryRetentionInDays INT 
	
	SET @CPUHistoryRetentionInDays = (SELECT ISNULL(TRY_CAST([Value] AS INT),7) FROM [Inspector].[Settings] WHERE [Description] = ''CPUHistoryRetentionInDays'');
	SET @Frequency = (SELECT MAX([Frequency]) FROM Inspector.Modules WHERE Modulename = ''CPU''); 
	SET @ts_now = (SELECT cpu_ticks / (cpu_ticks/ms_ticks)  FROM sys.dm_os_sys_info);

	IF @CPUHistoryRetentionInDays IS NULL BEGIN SET @CPUHistoryRetentionInDays = 7 END;

	DELETE FROM [Inspector].[CPU] 
	WHERE [EventTime] < DATEADD(DAY,-@CPUHistoryRetentionInDays,GETDATE())
	AND [Servername] = @@SERVERNAME;
	
	INSERT INTO [Inspector].[CPU] (Servername,Log_Date,EventTime,SystemCPUUtilization,SQLCPUUtilization)
	SELECT 
	@@SERVERNAME,
	GETDATE(),
	EventTime, 
	ISNULL(system_cpu_utilization_post_sp2, system_cpu_utilization_pre_sp2) AS SystemCPUUtilization,
	ISNULL(sql_cpu_utilization_post_sp2, sql_cpu_utilization_pre_sp2) AS SQLCPUUtilization
	FROM 
	(
	  SELECT 
	    record.value(''(Record/@id)[1]'', ''int'') AS record_id,
	    DATEADD (ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS EventTime,
	    100-record.value(''(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS system_cpu_utilization_post_sp2,
	    record.value(''(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS sql_cpu_utilization_post_sp2 , 
	    100-record.value(''(Record/SchedluerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS system_cpu_utilization_pre_sp2,
	    record.value(''(Record/SchedluerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS sql_cpu_utilization_pre_sp2
	  FROM (
	    SELECT timestamp, CONVERT (xml, record) AS record 
	    FROM sys.dm_os_ring_buffers 
	    WHERE ring_buffer_type = ''RING_BUFFER_SCHEDULER_MONITOR''
	    AND record LIKE ''%<SystemHealth>%'') AS t
	) AS t
	WHERE EventTime > DATEADD(MINUTE,-@Frequency,GETDATE())
	AND NOT EXISTS (SELECT 1 FROM Inspector.CPU WHERE CPU.EventTime  = t.EventTime AND CPU.Servername = @@SERVERNAME);
END';
END
ELSE 
BEGIN 
SET @SQLstmt = N'ALTER PROCEDURE [Inspector].[CPUInsert]
AS
BEGIN 
--Revision date: 07/12/2019
	DECLARE @ts_now BIGINT
	DECLARE @Frequency INT 
	DECLARE @CPUHistoryRetentionInDays INT 
	
	SET @CPUHistoryRetentionInDays = (SELECT ISNULL(TRY_CAST([Value] AS INT),7) FROM '+QUOTENAME(@LinkedServername)+N'.'+QUOTENAME(DB_NAME())+N'.[Inspector].[Settings] WHERE [Description] = ''CPUHistoryRetentionInDays'');
	SET @Frequency = (SELECT MAX([Frequency]) FROM Inspector.Modules WHERE Modulename = ''CPU''); 
	SET @ts_now = (SELECT cpu_ticks / (cpu_ticks/ms_ticks)  FROM sys.dm_os_sys_info);

	IF @CPUHistoryRetentionInDays IS NULL BEGIN SET @CPUHistoryRetentionInDays = 7 END;

	DELETE FROM '+QUOTENAME(@LinkedServername)+N'.'+QUOTENAME(DB_NAME())+N'.[Inspector].[CPU] 
	WHERE [EventTime] < DATEADD(DAY,-@CPUHistoryRetentionInDays,GETDATE())
	AND [Servername] = @@SERVERNAME;
	
	INSERT INTO '+QUOTENAME(@LinkedServername)+N'.'+QUOTENAME(DB_NAME())+N'.[Inspector].[CPU] (Servername,Log_Date,EventTime,SystemCPUUtilization,SQLCPUUtilization)
	SELECT 
	@@SERVERNAME,
	GETDATE(),
	EventTime, 
	ISNULL(system_cpu_utilization_post_sp2, system_cpu_utilization_pre_sp2) AS SystemCPUUtilization,
	ISNULL(sql_cpu_utilization_post_sp2, sql_cpu_utilization_pre_sp2) AS SQLCPUUtilization
	FROM 
	(
	  SELECT 
	    record.value(''(Record/@id)[1]'', ''int'') AS record_id,
	    DATEADD (ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS EventTime,
	    100-record.value(''(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS system_cpu_utilization_post_sp2,
	    record.value(''(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS sql_cpu_utilization_post_sp2 , 
	    100-record.value(''(Record/SchedluerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS system_cpu_utilization_pre_sp2,
	    record.value(''(Record/SchedluerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS sql_cpu_utilization_pre_sp2
	  FROM (
	    SELECT timestamp, CONVERT (xml, record) AS record 
	    FROM sys.dm_os_ring_buffers 
	    WHERE ring_buffer_type = ''RING_BUFFER_SCHEDULER_MONITOR''
	    AND record LIKE ''%<SystemHealth>%'') AS t
	) AS t
	WHERE EventTime > DATEADD(MINUTE,-@Frequency,GETDATE())
	AND NOT EXISTS (SELECT 1 FROM '+QUOTENAME(@LinkedServername)+N'.'+QUOTENAME(DB_NAME())+N'.[Inspector].[CPU] WHERE CPU.EventTime  = t.EventTime AND CPU.Servername = @@SERVERNAME);
END';
END

END 

EXEC sp_executesql @SQLstmt;


IF OBJECT_ID('Inspector.PSGetCPUStage',N'P') IS NULL 
BEGIN 
	EXEC('CREATE PROCEDURE [Inspector].[PSGetCPUStage] AS');
END

IF OBJECT_ID('Inspector.PSGetCPUStage',N'P') IS NOT NULL 
BEGIN 
EXEC('ALTER PROCEDURE [Inspector].[PSGetCPUStage] (
@Servername NVARCHAR(128)
)
AS
BEGIN 
	--Revision Date: 01/02/2020

	INSERT INTO [Inspector].[CPU] ([Servername],[Log_Date],[EventTime],[SystemCPUUtilization],[SQLCPUUtilization])
	SELECT [Servername],[Log_Date],[EventTime],[SystemCPUUtilization],[SQLCPUUtilization]
	FROM [Inspector].[PSCPUStage] Stage
	WHERE [Servername] = @Servername 
	AND NOT EXISTS (SELECT 1 
					FROM [Inspector].[CPU] Base
					WHERE [Base].[EventTime] = [Stage].[EventTime]
					AND	[Base].[Servername] = [Stage].[Servername])
END');
END

IF OBJECT_ID('Inspector.CPUReport',N'P') IS NULL 
BEGIN 
	EXEC('CREATE PROCEDURE [Inspector].[CPUReport] AS');
END

IF OBJECT_ID('Inspector.CPUReport',N'P') IS NOT NULL 
BEGIN 
EXEC('ALTER PROCEDURE [Inspector].[CPUReport] (
@Servername NVARCHAR(128),
@Modulename VARCHAR(50),
@TableHeaderColour VARCHAR(7) = ''#E6E6FA'',
@WarningHighlight VARCHAR(7),
@AdvisoryHighlight VARCHAR(7),
@InfoHighlight VARCHAR(7),
@ModuleConfig VARCHAR(20),
@WarningLevel TINYINT,
@ServerSpecific BIT,
@NoClutter BIT,
@TableTail VARCHAR(256),
@HtmlOutput VARCHAR(MAX) OUTPUT,
@CollectionOutOfDate BIT OUTPUT,
@PSCollection BIT,
@Debug BIT = 0
)
AS

--Revision date: 15/12/2020
BEGIN
--Excluded from Warning level control
	DECLARE @HtmlTableHead VARCHAR(4000);
	DECLARE @Columnnames VARCHAR(2000);
	DECLARE @SQLtext NVARCHAR(4000);
	DECLARE @CPUThresholdWarningHighlight INT
	DECLARE @CPUThresholdAdvisoryHighlight INT
	DECLARE @CPUThresholdInfoHighlight INT
	DECLARE @CPUBreachedConsecutiveCount INT
	DECLARE @Frequency INT
	DECLARE @MonitorHourStart INT;
	DECLARE @MonitorHourEnd INT;

	IF OBJECT_ID(''tempdb.dbo.#InspectorModuleReport'') IS NOT NULL 
	DROP TABLE #InspectorModuleReport;
	
	CREATE TABLE #InspectorModuleReport (
	[@bgcolor] VARCHAR(7),
	[Servername] NVARCHAR(128), 
	[EventTime] VARCHAR(20),
	[SystemCPUUtilization] INT, 
	[SQLCPUUtilization] INT, 
	[OtherCPU] INT
	);

	SET @MonitorHourStart = (SELECT [MonitorHourStart] FROM [Inspector].[MonitorHours] WHERE [Servername] = @Servername AND [Modulename] = @Modulename);
	SET @MonitorHourEnd = (SELECT [MonitorHourEnd] FROM [Inspector].[MonitorHours] WHERE [Servername] = @Servername AND [Modulename] = @Modulename);
	SET @CPUThresholdWarningHighlight = (SELECT ISNULL(TRY_CAST([Inspector].[GetServerModuleThreshold] (@Servername,@Modulename,''CPUThresholdWarningHighlight'') AS INT),90));
	SET @CPUThresholdAdvisoryHighlight = (SELECT ISNULL(TRY_CAST([Inspector].[GetServerModuleThreshold] (@Servername,@Modulename,''CPUThresholdAdvisoryHighlight'') AS INT),85));
	SET @CPUThresholdInfoHighlight = (SELECT ISNULL(TRY_CAST([Inspector].[GetServerModuleThreshold] (@Servername,@Modulename,''CPUThresholdInfoHighlight'') AS INT),75));
	SET @CPUBreachedConsecutiveCount = (SELECT TRY_CAST([Inspector].[GetServerModuleThreshold] (@Servername,@Modulename,''CPUBreachedConsecutiveCount'') AS INT));
	SET @Frequency = (SELECT [Frequency] FROM Inspector.ModuleConfig WHERE ModuleConfig_Desc = @ModuleConfig); 
	
	SET @Debug = [Inspector].[GetDebugFlag](@Debug,@ModuleConfig,@Modulename);

	--Set defaults if NULL
	IF @CPUThresholdWarningHighlight IS NULL BEGIN SET @CPUThresholdInfoHighlight = 90 END;
	IF @CPUThresholdAdvisoryHighlight IS NULL BEGIN SET @CPUThresholdInfoHighlight = 85 END;
	IF @CPUThresholdInfoHighlight IS NULL BEGIN SET @CPUThresholdInfoHighlight = 75 END;
	IF @MonitorHourStart IS NULL BEGIN SET @MonitorHourStart = 0 END;
	IF @MonitorHourEnd IS NULL BEGIN SET @MonitorHourEnd = 23 END;

/********************************************************/
	--Your query MUST have a case statement that determines which colour to highlight rows
	--Your query MUST use an INTO clause to populate the temp table so that the column names can be determined for the report
	--@bgcolor is used the for table highlighting , Warning,Advisory and Info highlighting colours are determined from 
	--the ModuleWarningLevel table and your Case expression And/or Where clause will determine which rows get the highlight
	--query example:

/* If you have not enabled the consecutive counts threshold then use the original code to just check for any breaches regardless of consecutive duration */
IF (@CPUBreachedConsecutiveCount IS NULL)
BEGIN
	INSERT INTO #InspectorModuleReport ([@bgcolor],[Servername],[EventTime],[SystemCPUUtilization],[SQLCPUUtilization],[OtherCPU])
	SELECT 
	CASE 
		WHEN SystemCPUUtilization >= @CPUThresholdWarningHighlight THEN @WarningHighlight
		WHEN SystemCPUUtilization >= @CPUThresholdAdvisoryHighlight AND SystemCPUUtilization < @CPUThresholdWarningHighlight THEN @AdvisoryHighlight
		WHEN SystemCPUUtilization > @CPUThresholdInfoHighlight AND SystemCPUUtilization < @CPUThresholdAdvisoryHighlight THEN @InfoHighlight
	END AS [@bgcolor],
	Servername,
	CONVERT(VARCHAR(24),EventTime,113) AS EventTime,
	SystemCPUUtilization,
	SQLCPUUtilization,
	OtherCPU
	FROM [Inspector].[CPU]
	WHERE SystemCPUUtilization > @CPUThresholdInfoHighlight
	AND EventTime >= DATEADD(MINUTE,-@Frequency,GETDATE())
	AND Servername = @Servername
	AND DATEPART(HOUR,EventTime) BETWEEN @MonitorHourStart AND @MonitorHourEnd
END 
ELSE /* Otherwise let crack on and work out how many consecutive CPU recordings there are for the server and if greater than or equal to your threshold then show the results */
BEGIN 
INSERT INTO #InspectorModuleReport ([@bgcolor],[Servername],[EventTime],[SystemCPUUtilization],[SQLCPUUtilization],[OtherCPU])
EXEC sp_executesql N''WITH CPUForFrequency
     AS (SELECT [Servername], 
                [Log_Date], 
                [EventTime], 
                [SystemCPUUtilization], 
                [SQLCPUUtilization], 
                [OtherCPU], 
                ROW_NUMBER() OVER(
                ORDER BY [EventTime] ASC) AS [EventTimeOrderRN], 
                ROW_NUMBER() OVER(PARTITION BY(CASE
                                                   WHEN [SystemCPUUtilization] > @CPUThresholdInfoHighlight
                                                   THEN 1
                                                   ELSE 0
                                               END)
                ORDER BY [EventTime] ASC) AS [EventTimeOrderByThreshold]
         FROM [Inspector].[CPU]
         WHERE [EventTime] >= DATEADD(MINUTE, -@Frequency, GETDATE())
               AND [Servername] = @Servername
			   AND DATEPART(HOUR,EventTime) BETWEEN @MonitorHourStart AND @MonitorHourEnd),
     Consecutives
     AS (SELECT([EventTimeOrderRN]
                - [EventTimeOrderByThreshold]) AS [ConsecutiveBucketID], 
               COUNT(*) AS [TotalConsecutives]
         FROM [CPUForFrequency]
         WHERE [SystemCPUUtilization] > @CPUThresholdInfoHighlight
         GROUP BY([EventTimeOrderRN]
                  - [EventTimeOrderByThreshold]))
     SELECT CASE
                WHEN [SystemCPUUtilization] >= @CPUThresholdWarningHighlight THEN @WarningHighlight
                WHEN [SystemCPUUtilization] >= @CPUThresholdAdvisoryHighlight AND [SystemCPUUtilization] < @CPUThresholdWarningHighlight THEN @AdvisoryHighlight
                WHEN [SystemCPUUtilization] > @CPUThresholdInfoHighlight AND [SystemCPUUtilization] < @CPUThresholdAdvisoryHighlight THEN @InfoHighlight
            END AS [@bgcolor], 
            [Servername], 
            CONVERT(VARCHAR(24), [EventTime], 113) AS [EventTime], 
            [SystemCPUUtilization], 
            [SQLCPUUtilization], 
            [OtherCPU]
     FROM [CPUForFrequency]
     WHERE EXISTS
     (
         SELECT 1
         FROM [Consecutives]
         WHERE [ConsecutiveBucketID] = ([CPUForFrequency].[EventTimeOrderRN]
                                        - [CPUForFrequency].[EventTimeOrderByThreshold])
               AND [TotalConsecutives] >= @CPUBreachedConsecutiveCount
               AND [SystemCPUUtilization] > @CPUThresholdInfoHighlight
     );'',
	 N''@Frequency INT,
	 @Servername NVARCHAR(128),
	 @MonitorHourStart INT,
	 @MonitorHourEnd INT,
	 @CPUThresholdWarningHighlight INT,
	 @CPUThresholdAdvisoryHighlight INT,
	 @CPUThresholdInfoHighlight INT,
	 @WarningHighlight VARCHAR(7),
	 @AdvisoryHighlight VARCHAR(7),
	 @InfoHighlight VARCHAR(7),
	 @CPUBreachedConsecutiveCount INT'',
	 @Frequency = @Frequency,
	 @Servername = @Servername,
	 @MonitorHourStart = @MonitorHourStart,
	 @MonitorHourEnd = @MonitorHourEnd,
	 @CPUThresholdWarningHighlight = @CPUThresholdWarningHighlight,
	 @CPUThresholdAdvisoryHighlight = @CPUThresholdAdvisoryHighlight,
	 @CPUThresholdInfoHighlight = @CPUThresholdInfoHighlight,
	 @WarningHighlight = @WarningHighlight,
	 @AdvisoryHighlight = @AdvisoryHighlight,
	 @InfoHighlight = @InfoHighlight,
	 @CPUBreachedConsecutiveCount = @CPUBreachedConsecutiveCount;
END

/********************************************************/

	SET @Columnnames = (
	SELECT 
	STUFF(Columnnames,1,1,'''') 
	FROM
	(
		SELECT '',''+name
		FROM tempdb.sys.all_columns
		WHERE [object_id] = OBJECT_ID(N''tempdb.dbo.#InspectorModuleReport'')
		AND name != N''@bgcolor''
		ORDER BY column_id ASC
		FOR XML PATH('''')
	) as g (Columnnames)
	);

	--Set columns names for the Html table
	SET @HtmlTableHead = (SELECT [Inspector].[GenerateHtmlTableheader] (
	@Servername,
	@Modulename,
	@ServerSpecific,
	''CPU greater than ''
	+CAST(@CPUThresholdInfoHighlight AS VARCHAR(3))
	+''% in the last ''
	+CAST(@Frequency AS VARCHAR(10))
	+''mins between the hours of ''
	+CAST(@MonitorHourStart AS VARCHAR(10))
	+'' and ''
	+CAST(@MonitorHourEnd AS VARCHAR(10))
	+ISNULL('' with consecutive breaches of ''+CAST(@CPUBreachedConsecutiveCount AS VARCHAR(10))+'' or more'',''''), --Title for the HTML table, you can use a string here instead such as ''My table title here'' if you want to
	@TableHeaderColour,
	@Columnnames)
	);


	SET @SQLtext = N''
	SELECT @HtmlOutput =
	(SELECT ''
	+''[@bgcolor],''
	+REPLACE(@Columnnames,'','','' AS ''''td'''','''''''',+ '') + '' AS ''''td'''','''''''''' 
	+'' FROM #InspectorModuleReport
	FOR XML PATH(''''tr''''),Elements);''
	--Add an ORDER BY if required

	EXEC sp_executesql @SQLtext,N''@HtmlOutput VARCHAR(MAX) OUTPUT'',@HtmlOutput = @HtmlOutput OUTPUT;

	--Optional
	--If in the above query you populate the table with something like ''No issues present'' then you probably do not want that to 
	--show when @Noclutter mode is on
	IF (@NoClutter = 1)
	BEGIN 
		IF(@HtmlOutput LIKE ''%<Your No issues present text here>%'')
		BEGIN
			SET @HtmlOutput = NULL;
		END
	END

	--If there is data for the HTML table then build the HTML table
	IF (@HtmlOutput IS NOT NULL)
	BEGIN 
		SET @HtmlOutput = 
			@HtmlTableHead
			+ @HtmlOutput
			+ @TableTail
			+''<p><BR><p>'';
	END


IF (@Debug = 1)
BEGIN 
	SELECT 
	OBJECT_NAME(@@PROCID) AS ''Procname'',
	@Servername AS ''@Servername'',
	@Modulename AS ''@Modulename'',
	@TableHeaderColour AS ''@TableHeaderColour'',
	@WarningHighlight AS ''@WarningHighlight'',
	@AdvisoryHighlight AS ''@AdvisoryHighlight'',
	@InfoHighlight AS ''@InfoHighlight'',
	@CPUThresholdWarningHighlight AS ''CPUThresholdWarningHighlight'',
	@CPUThresholdAdvisoryHighlight AS ''CPUThresholdAdvisoryHighlight'',
	@CPUThresholdInfoHighlight AS ''CPUThresholdInfoHighlight'',
	@CPUBreachedConsecutiveCount AS ''CPUBreachedConsecutiveCount'',
	@ModuleConfig AS ''@ModuleConfig'',
	@WarningLevel AS ''@WarningLevel'',
	@NoClutter AS ''@NoClutter'',
	@TableTail AS ''@TableTail'',
	@HtmlOutput AS ''@HtmlOutput'',
	@HtmlTableHead AS ''@HtmlTableHead'',
	@SQLtext AS ''@SQLtext'',
	@CollectionOutOfDate AS ''@CollectionOutOfDate'',
	@PSCollection AS ''@PSCollection''
END 

END')
END



IF NOT EXISTS(SELECT 1 FROM [Inspector].[Modules] WHERE [Modulename] = 'CPU')
BEGIN 
	INSERT INTO [Inspector].[Modules] ([ModuleConfig_Desc], [Modulename], [CollectionProcedurename], [ReportProcedurename], [ReportOrder], [WarningLevel], [ServerSpecific], [Debug], [IsActive], [HeaderText], [Frequency], [StartTime], [EndTime])
	VALUES('Default','CPU','CPUInsert','CPUReport',5,2,1,0,1,'CPU has exceeded your threshold',15,'00:00','23:59');
END

--Update PS Config centralisation stage information
UPDATE [Inspector].[PSConfig]
SET [StageTablename] = N'PSCPUStage',
[StageProcname] = N'PSGetCPUStage',
[TableAction] = '3',
[InsertAction] = '3',
[RetentionInDays] = (SELECT ISNULL([Value],5) FROM [Inspector].[Settings] WHERE [Description] = 'CPUHistoryRetentionInDays')
WHERE [Modulename] = 'CPU';


IF NOT EXISTS(SELECT 1 FROM [Inspector].[MultiWarningModules] WHERE [Modulename] IN ('CPU'))
BEGIN 
	INSERT INTO [Inspector].[MultiWarningModules] ([Modulename])
	VALUES('CPU');
END


IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID(N'Inspector.InspectorUpgradeHistory') AND name = 'RevisionDate')
BEGIN 
	ALTER TABLE [Inspector].[InspectorUpgradeHistory] ADD RevisionDate DATE NULL;
END

EXEC sp_executesql N'
INSERT INTO [Inspector].[InspectorUpgradeHistory] ([Log_Date], [PreserveData], [CurrentBuild], [TargetBuild], [SetupCommand], [RevisionDate])
VALUES(GETDATE(),1,@InspectorBuild,@InspectorBuild,''Inspector_CPU_CustomModule.sql'',@Revisiondate);',
N'@InspectorBuild DECIMAL(4,2),
@Revisiondate DATE',
@InspectorBuild = @InspectorBuild,
@Revisiondate = @Revisiondate;


IF (@@ERROR = 0)
BEGIN 
	IF EXISTS(SELECT 1 FROM sys.tables WHERE name = 'CPUConfig' AND schema_id = SCHEMA_ID('Inspector'))
	BEGIN 
		EXEC sp_executesql N'DROP TABLE [Inspector].[CPUConfig];';
	END
END 
	
END
ELSE 
BEGIN 
	RAISERROR('Inspector schema not found, ensure that the Inspector is installed then try running this script again',11,0);
END

GO