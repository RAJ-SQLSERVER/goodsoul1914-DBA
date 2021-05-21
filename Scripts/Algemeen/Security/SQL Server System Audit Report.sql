/***********************************************************************************************************************************
[S]QL Server [A]nalysis and [S]ecurity [A]udit [T]ool (SASAT) 
Created by Rudy Panigas
SQL Server 2012, 2014 and higher

This script will analyze the SQL Server setting and produce a report on the findings
The report shows the summary of the server's information, analyzes of possible dangerous setting and 
analyzes the security configuration. If security issues are found, explanation(s) and recommendation(s) 
are show and how to made the change(s) with either SSMS or T-SQL script(s). This script works on SQL 2012 and higher.

***********************************************************************************************************************************
    *    
  *   *	  Disclaimer ** Use this script at your own risk. The author does not take any responsibilities for correctness of report. 
 *  !  *                All findings should be reviewed with production DBAs, auditors and Microsoft support. **  
*       *
*********
************************************************************************************************************************************

Apr 10, 2015 - Version 1.0 - 1.9  -Initial build
Apr 16, 2015 - Version 2.0 - 2.3  -Testing and correcting errors 
Apr 20, 2015 - Version 2.4  -Added server inventory output and audit analysis
Apr 20, 2015 - Version 2.5  -Added remediation scripts
Apr 21, 2015 - Version 2.6  -Added totals and percentage passed 
Apr 21, 2015 - Version 2.7  -Removed testing section
May 15, 2015 - Version 2.8  -Added check for xp_fixeddrives and Trace Flag detection
May 28, 2015 - Version 2.9  -Change some wording and web link verification
May 29, 2015 - Version 3.0  -Tweaked the output of results. Change name to SASAT (Server Analysis and Security Audit Tool)
Jun 01, 2015 - Version 3.1  -Change incorrect logic with default trace file detection. 
                            -Tested the script on SQL 2005, 2008, 2008R2, 2012 and 2014 with no issues 
				            -Added audit for login authentication
Jun 12, 2015 - Version 3.2  -Removed the need to change the sp_configure 'show advanced options'
				            -Added audit for 'sa' account 
Jun 15, 2015 - Version 3.3  -Changed output format for better viewing
Aug 20, 2015 - Version 3.4  -Changed output results format for better viewing. Tested all HTTP links
Aug 21, 2015 - Version 3.5  -Added detection of SysAdmin Members and ServerAdmin Members
Aug 24, 2015 - Version 3.6  -Changes to output of numbered steps. Added display for sp_configure with effect of changes
Aug 27, 2015 - Version 3.7  -Changed output format for better viewing
Sep 02, 2015 - Version 3.8  -Added detection of Instance and provide steps for manual analysis 
Sep 03, 2015 - Version 3.9  -Removed the need to display of sp_configure at end of report. Code commented out 
                            -Changed output for sys and Server Admin display
Sep 04, 2015 - Version 4.0  -Added detection of SQL installation on physical or virtual server
Sep 15, 2015 - Version 4.1  -Correct port number detection for NULL value. Added IP detection 
Sep 15, 2015 - Version 4.2  -Changed detection of Name Pipe or TCP connection
Sep 16, 2015 - Version 4.3  -Updated URL links
Sep 17, 2015 - Version 4.4  -Changed output for Trace Flag information. Fixed detection of xp_cmdshell
Sep 21, 2015 - Version 4.5  -Changed output for better reading of results
Oct 13, 2015 - Version 4.6  -Changed output for better reading of results, again
Oct 28, 2015 - Version 4.7  -Added display of total memory of server
Jan 06, 2016 - Version 4.8  -Added detection of Trustworthy setting on databases
Jan 08, 2016 - Version 4.9  -Provide list of section that have failed the analyzes/audit
Jan 22, 2016 - Version 5.0  -Added additional checks which brings the total checks to 40
							-set Auto_Close Off on contained databases 
							-Revoke CONNECT permissions on the Guest user 
							-Drop Orphaned User form databases 
							-SQL Authentication in contained databases 
							-Set the 'CHECK_EXPIRATION' Option to ON for All SQL Authenticated Logins Within the Sysadmin Role 
							-Set the 'CHECK_POLICY' Option to ON for All SQL Authenticated Logins 
							-Set the 'CLR Assembly Permission Set' to SAFE_ACCESS for All CLR Assemblies
							-Updated links to point to Microsoft sites for SQL 2014 and 2012. All links working as of this date 
							-Added additional comments on hidden instances
							-Provide list of stored procedure that can auto execute on SQL Server start up
Jan 27, 2016 - Version 5.1  -Cleaned up some more of the output
							-Change the detection of version numbers for SQL 2016 and 2018 ** Not fully confirmed from MS as only 2016 CTP is out
Feb 17, 2016 - Version 5.2	-Add reference for Database Mail. Corrected grimmer  
Oct 03, 2016 - Version 5.3	-Correct insert error that effects some systems
Feb 07, 2017 - Version 5.4	-Changes to output for better cut and paste into report
Aug 09, 2017 - Version 5.5	-Added script that will change the audit settings to both Failed/Successful logins
Aug 30, 2017 - Version 5.6  -Tested the script on SQL 2016 with no issues
Feb 01, 2018 - Version 5.7  -Changes to correctly detect SQL Server 2017
----------------------- Version Control -------------------------------
***********************************************************************************************************************************/

SET NOCOUNT ON;
USE master;


DECLARE @UpdatedDate VARCHAR(30);
SET @UpdatedDate = 'Feb 01, 2018 - Version 5.7';

-- Pre Cleanup, if temp tables exist

IF OBJECT_ID('tempdb..#AutoStart') IS NOT NULL
BEGIN
    DROP TABLE #AutoStart;
END;

IF OBJECT_ID('tempdb..#OrphanUserLIst') IS NOT NULL
BEGIN
    DROP TABLE #OrphanUserLIst;
END;

IF OBJECT_ID('tempdb..#SQLAuthCD') IS NOT NULL
BEGIN
    DROP TABLE #SQLAuthCD;
END;

IF OBJECT_ID('tempdb..#CLRAssemblyPermission') IS NOT NULL
BEGIN
    DROP TABLE #CLRAssemblyPermission;
END;

IF OBJECT_ID('tempdb..#CHECK_POLICY') IS NOT NULL
BEGIN
    DROP TABLE #CHECK_POLICY;
END;

IF OBJECT_ID('tempdb..#CHECK_EXPIRATION') IS NOT NULL
BEGIN
    DROP TABLE #CHECK_EXPIRATION;
END;

IF OBJECT_ID('tempdb..#CONNECTRevokeGuest') IS NOT NULL
BEGIN
    DROP TABLE #CONNECTRevokeGuest;
END;

IF OBJECT_ID('tempdb..#OrphanUers') IS NOT NULL
BEGIN
    DROP TABLE #OrphanUers;
END;

IF OBJECT_ID('tempdb..#TrustedDB') IS NOT NULL
BEGIN
    DROP TABLE #TrustedDB;
END;

IF OBJECT_ID('tempdb..#nodes') IS NOT NULL
BEGIN
    DROP TABLE #nodes;
END;

IF OBJECT_ID('tempdb..#KERBINFO') IS NOT NULL
BEGIN
    DROP TABLE #KERBINFO;
END;

IF OBJECT_ID('tempdb..#SysAdminAccount') IS NOT NULL
BEGIN
    DROP TABLE #SysAdminAccount;
END;

IF OBJECT_ID('tempdb..#SrvAdmin') IS NOT NULL
BEGIN
    DROP TABLE #SrvAdmin;
END;

IF OBJECT_ID('tempdb..#SQL_Server_Settings') IS NOT NULL
BEGIN
    DROP TABLE #SQL_Server_Settings;
END;

IF OBJECT_ID('tempdb..#TraceStats') IS NOT NULL
BEGIN
    DROP TABLE #TraceStats;
END;

IF OBJECT_ID('tempdb..#SASATFailed') IS NOT NULL
BEGIN
    DROP TABLE #SASATFailed;
END;


-------------------------------------------------------------------------
PRINT '';
PRINT ' 						SQL Server Analysis and Security Audit Tool (SASAT) ';
PRINT ' 						***************************************************';
PRINT ' 					Created by Rudy Panigas. Updated on ' + @UpdatedDate;
PRINT '';
PRINT 'This script will analyze/audit your SQL Server settings and report on the findings. The report shows the summary of SQL server''s information,';
PRINT 'analyze possible dangerous settings and analyzes the security configuration. If issues are detected then explanations, recommendations and how';
PRINT 'to make changes (either with SSMS or with T-SQL scripts) are shown.';
PRINT '';
PRINT '			The following (40) SQL Server settings are reviewed (SQL Server 2012 and higher versions)';
PRINT '';
PRINT '	TRUSTWORTHY Databases			Allow Remote Access				Cross DB Ownership Chaining		Max Worker Threads';
PRINT '	Priority Boost					Lightweight Pooling				Startup Stored Procedures		Affinity64 Mask';
PRINT '	Affinity I/O Mask				Affinity64 I/O Mask				CLR enabled						Database Mail XPs';
PRINT '	OLE Automation Procedures		Ad Hoc Distributed Queries		sa account						Remote Admin Connections';
PRINT '	Default Trace file				Default SQL Port Number			xp_dirtree						xp_fixeddrives';
PRINT '	xp_enumgroups					xp_servicecontrol				xp_subdirs						xp_regaddmultistring';
PRINT '	xp_regdeletekey					xp_regdeletevalue				xp_regenumvalues				xp_regremovemultistring';
PRINT '	xp_regwrite						xp_regwrite						Audit Level						xp_cmdshell';
PRINT '	Server Authentication			Auto_Close						Orphaned Users					CLR Assembly Permission';
PRINT '	CONNECT Permissions for Guest 	CHECK_POLICY SQL Authenticated	CHECK_EXPIRATION				SQL Authentication (Contained databases)';
PRINT '';
DECLARE @CurrentDate NVARCHAR(12),                    -- Current data/time 
        @SQLServerName NVARCHAR(50),                  --Set SQL Server Name 
        @NodeName1 NVARCHAR(50),                      -- Name of node 1 if clustered 
        @NodeName2 NVARCHAR(50),                      -- Name of node 2 if clustered 
        @NodeName3 NVARCHAR(50),

