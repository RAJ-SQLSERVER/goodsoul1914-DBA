CREATE TABLE employees
(
    id           INT PRIMARY KEY CLUSTERED,
    firstname    VARCHAR(150),
    lastname     VARCHAR(150),
    phonenumber  VARCHAR(20),
    emailaddress VARCHAR(500),
    city         VARCHAR(50),
    state        VARCHAR(50),
    postalcode   VARCHAR(10),
    country      VARCHAR(50)
)
GO

INSERT INTO employees
SELECT businessentityid,
        firstname,
        lastname jobtitle,
        phonenumber,
        emailaddress,
        city,
        stateprovincename,
        postalcode,
        countryregionname
FROM   humanresources.vemployee
WHERE  firstname IS NOT NULL
        AND lastname IS NOT NULL
GO


select id, name as [IndexName] ,rowmodctr [Rows Modification] ,rowcnt [Number of Rows] 
from sys.sysindexes 
where ID =OBJECT_ID('employees')


update employees 
set city='New York' 
where city='Bothell'



select id, name as [IndexName] ,rowmodctr [Rows Modification] ,rowcnt [Number of Rows] 
from sys.sysindexes 
where ID =OBJECT_ID('employees')


DELETE FROM employees 
WHERE  city = 'Bothell'
go
SELECT id, NAME AS [IndexName], rowmodctr [Rows Modification], rowcnt [Number of Rows]
FROM   sys.sysindexes 
WHERE  id = Object_id('employees')
GO


SELECT SCH.NAME      [SCHEMA_NAME],
OBJ.NAME             [TABLE_NAME],
MAX(IK.ROWCNT)       [ROW_COUNT],
MAX(IX.ROWMODCTR)    [ROWS_MODIFIED],
MAX(SP.LAST_UPDATED) [LAST_UODATED]
FROM   SYS.OBJECTS AS OBJ
INNER JOIN SYS.SCHEMAS SCH ON OBJ.[SCHEMA_ID] = SCH.[SCHEMA_ID]
INNER JOIN SYS.STATS AS STAT ON STAT.[OBJECT_ID] = OBJ.[OBJECT_ID]
CROSS APPLY SYS.DM_DB_STATS_PROPERTIES(STAT.[OBJECT_ID], STAT.STATS_ID) AS SP
LEFT OUTER JOIN SYS.SYSINDEXES AS IX ON STAT.[OBJECT_ID] = IX.ID AND STAT.[NAME] = IX.NAME
LEFT OUTER JOIN SYS.SYSINDEXES AS IK ON STAT.[OBJECT_ID] = IK.ID AND IK.INDID = 1
WHERE MODIFICATION_COUNTER > 10
AND OBJ.[OBJECT_ID] > 100
GROUP BY SCH.NAME, OBJ.NAME
go


create procedure dbo.sp_daily_stats_update
as
Begin
set nocount on 

create table #databases (
id int , 
name varchar(max)
)

create table #TablesUpdated (
id int identity(1,1),
DBName varchar(250), 
Schemaname varchar(30),
tablename varchar(250),
totalrows int, 
rowmodified int,
statsupdatedate datetime 
)

create table ##StatisticsReport (
id int identity(1,1),
DBName varchar(250), 
Schemaname varchar(30),
tablename varchar(250),
totalrows int, 
rowmodified int
)

insert into #databases(name) 
select name 
from sys.databases 
where database_id>5

declare @SQLQuery nvarchar(max)
declare @UpdateStatisticsQuery nvarchar(max)
declare @i int =0
declare @DBName varchar(max)
declare @DBCount int

set @DBCount = (select count(1) from #databases)

While @DBCount>@i
Begin
set @DBName = (select top 1 name from #databases)
set @SQLQuery = 'SELECT 
''' + @DBName + ''',
sch.NAME             [Schema_Name],
        obj.NAME             [Table_Name],
        Max(ik.rowcnt)       [Row_Count],
        Max(ix.rowmodctr)    [Rows_Modified],
        Max(sp.last_updated) [Last_Uodated]
FROM   '+@DBName+'.sys.objects AS obj
        INNER JOIN '+@DBName+'.sys.schemas sch
                ON obj.[schema_id] = sch.[schema_id]
        INNER JOIN '+@DBName+'.sys.stats AS stat
                ON stat.[object_id] = obj.[object_id]
        CROSS apply '+@DBName+'.sys.Dm_db_stats_properties(stat.[object_id], stat.stats_id)
                    AS sp
        LEFT OUTER JOIN '+@DBName+'.sys.sysindexes AS ix
                    ON stat.[object_id] = ix.id
                        AND stat.[name] = ix.NAME
        LEFT OUTER JOIN '+@DBName+'.sys.sysindexes AS ik
                    ON stat.[object_id] = ik.id
                        AND ik.indid = 1
WHERE  modification_counter > 10
        AND obj.[object_id] > 100
GROUP  BY sch.NAME,
            obj.NAME'

insert into #TablesUpdated (DBName,Schemaname,tablename,totalrows,rowmodified,statsupdatedate)
exec sp_executesql @SQLQuery

delete 
from #databases 
where name=@DBName

set @I=@i+1
End		    

select * 
from #TablesUpdated

insert into ##StatisticsReport (DBName,Schemaname,tablename,totalrows,rowmodified) 
select DBName,Schemaname,tablename,totalrows,rowmodified from #TablesUpdated

declare @j int =0
declare @DB_Name varchar(max)
declare @tableCount int

set @TableCount=(select count(1) from #TablesUpdated)

declare @Schema_Name varchar(250)
declare @Table_Name varchar(250) 

While (@TableCount>@j)
Begin
select top 1 @DB_Name = DBName, @Schema_Name=Schemaname,@Table_Name=tablename 
from #TablesUpdated

set @UpdateStatisticsQuery = 'Update Statistics [' +@DB_Name +'].[' +@Schema_Name +'].[' +@Table_Name+ '] With FULLSCAN;'

exec sp_executesql @UpdateStatisticsQuery

delete 
from #TablesUpdated 
where DBName=@DB_Name and Schemaname=@Schema_Name and tablename=@Table_Name

set @j =@j +1
End

DECLARE @lsMessage VARCHAR(2000)  
DECLARE @SubjectText VARCHAR(2000)  
DECLARE @Filename VARCHAR(2000) 
 
SET @SubjectText = 'Statistics Update Report - ' + @@SERVERNAME  
SET @Filename = 'statistics_update_report_' + @@SERVERNAME + '_' + CONVERT(VARCHAR, GETDATE(), 112)  + '.csv'   
SET @lsMessage =   
    '<p style="font-family:Arial; font-size:10pt">Statistics have been updated.  Please review the report for a list of databases and tables affected.  ' +  
    '</p>' 

EXEC msdb.dbo.sp_send_dbmail    
    @recipients='nisargupadhyay87@outlook.com',   
    @body=@lsMessage,   
    @subject=@SubjectText,     
    @importance='high',   
    @body_format='HTML',   
    @profile_name='OutlookMail'      
,@query = 'SELECT DBName,Schemaname,tablename,totalrows,rowmodified FROM ##StatisticsReport' ,  
    @attach_query_result_as_file = 1,  
    @query_attachment_filename=@Filename,
    @query_result_separator='	'
drop table #databases
drop table #TablesUpdated
drop table ##StatisticsReport
End


Exec sp_daily_stats_update