-------------------------------------------------------------------------------
 -- remove remarks if more than 2 node cluster 
-------------------------------------------------------------------------------

        @NodeName4 NVARCHAR(50),

-------------------------------------------------------------------------------
-- remove remarks if more than 2 node cluster 
-------------------------------------------------------------------------------

        @AccountName NVARCHAR(50),                    -- Account name used 
        @StaticPortNumber NVARCHAR(50),               -- Static port number 
        @INSTANCENAME NVARCHAR(30),                   -- SQL Server Instance Name 
        @VALUENAME NVARCHAR(20),                      -- Detect account used in SQL 2005, see notes below 
        @KERB NVARCHAR(50),                           -- Is Kerberos used or not 
        @DomainName NVARCHAR(50),                     -- Name of Domain 
        @IP NVARCHAR(20),                             -- IP address used by SQL Server 
        @InstallDate NVARCHAR(20),                    -- Installation date of SQL Server 
        @ProductVersion NVARCHAR(30),                 -- Production version 
        @MachineName NVARCHAR(30),                    -- Server name 
        @ServerName NVARCHAR(30),                     -- SQL Server name 
        @EDITION NVARCHAR(30),                        --SQL Server Edition 
        @ProductLevel NVARCHAR(20),                   -- Product level 
        @ISClustered NVARCHAR(20),                    -- System clustered 
        @ISIntegratedSecurityOnly NVARCHAR(50),       -- Security level 
        @ISSingleUser NVARCHAR(20),                   -- System in Single User mode 
        @COLLATION NVARCHAR(30),                      -- Collation type 
        @physical_CPU_Count VARCHAR(4),               -- CPU count 
        @EnvironmentType VARCHAR(15),                 -- Physical or Virtual 
        @MachineType INT,                             -- Server type  
        @MaxMemory NVARCHAR(10),                      -- Max memory 
        @MinMemory NVARCHAR(10),                      -- Min memory 
        @TotalMEMORYinBytes NVARCHAR(10),             -- Total memory 
        @TotalMEMORYinMegaBytes NVARCHAR(10),         -- Converted value of physical server memory in megabytes 
        @ErrorLogLocation VARCHAR(500),               -- location of error logs 
        @TraceFileLocation VARCHAR(100),              -- location of trace files 
        @LinkServers VARCHAR(2),                      -- Number of linked servers found 
        @FileStreams VARCHAR(2),                      -- Is FileStreams enabled 
        @BackUpCompression VARCHAR(2),                -- Is backup compression enabled 
        @TestResultCounter NUMERIC(3, 0),             -- tracks total tests passed and is used in final reporting section 
        @ResultsPercentage NUMERIC(3, 0),             -- Results as percentage passed 
        @TotalAutomatedTests NUMERIC(3, 0),           --Total automated test 
        @DefaultTraceEnabled VARCHAR(2),              -- Is default trace enabled 
        @xp_cmdshellEnabled VARCHAR(2),               -- Is command shell enabled 
        @RemoteAdminConnections VARCHAR(2),           -- is remote admin connection enabled 
        @xp_dirtreeEnabled NVARCHAR(10),              -- is xp_dirtree enabled 
        @xp_fixeddrivesEnabled NVARCHAR(10),          -- is xp_emumgroups enabled 
        @xp_enumgroupsEnabled NVARCHAR(10),           -- is xp_emumgroups enabled 
        @xp_servicecontrolEnabled NVARCHAR(10),       -- is xp_servicecontrol enabled 
        @xp_subdirsEnabled NVARCHAR(10),              -- is xp_subdirs enabled 
        @xp_regaddmultistringEnabled NVARCHAR(10),    -- is xp_readdmultistring enabled 
        @xp_regdeletekeyEnabled NVARCHAR(10),         -- is xp_regdeletekey enabled 
        @xp_regdeletevalueEnabled NVARCHAR(10),       -- is xp_regdeletevalue enabled 
        @xp_regenumvaluesEnabled NVARCHAR(10),        -- is xp_regnumvalues enabled 
        @xp_regremovemultistringEnabled NVARCHAR(10), -- is xp_regremovemultistring enabled  
        @xp_regwriteEnabled NVARCHAR(10),             -- is xp_regwrite enabled 
        @xp_regreadEnabled NVARCHAR(10),              -- is xp_regread enabled  
        @SADisabled NVARCHAR(15),                     -- is the 'sa' account enabled 
        @TRANSPORT NVARCHAR(20),                      -- Connection type 
        @AuditLevel INT,                              -- Connection audit levels 
        @AuditLvltxt VARCHAR(50);                     -- Connection audit levels description

SET @TestResultCounter = 0; -- setting result counter to zero
SET @ResultsPercentage = 0; -- setting percentage counter to zero
SET @TotalAutomatedTests = 40; -- setting total number of automated tests

SET @CurrentDate =
(
    SELECT GETDATE()
);
SET @ServerName =
(
    SELECT @@SERVERNAME
);

CREATE TABLE #SASATFailed -- Record sections that have failed audit
(
    AuditName NVARCHAR(100)
);

PRINT 'Report generated for ''' + @ServerName + ''' SQL Server on ' + @CurrentDate;
PRINT '';
PRINT '******** SQL Server Summary ********';
PRINT '';
SET @SQLServerName =
(
    SELECT @@ServerName
);
PRINT '* Detected - SQL Server name\Instance name --> ' + @SQLServerName;

SET @InstallDate =
(
    SELECT createdate
    FROM sys.syslogins
    WHERE sid = 0x010100000000000512000000
);
PRINT '* Detected - Installation Date --> ' + @InstallDate;

SET @MachineName =
(
    SELECT CONVERT(CHAR(100), SERVERPROPERTY('MachineName'))
);
PRINT '* Detected - Machine Name --> ' + @MachineName;

SET @INSTANCENAME =
(
    SELECT CONVERT(CHAR(50), SERVERPROPERTY('InstanceName'))
);
IF @INSTANCENAME IS NULL
    SET @INSTANCENAME = 'Default Instance';
PRINT '* Detected - Instance Name --> ' + @INSTANCENAME;

SET @EDITION =
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('EDITION'))
);
PRINT '* Detected - Edition and BIT Level --> ' + @EDITION;

SET @ProductLevel =
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('ProductLevel'))
);
PRINT '* Detected - Production Service Pack Level --> ' + @ProductLevel;
SET @ProductVersion =
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('ProductVersion'))
);
PRINT '* Detected - Production Version --> ' + @ProductVersion;

IF @ProductVersion LIKE '6.5%'
BEGIN
    SET @ProductVersion = N'SQL Server 6.5';
    SET @MachineType = 6;
END;

IF @ProductVersion LIKE '7.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 7';
    SET @MachineType = 7;
END;

IF @ProductVersion LIKE '8.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2000';
    SET @MachineType = 8;
END;

IF @ProductVersion LIKE '9.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2005';
    SET @MachineType = 9;
END;

IF @ProductVersion LIKE '10.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2008';
    SET @MachineType = 10;
END;

IF @ProductVersion LIKE '10.50%'
BEGIN
    SET @ProductVersion = N'SQL Server 2008R2';
    SET @MachineType = 10;
END;

IF @ProductVersion LIKE '11.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2012';
    SET @MachineType = 11;
END;

IF @ProductVersion LIKE '12.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2014';
    SET @MachineType = 12;
END;

IF @ProductVersion LIKE '13.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2016';
    SET @MachineType = 13;
END;

IF @ProductVersion LIKE '14.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2017';
    SET @MachineType = 14;
END;

IF @ProductVersion LIKE '15.0%'
BEGIN
    SET @ProductVersion = N'SQL Server 2019';
    SET @MachineType = 15; -- for future use
END;

PRINT '* Detected - Production Name --> ' + @ProductVersion;

IF @MachineType >= 11
BEGIN
    IF
    (
        SELECT virtual_machine_type FROM sys.dm_os_sys_info
    ) = 1
        SET @EnvironmentType = 'Virtual';
    IF
    (
        SELECT virtual_machine_type FROM sys.dm_os_sys_info
    ) = 0
        SET @EnvironmentType = 'Physical';
    PRINT '* Detected - Environment Type --> ' + @EnvironmentType;
END;

SET @physical_CPU_Count =
(
    SELECT cpu_count FROM sys.dm_os_sys_info
);
PRINT '* Detected - Logical CPU Count --> ' + @physical_CPU_Count;

SET @TotalMEMORYinBytes = CONVERT(   NVARCHAR(10),
                          (
                              SELECT physical_memory_kb FROM sys.dm_os_sys_info
                          )
                                 );
SET @TotalMEMORYinMegaBytes = @TotalMEMORYinBytes / 1024;
PRINT '* Detected - Total Memory (Megabytes) --> ' + @TotalMEMORYinMegaBytes;

SET @MaxMemory = CONVERT(   NVARCHAR(10),
                 (
                     SELECT value FROM sys.configurations WHERE name LIKE 'max server memory%'
                 )
                        );
SET @MinMemory = CONVERT(   NVARCHAR(10),
                 (
                     SELECT value FROM sys.configurations WHERE name LIKE 'min server memory%'
                 )
                        );
PRINT '* Detected - Maximum Memory (Megabytes) --> ' + @MaxMemory;
PRINT '* Detected - Minimum Memory (Megabytes) --> ' + @MinMemory;

SET @IP =
(
    SELECT DEC.local_net_address
    FROM sys.dm_exec_connections AS DEC
    WHERE DEC.session_id = @@SPID
);

IF @IP IS NULL
BEGIN
    PRINT '* Detected - IP Address --> No connection with IP address made';
END;
ELSE
BEGIN
    PRINT '* Detected - IP Address --> ' + @IP;
    SET @StaticPortNumber =
    (
        SELECT local_tcp_port
        FROM sys.dm_exec_connections
        WHERE session_id = @@SPID
    );
    PRINT '* Detected - Port Number --> ' + @StaticPortNumber;
END;

SET @DomainName =
(
    SELECT DEFAULT_DOMAIN()
);
PRINT '* Detected - Default Domain Name --> ' + @DomainName;

-------------------------------------------------------------------------------
-- For Service Account Name - This line will work on SQL 2008R2 and higher only
-------------------------------------------------------------------------------

SET @AccountName =
(
    SELECT TOP 1 service_account FROM sys.dm_server_services
);
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE',
                                       @key = N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
                                       @value_name = N'ObjectName',
                                       @value = @AccountName OUTPUT;

-------------------------------------------------------------------------------
-- Use this section, instead of the above if your are scanning SQL Servers 2008 
-- and lower
-- EXECUTE  master.dbo.xp_instance_regread
--		@rootkey      = N'HKEY_LOCAL_MACHINE',
--		@key          = N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
--		@value_name   = N'ObjectName',
--		@value        = @AccountName OUTPUT
-------------------------------------------------------------------------------
PRINT '* Detected - Service Account name --> ' + @AccountName;

IF
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('ISClustered'))
) = 1
    SET @ISClustered = N'Clustered';
ELSE
    SET @ISClustered = N'Not Clustered';
PRINT '* Detected - Clustered Status --> ' + @ISClustered;

--cluster node names. Modify if there are more than 2 nodes in cluster
SELECT NodeName
INTO #nodes
FROM sys.dm_os_cluster_nodes;
IF @@rowcount = 0
BEGIN
    SET @NodeName1 = N'NONE'; -- NONE for no cluster
END;
ELSE
BEGIN
    SET @NodeName1 =
    (
        SELECT TOP 1 NodeName FROM #nodes
    );
    SET @NodeName2 =
    (
        SELECT NodeName FROM #nodes WHERE NodeName = @NodeName1
    );
-- Add code here if more that 2 node cluster
--SET @NodeName3 = (SELECT NodeName from #nodes where NodeName  @NodeName1 AND NodeName  @NodeName2)
--SET @NodeName4 = (SELECT NodeName from #nodes where NodeName  @NodeName1 AND NodeName  @NodeName2 AND NodeName  @NodeName3)
END;

IF @NodeName1 = 'NONE'
BEGIN
    PRINT '* Detected - Cluster --> SQL Server is not clustered';
END;
ELSE
BEGIN
    PRINT '* Detected - cluster node 1 --> ' + @NodeName1;
    PRINT '* Detected - cluster node 2 --> ' + @NodeName2;
-- --Add code here if more that 2 node cluster
--PRINT '* Detected - cluster node 3 --> '+@NodeName3
--PRINT '* Detected - cluster node 4 --> '+@NodeName4
END;

SELECT net_transport,
       auth_scheme
INTO #KERBINFO
FROM sys.dm_exec_connections
WHERE session_id = @@spid;
IF @@rowcount = 0
BEGIN
    SET @KERB = N'Kerberos not used in TCP network transport';
END;
ELSE
BEGIN
    SET @KERB = N'TCP is using Kerberos';
END;
PRINT '* Detected - Kerberos --> ' + @KERB;

IF
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('ISIntegratedSecurityOnly'))
) = 1
    SET @ISIntegratedSecurityOnly = N'Windows Authentication Security Mode';
ELSE
    SET @ISIntegratedSecurityOnly = N'SQL Authentication and Windows Authentication Mode ';
PRINT '* Detected - Security Mode --> ' + @ISIntegratedSecurityOnly;

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                    N'Software\Microsoft\MSSQLServer\MSSQLServer',
                                    N'AuditLevel',
                                    @AuditLevel OUTPUT;

SELECT @AuditLvltxt = CASE
                          WHEN @AuditLevel = 0 THEN
                              'None'
                          WHEN @AuditLevel = 1 THEN
                              'Successful logins only'
                          WHEN @AuditLevel = 2 THEN
                              'Failed logins only'
                          WHEN @AuditLevel = 3 THEN
                              'Both successful and failed logins'
                          ELSE
                              'Unknown'
                      END;
PRINT '* Detected - Audit Level --> ' + @AuditLvltxt;

IF
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('ISSingleUser'))
) = 1
    SET @ISSingleUser = N'Single User';
ELSE
    SET @ISSingleUser = N'Multi User';
PRINT '* Detected - User Mode --> ' + @ISSingleUser;

SET @FileStreams = CONVERT(   NVARCHAR(10),
                   (
                       SELECT value FROM sys.configurations WHERE name LIKE 'filestream access%'
                   )
                          );
IF
(
    SELECT @FileStreams
) = 1
    PRINT '* Detected - FileStreams --> Enabled';
ELSE
    PRINT '* Detected - FileStreams --> Disabled';

SET @BackUpCompression = CONVERT(   NVARCHAR(10),
                         (
                             SELECT value FROM sys.configurations WHERE name LIKE 'backup compression%'
                         )
                                );
IF
(
    SELECT @BackUpCompression
) = 1
    PRINT '* Detected - Backup Compression --> Enabled';
ELSE
    PRINT '* Detected - Backup Compression --> Disabled';

SET @COLLATION =
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('COLLATION'))
);
PRINT '* Detected - Collation Type --> ' + @COLLATION;

SET @ErrorLogLocation =
(
    SELECT REPLACE(CAST(SERVERPROPERTY('ErrorLogFileName') AS VARCHAR(500)), 'ERRORLOG', '')
);
PRINT '* Detected - SQL Server Errorlog Location --> ' + @ErrorLogLocation;

SET @DefaultTraceEnabled = CONVERT(   NVARCHAR(1),
                           (
                               SELECT value FROM sys.configurations WHERE name LIKE 'default trace%'
                           )
                                  );
IF
(
    SELECT @DefaultTraceEnabled
) = 1
    PRINT '* Detected - Default Trace File --> Enabled';
ELSE
    PRINT '* Detected - Default Trace File --> Disabled';

SET @TraceFileLocation =
(
    SELECT REPLACE(CONVERT(VARCHAR(100), SERVERPROPERTY('ErrorLogFileName')), '\ERRORLOG', '\log.trc')
);
PRINT '* Detected - SQL Server Default Trace Location --> ' + @TraceFileLocation;

CREATE TABLE #TraceStats
(
    TraceFlag INT,
    status INT,
    Global INT,
    [Session] INT
);

INSERT INTO #TraceStats
EXEC ('DBCC TRACESTATUS WITH NO_INFOMSGS');

IF
(
    SELECT COUNT(*) FROM #TraceStats
) = 0
BEGIN
    PRINT '* Detected - Trace Flags Setting -->  No Trace Flags settings detected';
END;
ELSE
BEGIN
    PRINT '* Detected - Trace Flags Setting --> Trace Flags Detected';

    DECLARE @TraceFlagValue NVARCHAR(10),
            @TraceFlagStatus NVARCHAR(10),
            @TraceFlagGlobal NVARCHAR(10),
            @TraceFlagSession NVARCHAR(10);

    DECLARE TraceFlagSet CURSOR LOCAL FAST_FORWARD FOR(
    SELECT TraceFlag,
           status,
           Global,
           [Session]
    FROM #TraceStats);

    OPEN TraceFlagSet;
    FETCH NEXT FROM TraceFlagSet
    INTO @TraceFlagValue,
         @TraceFlagStatus,
         @TraceFlagGlobal,
         @TraceFlagSession;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @TraceFlagGlobal = 0
        BEGIN
            SET @TraceFlagGlobal = N'No';
        END;
        ELSE
            SET @TraceFlagGlobal = N'Yes';
        IF @TraceFlagSession = 0
        BEGIN
            SET @TraceFlagSession = N'No';
        END;
        ELSE
            SET @TraceFlagSession = N'Yes';
        PRINT '								Using TraceFlag = ' + @TraceFlagValue;
        PRINT '											Status = ' + @TraceFlagStatus;
        PRINT '											Use Globally = ' + @TraceFlagGlobal;
        PRINT '											Used in Session = ' + @TraceFlagSession;
        FETCH NEXT FROM TraceFlagSet
        INTO @TraceFlagValue,
             @TraceFlagStatus,
             @TraceFlagGlobal,
             @TraceFlagSession;
    END;

    CLOSE TraceFlagSet;
    DEALLOCATE TraceFlagSet;

END;
SET @LinkServers =
(
    SELECT COUNT(*) FROM sys.servers WHERE is_linked = '1'
);
PRINT '* Detected - Number of Link Servers --> ' + @LinkServers;

PRINT '';
PRINT '* Detected - SysAdmin Members';
PRINT '  ----------------------------';
IF
(
    SELECT COUNT(*)
    FROM sys.server_principals
    WHERE IS_SRVROLEMEMBER('sysadmin', name) = 1
) = 0
BEGIN
    PRINT '';
    PRINT '** No Sysadmin Accounts Detected ** ';
END;
ELSE
BEGIN
    SELECT CONVERT(NVARCHAR(40), name) COLLATE DATABASE_DEFAULT AS 'SysAdmin'
    INTO #SysAdminAccount
    FROM sys.server_principals
    WHERE IS_SRVROLEMEMBER('sysadmin', name) = 1;

    DECLARE @AdminAccounts VARCHAR(50);

    DECLARE SysAccounts CURSOR LOCAL FAST_FORWARD FOR(
    SELECT SysAdmin
    FROM #SysAdminAccount);
    OPEN SysAccounts;
    FETCH NEXT FROM SysAccounts
    INTO @AdminAccounts;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'SysAdmin Account - ' + @AdminAccounts;
        FETCH NEXT FROM SysAccounts
        INTO @AdminAccounts;
    END;

    CLOSE SysAccounts;
    DEALLOCATE SysAccounts;
END;

IF
(
    SELECT is_disabled FROM sys.server_principals WHERE sid = 0x01
) = 0
BEGIN
    PRINT '	* Detected setting for ''sa'' account  --> Security Audit FAILED.  --> *** FAILED/WARNING. Possible Dangerous Setting --> Is set to ENABLE ***';
    PRINT '';
    PRINT '	Reason: Disabling this account reduces the risk of an attacker executing a brute\force attacks against SQL Server.';
    PRINT ' The sa account is generally known and has high permissions like sysadmin. It is bad security practice for';
    PRINT ' applications and/or scripts connect with the sa account. If this has been done, however,  disabling the account ';
    PRINT ' will prevent applications and/or scripts from functioning properly. In this case you must leave the account enable. ';
    PRINT ' It is recommend that other audit tools should be used to trace the usage/use of the ''sa'' account';
    PRINT '';
    PRINT '	Recommend changes:  Execute the following query to disable the ''sa'' account';
    PRINT '';
    PRINT ' 	ALTER LOGIN sa DISABLE; ';
    PRINT '';
    PRINT '	By default the ''sa'' login account is enabled. ';
    PRINT '';
    PRINT '	References the following site: https://msdn.microsoft.com/en-us/library/ms188786(v=sql.110).aspx';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'SA Account Enabled';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''sa'' account is DISABLED --> Possible Dangerous Setting - PASSED';
    PRINT '';
    SET @TestResultCounter = @TestResultCounter + 1;
END;

SET @RemoteAdminConnections = CONVERT(   NVARCHAR(10),
                              (
                                  SELECT value
                                  FROM sys.configurations
                                  WHERE name LIKE 'Remote admin connections%'
                              )
                                     );
IF
(
    SELECT @RemoteAdminConnections
) = 1
BEGIN
    PRINT '	* Detected setting for ''Remote Admin Connections'' = 0 --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''Remote Admin Connections'' = 0 --> Security Audit FAILED --> Change this setting back to default! ***';
    PRINT '';
    PRINT '	Reason: The Dedicated Admin Connection (DAC) is a feature that allows connections to have direct access to system ';
    PRINT ' tables which could be used to conduct malicious activities. This feature must be restricted for only local ';
    PRINT ' administrators to reduce the risk. ';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT ' 	EXECUTE sp_configure ''show advanced options'', 1; ';
    PRINT ' 	GO ';
    PRINT ' 	RECONFIGURE; ';
    PRINT ' 	GO ';
    PRINT ' 	EXECUTE sp_configure ''Remote admin connections'', 1; ';
    PRINT ' 	GO ';
    PRINT ' 	RECONFIGURE; ';
    PRINT ' 	GO ';
    PRINT ' 	EXECUTE sp_configure ''show advanced options'', 0; ';
    PRINT ' 	GO ';
    PRINT ' 	RECONFIGURE; ';
    PRINT ' 	GO ';
    PRINT '';
    PRINT '	Both value columns must show 1 on clustered installations. Default Value: 0 (disabled). This change will take effect immediately. ';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 1.	https://msdn.microsoft.com/en-us/library/ms190468(v=sql.120).aspx';
    PRINT ' 2.	https://msdn.microsoft.com/en-us/library/ms190468(v=sql.110).aspx';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Remote Admin Connections';
END;

SET @DefaultTraceEnabled = CONVERT(   NVARCHAR(1),
                           (
                               SELECT value FROM sys.configurations WHERE name LIKE 'default trace%'
                           )
                                  );
IF
(
    SELECT @DefaultTraceEnabled
) = 1
BEGIN
    PRINT '	* Detected setting for ''Default Trace File Enabled'' = 1 --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''Default Trace File Enabled'' = 0 --> Security Audit FAILED   Default Trace is set to 1  --> Change this setting back to default! ***';
    PRINT '';
    PRINT '	Reason: Default trace allows for the collection of valuable audit information and security-related activities on the server.';
    PRINT '	Default trace files provide audit logging of database activity including account activities, login privilege ';
    PRINT '	elevation and execution of DBCC commands. ';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT ' 	EXECUTE sp_configure ''show advanced options'', 1; ';
    PRINT ' 	GO ';
    PRINT ' 	RECONFIGURE; ';
    PRINT ' 	GO ';
    PRINT ' 	EXECUTE sp_configure ''Default trace enabled'', 1; ';
    PRINT ' 	GO ';
    PRINT ' 	RECONFIGURE; ';
    PRINT ' 	GO ';
    PRINT ' 	EXECUTE sp_configure ''show advanced options'', 0; ';
    PRINT ' 	GO ';
    PRINT ' 	RECONFIGURE; ';
    PRINT ' 	GO ';
    PRINT '';
    PRINT '	Both value columns must show 1.Default Value: 1 (on). This change will take effect immediately. ';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 1.	https://msdn.microsoft.com/en-us/library/ms175513(v=sql.120).aspx';
    PRINT ' 2.	https://msdn.microsoft.com/en-us/library/ms175513(v=sql.110).aspx';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Default Trace File Enabled';
END;

SET @TRANSPORT =
(
    SELECT net_transport
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID
);

IF @TRANSPORT = 'Named pipe'
BEGIN
    PRINT '	* Detected setting for ''Default SQL Port Number'' --> Connection made with ' + @TRANSPORT
          + '. Manually check default port number if TCP/IP is enable';
    PRINT '';
END;
ELSE
BEGIN
    IF @StaticPortNumber = '1433'
    BEGIN
        PRINT '	* Detected setting for ''Default SQL Port Number'' --> Security Audit FAILED. Default SQL Port Number is set to '
              + @StaticPortNumber + ' --> Change setting! ***';
        PRINT '';
        PRINT '	Reason: Using a non-default port helps protect SQL Server from attacks directed to the default port. ';
        PRINT ' Changing the default port will force DAC (Default Administrator Connection) to listen on a random port. Also, firewall';
        PRINT ' will require configuration changes. Default SQL Server instance are assigned port of TCP: 1433 for TCP/IP communication.';
        PRINT ' Since TCP: 1433 is a widely known for SQL Server port, the port number should be changed. ';
        PRINT ' By default, SQL Server instances listen on TCP port 1433 and named instances uses dynamic ports.';
        PRINT '';
        PRINT '	References: ';
        PRINT ' 1.	https://msdn.microsoft.com/en-us/library/ms177440(v=sql.120).aspx';
        PRINT ' 2.	https://msdn.microsoft.com/en-us/library/ms177440(v=sql.110).aspx';
        PRINT '';
        INSERT INTO #SASATFailed
        SELECT 'Default Port Number';
    END;
    ELSE
    BEGIN
        PRINT '	* Detected setting for ''Default SQL Port Number'' --> ' + @StaticPortNumber
              + ' --> Security Audit PASSED';
        PRINT '';
        SET @TestResultCounter = @TestResultCounter + 1;
    END;
END;

SET @xp_dirtreeEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_dirtree')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_dirtreeEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_dirtree''  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Ensuring this procedure is disabled will prevent an attacker from performing directory enumeration and';
    PRINT ' listing files and folders to read or write data to / from. This procedure is currently leveraged by ';
    PRINT ' several automated SQL Injection tools. 	Any record returned is an indicator that the public role ';
    PRINT ' maintains execute permission on the procedure. Results returns a set of the directory tree for ';
    PRINT ' a given directory path. ';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT '	The following steps can be performed using SQL Server Management Studio: ';
    PRINT '';
    PRINT '  			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT '  			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT '  			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT '  			2.	Locate xp_dirtree, right click and select Properties ';
    PRINT '';
    PRINT '  			3.	Select the Permissions tab ';
    PRINT '';
    PRINT '  			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the ';
    PRINT '  			recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission';
    PRINT ' 			on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT ' 	Or you can execute the following to revoke use by all general users on the SQL Server machine: ';
    PRINT '';
    PRINT ' 	REVOKE EXECUTE ON xp_dirtree TO PUBLIC;';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_dirtree Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_dirtree'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_fixeddrivesEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_fixeddrives')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_fixeddrivesEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_fixeddrives'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: When disabled, will prevent an attacker from viewing local available drives for ';
    PRINT ' directory and / or file enumeration. Any record returned indicates the public role maintains ';
    PRINT ' execute permission on the procedure. A list of all hard drives on the machine and the space';
    PRINT ' free in megabytes for each drive are shown. ';
    PRINT '';
    PRINT ' 	Recommended changes: Revoke use by all general users on the SQL Server machine:';
    PRINT '';
    PRINT ' 	REVOKE EXECUTE ON xp_fixeddrives TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_fixdrdrives Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_fixeddrives'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_enumgroupsEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_enumgroups')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_enumgroupsEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_enumgroups'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling this procedure will limit the ability to view Windows groups present on the';
    PRINT ' SQL Server machine. Currently being used by automated SQL Injection tools. ';
    PRINT ' Any record returned indicates the public role maintains execute permission on the procedure.';
    PRINT ' This procedure can provide a list of local Microsoft Windows groups and / or a list of global groups';
    PRINT ' that are defined in a specified Windows machine. ';
    PRINT '';
    PRINT ' 			The following steps can be performed by using SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT ' 			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT ' 			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT ' 			2.	Locate xp_enumgroups, right click and select Properties ';
    PRINT '';
    PRINT ' 			3.	Select the Permissions tab ';
    PRINT '';
    PRINT ' 			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the ';
    PRINT ' 			recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission on the ';
    PRINT ' 			procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke use by all general users on the SQL Server machine: ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_enumgroups Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_enumgroups'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_servicecontrolEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_servicecontrol')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_servicecontrolEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_servicecontrol'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Can be used remotely by an attacker to shutdown Windows services used by Antivirus products and / or firewalls';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure.';
    PRINT '	Can be used to start and / or stop windows services and SQL related services running on the SQL Server machine. ';
    PRINT '';
    PRINT ' 			The following steps can be used by using SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT ' 			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT ' 			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT ' 			2.	Locate xp_servicecontrol, right click and select Properties ';
    PRINT '';
    PRINT ' 			3.	Select the Permissions tab ';
    PRINT '';
    PRINT ' 			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the recommendation and ';
    PRINT ' 			you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission on the procedure';
    PRINT ' 			and the listed remediation procedure should be followed.';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT ' 	REVOKE EXECUTE ON xp_servicecontrol TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure ';
    PRINT '	By default, the public role is given execute permissions to this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_servicecontrol Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_servicecontrol'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_subdirsEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_subdirs')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_subdirsEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_subdirs'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disable to prevent an attacker from performing directory enumeration, ';
    PRINT '	listing all subdirectories on the file system. The attacker could use this information to ';
    PRINT '	determine where key OS and SQL Server files are located. Shows all subdirectories';
    PRINT '	with in a given folder or path. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure.';
    PRINT '';
    PRINT '	The following steps can be used by using SQL Server Management Studio: ';
    PRINT '';
    PRINT '			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT '			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT '			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT '			2.	Locate xp_subdirs, right click and select Properties ';
    PRINT '';
    PRINT '			3.	Select the Permissions tab ';
    PRINT '';
    PRINT '			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the';
    PRINT '			 recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT '			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT '			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission on the ';
    PRINT '			procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke use by all general users on the SQL Server machine: ';
    PRINT '';
    PRINT ' 	REVOKE EXECUTE ON xp_subdirs TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure. ';
    PRINT '	By default, the public role is not given execute permissions to this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_subdirs Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_subdirs'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regaddmultistringEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regaddmultistring')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regaddmultistringEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regaddmultistring'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '';
    PRINT '	Reason: Disabling this feature will prevent a SQL Server users from writing to the Windows registry through SQL Server. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure. ';
    PRINT '	Adds multiple strings to the server''s registry. ';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT '			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT '			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT '			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT '			2.	Locate xp_regaddmdmultistring, right click and select Properties ';
    PRINT '';
    PRINT '			3.	Select the Permissions tab ';
    PRINT '';
    PRINT '			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the ';
    PRINT '			recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT '			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT '			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission on the ';
    PRINT '			procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke the use by all general users on the SQL Server:';
    PRINT '';
    PRINT ' 	REVOKE EXECUTE ON xp_regaddmultistring TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regaddmultistring Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regaddmultistring'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regdeletekeyEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regdeletekey')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regdeletekeyEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regdeletekey'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling this feature will prevent a SQL Server users from deleting values from the Windows registry through SQL Server. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure. ';
    PRINT '	Ability to delete registry keys from the server''s registry.';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT ' 			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT ' 			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT ' 			2.	Locate xp_regdeletekey, right click and select Properties ';
    PRINT '';
    PRINT ' 			3.	Select the Permissions tab ';
    PRINT '';
    PRINT ' 			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the  ';
    PRINT ' 			recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission';
    PRINT ' 			on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke use by all general users on the SQL Server machine: ';
    PRINT '';
    PRINT ' 	REVOKE EXECUTE ON xp_regdeletekey TO PUBLIC; ';
    PRINT '';
    PRINT '	Note: Logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regdeletekey Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regdeletekey'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regdeletevalueEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regdeletevalue')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regdeletevalueEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regdeletevalue'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling this feature will prevent a SQL Server users from deleting values from the Windows registry through SQL Server. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure ';
    PRINT '	Deletes values from the server''s registry.';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT '			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT '			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT '			2.	Locate xp_regdeletevalue, right click and select Properties ';
    PRINT '';
    PRINT '			3.	Select the Permissions tab ';
    PRINT '';
    PRINT '			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the';
    PRINT '			recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5';
    PRINT '';
    PRINT '			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT '			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission ';
    PRINT '			on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke the use by all general users on the SQL Server machine:  ';
    PRINT '';
    PRINT ' 				REVOKE EXECUTE ON xp_regdeletevalue TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regdeletevalue Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regdeletevalue'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regenumvaluesEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regenumvalues')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regenumvaluesEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regenumvalues'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling this feature will prevent a SQL Server user from enumerating and reading registry values. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure. ';
    PRINT '	Enumerates and reads registry values from a provided registry path. ';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT '			1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT '			Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT '			Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT '			2.	Locate xp_regenumvalues, right click and select Properties ';
    PRINT '';
    PRINT '			3.	Select the Permissions tab ';
    PRINT '';
    PRINT '			4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the ';
    PRINT '			recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT '			5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT '			6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission';
    PRINT '			   on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke use by all general users on the SQL Server machine: ';
    PRINT '';
    PRINT '				REVOKE EXECUTE ON xp_regenumvalues TO PUBLIC; ';
    PRINT '';
    PRINT '	Note: Logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regenumvalues Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regenumvalues'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regremovemultistringEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regremovemultistring')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regremovemultistringEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regremovemultistring'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling will prevent a SQL Server users from deleting batch values from the Windows registry via SQL Server. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure. ';
    PRINT '	Removes multiple strings from the server''s registry. ';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT ' Databases\System Databases\master\Programmability\Extended Stored Procedures';
    PRINT ' \System Extended Stored Procedures ';
    PRINT '';
    PRINT ' 2.	Locate xp_regremovemultistring, right click and select Properties ';
    PRINT '';
    PRINT ' 3.	Select the Permissions tab ';
    PRINT '';
    PRINT ' 4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the ';
    PRINT ' recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute permission ';
    PRINT ' on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke the use by all general users on the SQL Server ';
    PRINT '';
    PRINT '				REVOKE EXECUTE ON xp_regremovemultistring TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regremovemultistring Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regremovemultistring'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regwriteEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regwrite')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regwriteEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regwrite'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling will prevent a SQL Server users from writing to the Windows registry via SQL Server. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure. ';
    PRINT '	Description: Writes key values to the server''s registry. ';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT ' Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT ' Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT ' 2.	Locate xp_regwrite, right click and select Properties ';
    PRINT '';
    PRINT ' 3.	Select the Permissions tab ';
    PRINT '';
    PRINT ' 4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with ';
    PRINT ' the recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute ';
    PRINT ' permission on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke use by all general users on the SQL Server machine: ';
    PRINT '';
    PRINT '				REVOKE EXECUTE ON xp_regwrite TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regwrite Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regwrite'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SET @xp_regreadEnabled =
(
    SELECT 'PUBLIC'
    FROM sys.database_permissions
    WHERE major_id = OBJECT_ID('xp_regread')
          AND type = 'EX'
          AND grantee_principal_id = 0
);

IF @xp_regreadEnabled = 'PUBLIC'
BEGIN
    PRINT '	* Detected setting for ''xp_regread'' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Disabling this feature will prevent a SQL Server users from enumerating';
    PRINT '	and reading registry values. This procedure is used by several automated SQL injection tools. ';
    PRINT '	Any record returned indicates the public role maintains execute permission on the procedure. ';
    PRINT '	Description: Reads key values from the server''s registry. ';
    PRINT '';
    PRINT '	The following steps can be used with SQL Server Management Studio: ';
    PRINT '';
    PRINT ' 1.	In Object Explorer, navigate to the SQL Server instance and expand the path: ';
    PRINT '';
    PRINT ' Databases\System Databases\master\Programmability\Extended Stored ';
    PRINT ' Procedures\System Extended Stored Procedures ';
    PRINT '';
    PRINT ' 2.	Locate xp_regread, right click and select Properties ';
    PRINT '';
    PRINT ' 3.	Select the Permissions tab ';
    PRINT '';
    PRINT ' 4.	If the ''public'' entry does not exist within the Users or Roles listing the server is in compliance with the ';
    PRINT ' recommendation and you can halt further steps. If the ''public'' entry does exist proceed to step 5 ';
    PRINT '';
    PRINT ' 5.	Select the ''public'' entry within the Users or Roles listing ';
    PRINT '';
    PRINT ' 6.	If the Grant check box for the Execute permission is checked the Public role maintains Execute';
    PRINT ' permission on the procedure and the listed remediation procedure should be followed. ';
    PRINT '';
    PRINT '	Recommended changes: Revoke the use by all general users on the SQL Server: ';
    PRINT '';
    PRINT '				REVOKE EXECUTE ON xp_regread TO PUBLIC;  ';
    PRINT '';
    PRINT '	Note: Logins within the sysadmin role will retain use of this procedure. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'XP_regread Enabled for PUBLIC';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''xp_regwrite'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

SELECT @AuditLvltxt = CASE
                          WHEN @AuditLevel = 0 THEN
                              'None'
                          WHEN @AuditLevel = 1 THEN
                              'Successful logins only'
                          WHEN @AuditLevel = 2 THEN
                              'Failed logins only'
                          WHEN @AuditLevel = 3 THEN
                              'Both successful and failed logins'
                          ELSE
                              'Unknown'
                      END;

IF @AuditLevel = 3
BEGIN
    PRINT '	* Detected setting for ''Audit Level'' is set to: ' + @AuditLvltxt
          + ' --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Logging successful and failed logins provides key information that can be used to detect\confirm password ';
    PRINT ' guessing attacks. Further, logging successful login attempts can be used to confirm server access during forensic ';
    PRINT ' investigations. Set logs both successful and failed login SQL Server authentication attempts. ';
    PRINT '';
    PRINT '	Recommended changes: Perform the following steps to change the audit level:';
    PRINT '';
    PRINT ' 			1.	Open SQL Server Management Studio. ';
    PRINT ' 			2.	Right click the target instance and select Properties and navigate to the Security tab. ';
    PRINT ' 			3.	Select the option Both failed and successful logins under the "Login Auditing" section and click OK. ';
    PRINT ' 			4.	Restart the SQL Server instance.';
    PRINT '';
    PRINT '	Recommended changes: Made with script below';
    PRINT '';
    PRINT '			EXEC xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', ';
    PRINT '			N''Software\Microsoft\MSSQLServer\MSSQLServer'', ';
    PRINT '			N''AuditLevel'', REG_DWORD, 3 -- Failed & Successful';
    PRINT '			GO';
    PRINT '';
    PRINT '	By default, only failed login attempted are captured. ';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 1.	https://technet.microsoft.com/en-us/library/ms188470(v=sql.120).aspx ';
    PRINT ' 2.	https://technet.microsoft.com/en-us/library/ms188470(v=sql.110).aspx ';
    PRINT '';
    PRINT '	Note: A value of ''all''  indicates a server login auditing setting of ''Both failed and successful logins''. ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Audit Level Logging';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''Audit Level'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
END;

IF
(
    SELECT CONVERT(CHAR(30), SERVERPROPERTY('ISIntegratedSecurityOnly'))
) = 0
BEGIN
    SET @ISIntegratedSecurityOnly = N'SQL Authentication and Windows Authentication Mode ';
    PRINT '';
    PRINT '	* Detected setting for ''Server Authentication'' is set to ' + @ISIntegratedSecurityOnly
          + '  --> Security Audit FAILED --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Windows provides a better authentication mechanism than SQL Server authentication. ';
    PRINT ' A config value of Windows NT Authentication indicates the Server Authentication property is set to ';
    PRINT ' Windows Authentication mode. Use Windows Authentication to validate connections. ';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT ' 	Perform the following steps: ';
    PRINT ' 			1.	Open SQL Server Management Studio. ';
    PRINT ' 			2.	Open the Object Explorer tab and connect to the target database instance. ';
    PRINT ' 			3.	Right click the instance name and select Properties. ';
    PRINT ' 			4.	Select the Security page from the left menu. ';
    PRINT ' 			5.	Set the Server authentication setting to Windows Authentication mode. ';
    PRINT '';
    PRINT '	Default Value: Windows Authentication Mode ';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1.	https://msdn.microsoft.com/en-us/library/ms188470(v=sql.120).aspx ';
    PRINT ' 	2.	https://msdn.microsoft.com/en-us/library/ms188470(v=sql.110).aspx ';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Authentication Mode';
END;
ELSE
BEGIN
    SET @ISIntegratedSecurityOnly = N'Windows Authentication Security Mode';
    PRINT '';
    PRINT '	* Detected setting for ''Server Authentication'' is set to ' + @ISIntegratedSecurityOnly
          + ' --> Security Audit PASSED';
    PRINT '';
    SET @TestResultCounter = @TestResultCounter + 1;
END;

DECLARE @AutoClose VARCHAR(5);

SET @AutoClose =
(
    SELECT COUNT(*)
    FROM sys.databases
    WHERE containment = 0
          AND is_auto_close_on = 1
);

IF
(
    SELECT @AutoClose
) > 0
BEGIN
    PRINT '	* Detected setting for ''AUTO_CLOSE OFF''  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: The AUTO_CLOSE setting on contained databases determines if an given database is closed or open after a';
    PRINT ' connection(s) is terminated. If this setting is enabled, additional connection to the database will';
    PRINT ' require the database to be reopened and procedure caches will be rebuilt';
    PRINT ' Without this setting, Denial of Serice (DoS) could occur';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT '	The following can be executed to change the value of AUTO_CLOSE to OFF. Replace the  which database';
    PRINT '	in question.';
    PRINT '';
    PRINT ' 	ALTER DATABASE  SET AUTO_CLOSE OFF;';
    PRINT '';
    PRINT '	Note: Server logins within the sysadmin role will retain use of this procedure.	Default value is set to OFF ';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 1.	https://msdn.microsoft.com/en-us/library/ff929055(v=sql.120).aspx';
    PRINT ' 2.	https://msdn.microsoft.com/en-us/library/ff929055(v=sql.110).aspx';
    PRINT '';

    DECLARE @ContainName NVARCHAR(50);
    DECLARE ACOn CURSOR LOCAL FAST_FORWARD FOR(
    SELECT name
    FROM sys.databases
    WHERE containment = 0
          AND is_auto_close_on = 1);

    OPEN ACOn;
    FETCH NEXT FROM ACOn
    INTO @ContainName;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '			** Contained Database with Auto Close On: ' + @ContainName;
        FETCH NEXT FROM ACOn
        INTO @ContainName;
    END;
    CLOSE ACOn;
    DEALLOCATE ACOn;
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'AUTO_CLOSE OFF on Contained Database';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''AUTO_CLOSE ON on Contained Database'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

CREATE TABLE #CONNECTRevokeGuest
(
    DBName NVARCHAR(30),
    name NVARCHAR(30),
    permission_name NVARCHAR(30)
);

EXECUTE sp_MSforeachdb 'USE ?
IF DB_NAME() NOT IN(''master'',''tempdb'',''model'',''msdb'')
BEGIN
	SELECT DB_NAME() AS DBName, dpr.name, dpe.permission_name 
	INTO #CONNECTRevokeGuest 
	FROM sys.database_permissions dpe 
	JOIN sys.database_principals dpr 
	ON dpe.grantee_principal_id=dpr.principal_id 
	WHERE dpr.name=''guest'' 
	AND dpe.permission_name=''CONNECT'';
END';


IF
(
    SELECT COUNT(*) FROM #CONNECTRevokeGuest
) > 0
BEGIN
    PRINT '	* Detected setting for ''Revoke CONNECT permissions on the Guest user''  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: A login can assumes the identity of the guest user account. Revoking the connect permission';
    PRINT ' for the guest user will ensure that a login is not able to access database information without explicit access.';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT ' ';
    PRINT '	The following can be executed to revoke connect permissions on the Guest user in the database';
    PRINT '	Use this script for each database as needed. Change the [database name] to your database ';
    PRINT '';
    PRINT ' 	USE [database_name]; ';
    PRINT ' 	GO';
    PRINT ' 	REVOKE CONNECT FROM guest;';
    PRINT ' 	GO';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/bb402861(v=sql.120).aspx';
    PRINT ' 	2. https://msdn.microsoft.com/en-us/library/bb402861(v=sql.110).aspx';
    PRINT '';

    DECLARE @DBName1 NVARCHAR(30),
            @UserName1 NVARCHAR(30),
            @permission_name1 NVARCHAR(10);

    DECLARE RevokeGuest CURSOR LOCAL FAST_FORWARD FOR(
    SELECT DBName,
           name,
           permission_name
    FROM #CONNECTRevokeGuest);

    OPEN RevokeGuest;
    FETCH NEXT FROM RevokeGuest
    INTO @DBName1,
         @UserName1,
         @permission_name1;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '	** Check the following - Database Name: ' + @DBName1 + '		User Name: ' + @UserName1
              + '		Permission Granted: ' + @permission_name1;
        FETCH NEXT FROM RevokeGuest
        INTO @DBName1,
             @UserName1,
             @permission_name1;
    END;

    CLOSE RevokeGuest;
    DEALLOCATE RevokeGuest;

    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Revoke CONNECT permissions on the Guest user';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''Revoke CONNECT permissions on the Guest user'' --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

CREATE TABLE #OrphanUserLIst
(
    DBName NVARCHAR(50),
    name NVARCHAR(50)
);

EXECUTE sp_MSforeachdb 'USE ?
IF DB_NAME() NOT IN (''master'',''tempdb'',''model'',''msdb'')
BEGIN
	 INSERT INTO #OrphanUserLIst (DBName, name)
	 SELECT ''?''AS DBName,
	 users.name AS name
	 FROM master..syslogins logins 
	 RIGHT JOIN sysusers users 
	 ON logins.sid = users.sid 
	 WHERE logins.sid is null 
	 AND issqlrole  1 
	 AND isapprole  1   
	 AND users.name  ''INFORMATION_SCHEMA'' 
	 AND users.name  ''NT AUTHORITY\NETWORK SERVICE''
	 AND users.name NOT IN (''guest'', ''dbo'', ''sys'')
END';

IF
(
    SELECT COUNT(*) FROM #OrphanUserLIst
) > 0
BEGIN
    PRINT '	* Detected setting for Orphaned Users --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: A database user which exists in the database but not on SQL Server itself cannot log in to';
    PRINT ' the instance and is known as an orphaned account. This account should be removed.';
    PRINT ' Removing orphan account will minimize potential misuse.';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT ' ';
    PRINT '	The following can be used for the database in question to remove an orphan user(s) account. Replace ''database name'' with your';
    PRINT '	database name and the '''' with the orphan user account name.';
    PRINT '';
    PRINT ' 	USE [database_name]; ';
    PRINT ' 	GO';
    PRINT ' 	DROP USER ;';
    PRINT ' 	GO';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/ms175475(v=sql.120).aspx';
    PRINT ' 	2. https://msdn.microsoft.com/en-us/library/ms175475(v=sql.110).aspx';
    PRINT '';

    DECLARE @DBName2 NVARCHAR(50),
            @UserName2 NVARCHAR(30);

    DECLARE OrphanUsers CURSOR LOCAL FAST_FORWARD FOR(
    SELECT DBName,
           name
    FROM #OrphanUserLIst);

    OPEN OrphanUsers;
    FETCH NEXT FROM OrphanUsers
    INTO @DBName2,
         @UserName2;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '	** Check the following - Database Name: ' + @DBName2 + '		Orphan User Name: ' + @UserName2;
        FETCH NEXT FROM OrphanUsers
        INTO @DBName2,
             @UserName2;
    END;

    CLOSE OrphanUsers;
    DEALLOCATE OrphanUsers;
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Drop Orphan Users';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for Orphaned Users --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

CREATE TABLE #SQLAuthCD
(
    DBName NVARCHAR(50),
    name NVARCHAR(50),
    type_desc NVARCHAR(10),
    name2 NVARCHAR(50)
);

EXECUTE sp_MSforeachdb 'USE ?
IF DB_NAME() NOT IN (''master'',''tempdb'',''model'',''msdb'')
BEGIN
	INSERT INTO #SQLAuthCD (DBName, name, type_desc, name2) select 
	''?''AS DBName,
	sys.database_principals.[name],
	sys.database_principals.[type_desc], 
	sys.databases.[name] as Name2 
	from sys.database_principals, sys.databases
	WHERE 
	sys.database_principals.[name] NOT IN (''dbo'',''Information_Schema'',''sys'',''guest'',''##MS_PolicyEventProcessingLogin##'') 
	AND type IN (''U'',''S'',''G'') 
	AND sys.database_principals.[type_desc] = ''SQL_USER''
	AND sys.databases.containment  0
	AND ''?'' = sys.databases.[name]
END';

IF
(
    SELECT COUNT(*) FROM #SQLAuthCD
) > 0
BEGIN
    PRINT '	* Detected setting for SQL Authentication in Contained Databases  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Password complexity rules are not enforced in contained databases. Without an enforced password policy, there is an';
    PRINT ' increase in the likelihood of a weak credential being established in a contained database.';
    PRINT '';
    PRINT '	Recommended changes: Change the user account to use Windows Authentication';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/ff929055(v=sql.120).aspx';
    PRINT '';

    DECLARE @DBName3 NVARCHAR(30),
            @UserName3 NVARCHAR(30),
            @type_desc3 NVARCHAR(10);

    DECLARE SQLAuthContain CURSOR LOCAL FAST_FORWARD FOR(
    SELECT DBName,
           name,
           type_desc
    FROM #SQLAuthCD);

    OPEN SQLAuthContain;
    FETCH NEXT FROM SQLAuthContain
    INTO @DBName3,
         @UserName3,
         @type_desc3;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '	** Check the following - Database Name: ' + @DBName3 + '		User Name: ' + @UserName3
              + '		Type of Login: ' + @type_desc3;
        FETCH NEXT FROM SQLAuthContain
        INTO @DBName3,
             @UserName3,
             @type_desc3;
    END;

    CLOSE SQLAuthContain;
    DEALLOCATE SQLAuthContain;
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'SQL Authentication in Contained Databases';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for SQL Authentication in Contained Databases --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

CREATE TABLE #CHECK_EXPIRATION
(
    SQLLoginName NVARCHAR(50)
);

INSERT INTO #CHECK_EXPIRATION
SELECT SQLLoginName = sp.name
FROM sys.server_principals AS sp
    JOIN sys.sql_logins AS sl
        ON sl.principal_id = sp.principal_id
WHERE sp.type_desc = 'SQL_LOGIN'
      AND sp.name IN
          (
              SELECT name AS IsSysAdmin
              FROM sys.server_principals AS p
              WHERE IS_SRVROLEMEMBER('sysadmin', name) = 1
          )
      AND sl.is_expiration_checked = 1;

IF
(
    SELECT COUNT(*) FROM #CHECK_EXPIRATION
) > 0
BEGIN
    PRINT '	* Detected setting for ''CHECK_EXPIRATION'' Option to ON for All SQL Authenticated Logins Within the Sysadmin  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: Ensuring SQL logins comply with the secure password policy applied by the Windows Server Benchmark will ensure';
    PRINT ' the passwords for SQL logins with Sysadmin privileges are changed on a frequent basis to help prevent';
    PRINT ' compromise via a brute force attack.';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT ' ';
    PRINT '	The following can be executed to change the CHECK_EXPIRATION setting to ON';
    PRINT '';
    PRINT ' 	USE [MASTER]; ';
    PRINT ' 	GO';
    PRINT ' 	ALTER LOGIN [login_name] WITH CHECK_EXPIRATION = ON;';
    PRINT ' 	GO';
    PRINT '';
    PRINT '	Default Value: ON (enabled).';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/ms161959(v=sql.120).aspx';
    PRINT ' 	2. https://msdn.microsoft.com/en-us/library/ms161959(v=sql.110).aspx';
    PRINT '';

    DECLARE @UserName4 NVARCHAR(30);

    DECLARE CHECKEXPIRATION CURSOR LOCAL FAST_FORWARD FOR(
    SELECT SQLLoginName
    FROM #CHECK_EXPIRATION);

    OPEN CHECKEXPIRATION;
    FETCH NEXT FROM CHECKEXPIRATION
    INTO @UserName4;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '			** Check the following - User Name: ' + @UserName4;
        FETCH NEXT FROM CHECKEXPIRATION
        INTO @UserName4;
    END;

    CLOSE CHECKEXPIRATION;
    DEALLOCATE CHECKEXPIRATION;
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'CHECK_EXPIRATION SQL Authenticated Logins sysadmin';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''CHECK_EXPIRATION'' for All SQL Authenticated Logins Within the Sysadmin --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

CREATE TABLE #CHECK_POLICY
(
    SQLLoginName NVARCHAR(50),
    PasswordPolicyEnforced NVARCHAR(2)
);

INSERT INTO #CHECK_POLICY
SELECT SQLLoginName = sp.name,
       PasswordPolicyEnforced = CAST(sl.is_policy_checked AS BIT)
FROM sys.server_principals AS sp
    JOIN sys.sql_logins AS sl
        ON sl.principal_id = sp.principal_id
WHERE sp.type_desc = 'SQL_LOGIN'
      AND CAST(sl.is_policy_checked AS BIT) = 0;

IF
(
    SELECT COUNT(*) FROM #CHECK_POLICY
) > 0
BEGIN
    PRINT '	* Detected setting for ''CHECK_POLICY'' Option to ON for All SQL Authenticated Logins  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: By ensuring SQL logins comply with the secure password policy the SQL logins will not have blank passwords';
    PRINT ' and cannot be easily compromised from a brute force attack.';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT ' ';
    PRINT '	The following can be executed to change the CHECK_POLICY setting to ON';
    PRINT '';
    PRINT ' 	USE [MASTER]; ';
    PRINT ' 	GO';
    PRINT ' 	ALTER LOGIN [login_name] WITH CHECK_POLICY = ON;';
    PRINT ' 	GO';
    PRINT '';
    PRINT '	Default Value: ON (enabled).';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/ms161959(v=sql.120).aspx';
    PRINT ' 	2. https://msdn.microsoft.com/en-us/library/ms161959(v=sql.110).aspx';
    PRINT '';

    DECLARE @UserName5 NVARCHAR(30);

    DECLARE CHECKPOLICY CURSOR LOCAL FAST_FORWARD FOR(
    SELECT SQLLoginName
    FROM #CHECK_POLICY);

    OPEN CHECKPOLICY;
    FETCH NEXT FROM CHECKPOLICY
    INTO @UserName5;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '			** Check the following - SQL User Name: ' + @UserName5;
        FETCH NEXT FROM CHECKPOLICY
        INTO @UserName5;
    END;

    CLOSE CHECKPOLICY;
    DEALLOCATE CHECKPOLICY;
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'CHECK_POLICY for All SQL Authenticated Logins';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''CHECK_POLICY'' Option to ON for All SQL Authenticated Logins --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

CREATE TABLE #CLRAssemblyPermission
(
    Name NVARCHAR(50),
    permission_set_desc NVARCHAR(30)
);

INSERT INTO #CLRAssemblyPermission
SELECT name AS Name,
       permission_set_desc AS 'Permission Set Description'
FROM sys.assemblies
WHERE is_user_defined = 1;

IF
(
    SELECT COUNT(*) FROM #CLRAssemblyPermission
) > 0
BEGIN
    PRINT '	* Detected setting for ''CLR Assembly Permission Set'' to SAFE_ACCESS for All CLR Assemblies  --> Security Audit FAILED  --> Apply Recommended changes! ***';
    PRINT '';
    PRINT '	Reason: By setting CLR Assembly Permission Sets to SAFE_ACCESS will prevent assemblies from accessing external';
    PRINT ' resources such as the registry, network resources, files and environment variables.';
    PRINT ' Assemblies with EXTERNAL_ACCESS / UNSAFE permission sets can be used to access areas of the operating system,';
    PRINT ' steal/transmit data and/or alter the state of other protection measures of like antivirus.';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT ' ';
    PRINT '	The following can be executed to change the CHECK_POLICY setting to ON';
    PRINT '';
    PRINT ' 	USE [MASTER]; ';
    PRINT ' 	GO';
    PRINT ' 	ALTER ASSEMBLY assembly_name WITH PERMISSION_SET = SAFE;';
    PRINT ' 	GO';
    PRINT '';
    PRINT '	Default Value: is SAFE permission.';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/ms345101(v=sql.120).aspx';
    PRINT ' 	2. https://msdn.microsoft.com/en-us/library/ms345101(v=sql.110).aspx';
    PRINT ' 	3. https://msdn.microsoft.com/en-us/library/ms189790(v=sql.110).aspx';
    PRINT ' 	4. https://msdn.microsoft.com/en-us/library/ms186711(v=sql.110).aspx';
    PRINT '';

    DECLARE @UserName6 NVARCHAR(30),
            @permission_desc NVARCHAR(10);

    DECLARE CLRAssemblyPerm CURSOR LOCAL FAST_FORWARD FOR(
    SELECT Name,
           permission_set_desc
    FROM #CLRAssemblyPermission);

    OPEN CLRAssemblyPerm;
    FETCH NEXT FROM CLRAssemblyPerm
    INTO @UserName6,
         @permission_desc;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT '			** Check the following - User Name: ' + @UserName6 + '		CLR Assembly Permission: '
              + @permission_desc;
        FETCH NEXT FROM CLRAssemblyPerm
        INTO @UserName6,
             @permission_desc;
    END;

    CLOSE CLRAssemblyPerm;
    DEALLOCATE CLRAssemblyPerm;
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'CLR Assembly Permission Set';
END;
ELSE
BEGIN
    PRINT '	* Detected setting for ''CLR Assembly Permission Set'' to SAFE_ACCESS for All CLR Assemblies --> Security Audit PASSED';
    SET @TestResultCounter = @TestResultCounter + 1;
    PRINT '';
END;

PRINT '';
IF @INSTANCENAME = 'Default Instance'
BEGIN
    PRINT '------------------ * Detected -> SQL Server Instance - Manual Analysis Required ------------------------------------------- ';
    PRINT '';
    PRINT '	Reason: Production SQL Server instances that are non-clustered should have hidden instances to prevent';
    PRINT ' the detection by individuals and cannot be enumerated. DO NOT make this change on clustered';
    PRINT ' SQL Servers as it could break the cluster itself.';
    PRINT '';
    PRINT '	Set the ''Hide Instance'' option to ''Yes'' for Production SQL Server instances that are non-clustered';
    PRINT '';
    PRINT '	Recommended changes: ';
    PRINT '';
    PRINT '		The following steps can be performed with SQL Server Configuration Manager: ';
    PRINT '';
    PRINT ' 			1.	In SQL Server Configuration Manager, expand SQL Server Network Configuration, right-click';
    PRINT ' 			Protocols for ,  and then select Properties. ';
    PRINT '';
    PRINT ' 			2.	On the Flags tab, in the Hide Instance box, select Yes, and then click OK to close the dialog box.';
    PRINT ' 			The change takes effect immediately for new connections. ';
    PRINT '';
    PRINT '	Default Value: SQL Server instances are show and not hidden. ';
    PRINT '';
    PRINT '	References: ';
    PRINT ' 	1. https://msdn.microsoft.com/en-us/library/ms179327(v=sql.120).aspx';
    PRINT ' 	2. https://msdn.microsoft.com/en-us/library/ms179327(v=sql.110).aspx';
    PRINT '';
    INSERT INTO #SASATFailed
    SELECT 'Hide Instance Name';
END;

PRINT '------------------------------------ Automated Check/Test Summary Report -------------------------------------------------------';
PRINT '';
SET @ResultsPercentage = (@TestResultCounter / @TotalAutomatedTests) * 100;
PRINT ' Total number of automated checks/tests that have passed is ' + CONVERT(VARCHAR(4), @TestResultCounter)
      + ' out of ' + CONVERT(VARCHAR(4), @TotalAutomatedTests) + '. Success rate of '
      + (CONVERT(VARCHAR(4), @ResultsPercentage)) + '%';
PRINT '';
PRINT ' Summary of sections that have been marked as Failed/Warning';
PRINT '';
DECLARE @FailedName NVARCHAR(50);
DECLARE AuditRpt CURSOR LOCAL FAST_FORWARD FOR(
SELECT AuditName
FROM #SASATFailed);
OPEN AuditRpt;
FETCH NEXT FROM AuditRpt
INTO @FailedName;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '  - ' + @FailedName;
    FETCH NEXT FROM AuditRpt
    INTO @FailedName;
END;

CLOSE AuditRpt;
DEALLOCATE AuditRpt;
PRINT '';
PRINT '-------------------------------------------- End of SASAT Report ---------------------------------------------------------------';
PRINT '';

-- Performing clean up
IF OBJECT_ID('tempdb..#AutoStart') IS NOT NULL
BEGIN
    DROP TABLE #AutoStart;
END;

IF OBJECT_ID('tempdb..#OrphanUserLIst') IS NOT NULL
BEGIN
    DROP TABLE #OrphanUserLIst;
END;

IF OBJECT_ID('tempdb..#SQLAuthCD') IS NOT NULL
BEGIN
    DROP TABLE #SQLAuthCD;
END;

IF OBJECT_ID('tempdb..#CLRAssemblyPermission') IS NOT NULL
BEGIN
    DROP TABLE #CLRAssemblyPermission;
END;

IF OBJECT_ID('tempdb..#CHECK_POLICY') IS NOT NULL
BEGIN
    DROP TABLE #CHECK_POLICY;
END;

IF OBJECT_ID('tempdb..#CHECK_EXPIRATION') IS NOT NULL
BEGIN
    DROP TABLE #CHECK_EXPIRATION;
END;

IF OBJECT_ID('tempdb..#CONNECTRevokeGuest') IS NOT NULL
BEGIN
    DROP TABLE #CONNECTRevokeGuest;
END;

IF OBJECT_ID('tempdb..#OrphanUers') IS NOT NULL
BEGIN
    DROP TABLE #OrphanUers;
END;

IF OBJECT_ID('tempdb..#TrustedDB') IS NOT NULL
BEGIN
    DROP TABLE #TrustedDB;
END;

IF OBJECT_ID('tempdb..#nodes') IS NOT NULL
BEGIN
    DROP TABLE #nodes;
END;

IF OBJECT_ID('tempdb..#KERBINFO') IS NOT NULL
BEGIN
    DROP TABLE #KERBINFO;
END;

IF OBJECT_ID('tempdb..#SysAdminAccount') IS NOT NULL
BEGIN
    DROP TABLE #SysAdminAccount;
END;

IF OBJECT_ID('tempdb..#SrvAdmin') IS NOT NULL
BEGIN
    DROP TABLE #SrvAdmin;
END;

IF OBJECT_ID('tempdb..#SQL_Server_Settings') IS NOT NULL
BEGIN
    DROP TABLE #SQL_Server_Settings;
END;

IF OBJECT_ID('tempdb..#TraceStats') IS NOT NULL
BEGIN
    DROP TABLE #TraceStats;
END;

IF OBJECT_ID('tempdb..#SASATFailed') IS NOT NULL
BEGIN
    DROP TABLE #SASATFailed;
END;

GO

/***************************************************************************************************************
 -- Un remark the following lines if you would like to show all config setting 
PRINT ''
PRINT ' SQL Server Configuration Settings for this server as per SP_CONFIGURE'
PRINT ''
PRINT ' When making changes to SQL Server configurations, some changes are immediate and some require a restart'
PRINT ' of the SQL related services. Below shows current configurations and when the change(s) take effect.'
PRINT ''
SELECT Name as 'Configuration Name'
, CONVERT (NVARCHAR(6),[VALUE]) as 'Configured Value'
, CONVERT (NVARCHAR(6),[VALUE_IN_USE]) as 'Value in Used'
, CASE (CONVERT (NVARCHAR(15),[is_dynamic]))
	WHEN 0 THEN CAST('Service Restart Needed' as VARCHAR(25))
	WHEN 1 THEN CAST('Change is Immediate' as VARCHAR(25))
END  as '    Change Effect' 
, CONVERT (NVARCHAR(80),[Description]) as 'Description'
FROM SYS.CONFIGURATIONS
GO
***************************************************************************************************************/


/*************************************************************************************
 Quick audit changes for SQL Server that you can do which revokes execution for PUBLIC

REVOKE EXECUTE ON xp_dirtree TO PUBLIC;
REVOKE EXECUTE ON xp_fixeddrives TO PUBLIC; 
REVOKE EXECUTE ON xp_servicecontrol TO PUBLIC;
REVOKE EXECUTE ON xp_subdirs TO PUBLIC;
REVOKE EXECUTE ON xp_regaddmultistring TO PUBLIC; 
REVOKE EXECUTE ON xp_regdeletekey TO PUBLIC;
REVOKE EXECUTE ON xp_regdeletevalue TO PUBLIC; 
REVOKE EXECUTE ON xp_regenumvalues TO PUBLIC; 
REVOKE EXECUTE ON xp_regremovemultistring TO PUBLIC;
REVOKE EXECUTE ON xp_regwrite TO PUBLIC;
REVOKE EXECUTE ON xp_regread TO PUBLIC;
REVOKE EXECUTE ON xp_dirtree TO PUBLIC;
REVOKE EXECUTE ON xp_fixeddrives TO PUBLIC;
REVOKE EXECUTE ON xp_servicecontrol TO PUBLIC; 

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
*************************************************************************************/