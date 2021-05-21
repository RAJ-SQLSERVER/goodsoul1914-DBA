USE [HIX_PRODUCTIE]
GO

/****** Object:  StoredProcedure [dbo].[BVS_ReIndex]    Script Date: 24-1-2020 17:25:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[BVS_ReIndex] 
  @Mode sysname = null,
  @PlayTimeInMinutes int = 60,
  @MaxAvgSeconds int = 900,
  @LikeTableName sysname = null
  WITH RECOMPILE
as
set nocount on
declare @PeriodType varchar(2)
declare @PeriodAmount int
declare @ReindexMode int
-----------------------------------------------------------------------------
--- !!! pas hier de indexhoudbaarheidsdatum en de Reindex methode aan !!! ---
-----------------------------------------------------------------------------
set @PeriodType='D'        -- M=maanden, W=weken, D=dagen
set @PeriodAmount=0        -- aantal maanden/weken of dagen, als de index ouder dan deze waarde is komt de index in aanmerking voor herindexering
set @ReindexMode=3         -- 1='dbcc dbreindex', 2 = 'alter index offline', 3 = 'alter index online'
-------------------------------------------------------
--- !!! hieronder niets aanpassen               !!! ---
-------------------------------------------------------
if @mode = 'clear'
begin
  if object_id('dbo.BVS_IndexLog') is not null
    drop table dbo.BVS_IndexLog
  return
end

declare @ScriptStartTime datetime
set @ScriptStartTime= GETDATE()

declare @IndexStillGoodDate datetime
set @IndexStillGoodDate=case @PeriodType 
                          when 'M'  then ( DateAdd(mm, -isnull(@PeriodAmount, 1), getdate()) - ( SUBSTRING(CONVERT(nvarchar(12),GETDATE(), 114),1,12) ) )  
                          when 'W'  then ( DateAdd(ww, -isnull(@PeriodAmount, 1), getdate()) - ( SUBSTRING(CONVERT(nvarchar(12),GETDATE(), 114),1,12) ) )       
                          when 'D'  then ( DateAdd(dd, -isnull(@PeriodAmount, 1), getdate()) - ( SUBSTRING(CONVERT(nvarchar(12),GETDATE(), 114),1,12) ) )   
                          when 'Mi' then ( DateAdd(mi, -isnull(@PeriodAmount, 1), getdate()) - ( SUBSTRING(CONVERT(nvarchar(12),GETDATE(), 114),1,12) ) )        
                        else
                          null
                        end

if object_id('dbo.BVS_IndexLog') is null
begin
  create table dbo.BVS_IndexLog (TableId int, IndexName sysname, IndexStart datetime, IndexStop datetime, NrOfRows int, ScriptStart datetime, ReIndexQuery varchar(8000), IndexRuns integer, IndexTime integer)
  create clustered index IndexLog on dbo.BVS_IndexLog (TableID, IndexName, IndexStart)
end

insert into dbo.BVS_IndexLog
  select id TableID, name IndexName, null IndexStart, null IndexStop, rowcnt NrOfRows, @ScriptStartTime as ScriptStart, null ReIndexQuery, 0 IndexRuns, 0 IndexTime
  from sysindexes si
  where indid not in (0,255) 
    and ObjectProperty(id, 'IsUserTable') = 1 
    and IndexProperty(id, name, 'IsStatistics') = 0
    and (isnull(@LikeTableName, '') = '' or object_name(id) like @LikeTableName)
    and not exists (select * 
                    from dbo.BVS_IndexLog il with(nolock)
                    where il.TableId = si.id and il.IndexName = si.name and (IndexStart is null or IndexStart >= @IndexStillGoodDate))

declare @TableID int
declare @IndexName sysname
declare @Q varchar(8000)
declare @Start datetime
declare @NrOfRows int

if @mode='show'
begin
        select 
          case @ReindexMode
            when 1 then 'dbcc dbreindex(['+Object_Name(il.TableId)+'],['+il.IndexName+'])'
            when 2 then case
            				WHEN NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR = 100, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  99, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  98, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  97, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  96, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows >=       50000001               THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, SORT_IN_TEMPDB = ON)'
							ELSE 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(online = OFF, SORT_IN_TEMPDB = ON)' 
							END
            when 3 then case
							WHEN NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR = 100, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  99, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  98, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  97, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  96, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows >=       50000001               THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							ELSE 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							END
							
          else
            'Herindexeren ['+Object_Name(il.TableId)+'],['+il.IndexName+']'
          end as ReIndexQuery,
          GemDuurInSec,
          NrOfRows,
          LaatsteReIndexDatum,
          DateDiff(dd, LaatsteReIndexDatum, getdate()) AantalDagenOud
        from dbo.BVS_IndexLog il 
        left outer join (
          select TableId, IndexName, avg(datediff(ss, IndexStart, IndexStop)) GemDuurInSec, max(IndexStop) LaatsteReIndexDatum
          from dbo.BVS_IndexLog 
          where IndexStop is not null
            and IndexStop >= DATEADD(dd, -60, GETDATE())  
          group by TableId, IndexName      
        ) il2 on il.TableId = il2.TableId and il.IndexName = il2.IndexName
        where IndexStart is null 
--			and (NrOfRows >          0)   -- 20181114 MBL Start REINDEX
		and (isnull(@LikeTableName, '') = '' or object_name(il.TableId) like @LikeTableName)

        order by isnull(DateDiff(dd, LaatsteReIndexDatum, getdate()), 999) desc, NrOfRows asc
end

if @Mode = 'reindex'
begin

        while getdate() < dateadd(mi, @PlayTimeInMinutes, @ScriptStartTime)
        begin
          set @TableId=null

		  IF EXISTS (SELECT 1 FROM sys.index_resumable_operations where name = @IndexName)
		  begin
			  select top 1 @TableId = il.TableId, @IndexName = il.IndexName, @NrOfRows = il.NrOfRows
			  from dbo.BVS_IndexLog il
          where IndexStop is null and IndexRuns > 0
          and (isnull(@LikeTableName, '') = '' or object_name(TableId) like @LikeTableName)
          order by 
            isnull(DateDiff(dd,
                            (select max(IndexStop) from dbo.BVS_IndexLog il2 where il.TableId = il2.TableId and il.IndexName = il2.IndexName and IndexStop is not null), 
                            getdate()), 999) desc, 
            NrOfRows asc

          if @TableId is null
          begin
            break
          end
          
          select @Q = 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] RESUME with(MAX_DURATION=1)'
          end

          IF NOT EXISTS (SELECT 1 FROM sys.index_resumable_operations where name = @IndexName)
		  begin
			  select top 1 @TableId = il.TableId, @IndexName = il.IndexName, @NrOfRows = il.NrOfRows
			  from dbo.BVS_IndexLog il
          where IndexStart is null 
          and (isnull(@LikeTableName, '') = '' or object_name(TableId) like @LikeTableName)
          order by 
            isnull(DateDiff(dd,
                            (select max(IndexStop) from dbo.BVS_IndexLog il2 where il.TableId = il2.TableId and il.IndexName = il2.IndexName and IndexStop is not null), 
                            getdate()), 999) desc, 
            NrOfRows asc

          if @TableId is null
          begin
            break
          end
          
          select @Q=case @ReindexMode
            when 1 then 'dbcc dbreindex(['+Object_Name(@TableId)+'],['+@IndexName+'])'
            when 2 then case
            				WHEN @NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR = 100, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)'
							WHEN @NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  99, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)'
							WHEN @NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  98, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)'
							WHEN @NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  97, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)'
							WHEN @NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  96, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)'
							WHEN @NrOfRows >=       50000001               THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)'
							ELSE 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' 
							END
            when 3 then case
							WHEN @NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR = 100, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  99, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  98, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  97, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  96, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows >=       50000001               THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							ELSE 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							END
          end


          raiserror(@Q, 0, 1) with nowait

          set @Start=getdate() 

          update dbo.BVS_IndexLog 
          set IndexStart = @Start
          where TableId = @TableId and IndexName = @IndexName and IndexStart is null
          
          update dbo.BVS_IndexLog 
          set ReIndexQuery = CONVERT(varchar(8000), @Q)
          where TableId = @TableId and IndexName = @IndexName and IndexStart = @Start

		  DECLARE @t1 DATETIME;
		  DECLARE @t2 DATETIME;

          SET @t1 = GETDATE();
		  exec (@Q)
		  SET @t2 = GETDATE();

		  IF EXISTS (SELECT 1 FROM sys.index_resumable_operations where name = @IndexName)
		  begin
	          update dbo.BVS_IndexLog 
	          set IndexRuns = IndexRuns + 1
			    , IndexTime = IndexTime + 60
			  where TableId = @TableId and IndexName = @IndexName and IndexStart = @Start
		  end

		  end
          
		  IF NOT EXISTS (SELECT 1 FROM sys.index_resumable_operations where name = @IndexName)
		  begin
	          update dbo.BVS_IndexLog 
	          set IndexRuns = IndexRuns + 1
			    , IndexTime = IndexTime + DATEDIFF(ss,@t1,@t2)
			  where TableId = @TableId and IndexName = @IndexName and IndexStart = @Start
		  end

        end          
        raiserror('Done', 0, 1) with nowait
end

if @Mode = 'reindex_resume'
begin
CREATE TABLE #EZIS_Reindex_resume
( IndexName VARCHAR (255)
, ReindexQuery VARCHAR (255)
, GemDuurInSec INTEGER
, NrOfRows     INTEGER
, LaatsteReindexDatum DATETIME
, AantalDagenOud INTEGER)

set @MaxAvgSeconds = 60   --20181116 RMR
		insert into #EZIS_Reindex_resume
        select 
		il.indexname, 
          case @ReindexMode
            when 1 then 'dbcc dbreindex(['+Object_Name(il.TableId)+'],['+il.IndexName+'])'
            when 2 then case
            				WHEN NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR = 100, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  99, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  98, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  97, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  96, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN NrOfRows >=       50000001               THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, SORT_IN_TEMPDB = ON)'
							ELSE 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, SORT_IN_TEMPDB = ON)' 
							END
            when 3 then case
							WHEN NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR = 100, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  99, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  98, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  97, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  96, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							WHEN NrOfRows >=       50000001               THEN 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							ELSE 'alter index ['+il.IndexName+'] on dbo.['+Object_Name(il.TableId)+case when IndexProperty(il.TableId, il.IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = il.TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, SORT_IN_TEMPDB = ON)' else '] reorganize' end
							END
          else
            'Herindexeren ['+Object_Name(il.TableId)+'],['+il.IndexName+']'
          end as ReIndexQuery,
          GemDuurInSec,
          NrOfRows,
          LaatsteReIndexDatum,
          DateDiff(dd, LaatsteReIndexDatum, getdate()) AantalDagenOud
        from dbo.EzisIndexLog il 
        left outer join (
          select TableId, IndexName, avg(datediff(ss, IndexStart, IndexStop)) GemDuurInSec, max(IndexStop) LaatsteReIndexDatum
          from dbo.EzisIndexLog 
          where IndexStop is not null
            and IndexStop >= DATEADD(dd, -60, GETDATE())     
          group by TableId, IndexName      
        ) il2 on il.TableId = il2.TableId and il.IndexName = il2.IndexName
        where IndexStart is null 
--		and ((il.IndexName not like '%VRLIJST_LSTOPSLG%')
		and (GemDuurInSec > @MaxAvgSeconds)
--		and (NrOfRows <= 25000000)  --20181114 MBL maximaliseren FAST REINDEX
		and (NrOfRows >         0)  --20181114 MBL Start waarde
		and (isnull(@LikeTableName, '') = '' or object_name(il.TableId) like @LikeTableName)

        order by isnull(DateDiff(dd, LaatsteReIndexDatum, getdate()), 999) desc, NrOfRows asc


        while getdate() < dateadd(mi, @PlayTimeInMinutes, @ScriptStartTime)
        begin
			/****************************************************************************************/
			IF ((SELECT COUNT(*) FROM sys.index_resumable_operations) > 0)
			BEGIN
				PRINT N'Groter dan 1'
				-- Toon de indexes die gepauzeerd zijn
				DECLARE @ResumeQuery VARCHAR(2000)
				SET @ResumeQuery = 
				(
					SELECT TOP 1
--					'ALTER INDEX [' + i.name + '] on dbo.[' + o.name + '] RESUME with(MAX_DURATION='+ @PlayTimeInMinutes +')' AS ResumeQry
					'ALTER INDEX [' + i.name + '] on dbo.[' + o.name + '] RESUME with(MAX_DURATION=1)' AS ResumeQry
					  FROM sys.index_resumable_operations i
					     , sys.objects o
				     WHERE i.object_id = o.object_id
				     ORDER BY percent_complete DESC
				)
	
				-- Neem de index die het hoogste percentage heeft
				raiserror(@ResumeQuery, 0, 1) with nowait
				exec (@ResumeQuery)
			END


		 IF getdate() < dateadd(mi, @PlayTimeInMinutes, @ScriptStartTime)
		 BEGIN

			/***************************************************************************************/
          set @TableId=null
          SET @ReindexMode = 3 -- 20170616 BVS RMR

          select top 1 @TableId = il.TableId, @IndexName = il.IndexName, @NrOfRows = il.NrOfRows
          from dbo.EzisIndexLog il
          where IndexStart is null
		 --   and (il.IndexName not like '%VRLIJST_VROPSLG%')
			--and (il.IndexName not like '%METINGEN_METINGEN%') 
			--and (il.IndexName not like '%SEELOG_SEELOGI%')
			--and (il.IndexName not like '%MUTLOG_MUTLOG%')
			--and (NrOfRows <= 500000000)   -- 20181114 MBL maximaliseren REINDEX
			--and (NrOfRows >     100000)   -- 20181114 MBL Start REINDEX
		    and (il.IndexName COLLATE SQL_Latin1_General_CP1_CI_AS IN (SELECT IndexName from #EZIS_Reindex_resume ))


          and (isnull(@LikeTableName, '') = '' or object_name(TableId) like @LikeTableName)
          order by 
            isnull(DateDiff(dd,
                            (select max(IndexStop) from dbo.EzisIndexLog il2 where il.TableId = il2.TableId and il.IndexName = il2.IndexName and IndexStop is not null), 
                            getdate()), 999) desc, 
            NrOfRows asc

          if @TableId is null
          begin
            break
          end
          
          /* Toegevoegd voor bepaling van @reindexmode - 20171616 */
          IF EXISTS(SELECT SchemaName = OBJECT_SCHEMA_NAME(p.object_id)
        ,ObjectName = OBJECT_NAME(p.object_id)
        ,IndexName  = si.name
        ,p.object_id
        ,p.index_id
        ,au.type_desc
   FROM sys.system_internals_allocation_units au --Has allocation type
   JOIN sys.system_internals_partitions p        --Has an Index_ID
     ON au.container_id = p.partition_id
   JOIN sys.indexes si                           --For the name of the index
     ON si.object_id    = p.object_id
    AND si.index_id     = p.index_id
  WHERE au.type_desc    = 'LOB_DATA'
  AND p.object_id = @TableID
  AND si.name = @IndexName)
  BEGIN
	SET @ReindexMode = 3
END
/* EINDE TOEVOEGING */
          
          select @Q=case @ReindexMode
            when 1 then 'dbcc dbreindex(['+Object_Name(@TableId)+'],['+@IndexName+'])'
            when 2 then case
            				WHEN @NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR = 100, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN @NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  99, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN @NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  98, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN @NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  97, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN @NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  96, online = OFF, SORT_IN_TEMPDB = ON)'
							WHEN @NrOfRows >=       50000001               THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, SORT_IN_TEMPDB = ON)'
							ELSE 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+'] rebuild with(FILLFACTOR =  95, online = OFF, SORT_IN_TEMPDB = ON)' 
							END
            when 3 then case
							WHEN @NrOfRows BETWEEN         0 and    100000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR = 100, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN    100001 and   1000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  99, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN   1000001 and   5000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  98, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN   5000001 and  10000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  97, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows BETWEEN  10000001 and  50000000 THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  96, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							WHEN @NrOfRows >=       50000001               THEN 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							ELSE 'alter index ['+@IndexName+'] on dbo.['+Object_Name(@TableId)+case when IndexProperty(@TableId, @IndexName, 'IsClustered') = 0 OR not exists (select * from syscolumns where xtype in (34,35,99) and syscolumns.id = @TableId) then '] rebuild with(FILLFACTOR =  95, online = ON, MAXDOP=12, RESUMABLE = ON, MAX_DURATION = 1)' else '] reorganize' end
							END
          end

          raiserror(@Q, 0, 1) with nowait

          set @Start=getdate() 

          update dbo.EzisIndexLog 
          set IndexStart = @Start
          where TableId = @TableId and IndexName = @IndexName and IndexStart is null
          
          update dbo.EzisIndexLog 
          set ReIndexQuery = CONVERT(varchar(8000), @Q)
          where TableId = @TableId and IndexName = @IndexName and IndexStart = @Start

          exec (@Q)

          update dbo.EzisIndexLog 
          set IndexStop = getdate() 
          where TableId = @TableId and IndexName = @IndexName and IndexStart = @Start

        end          
        raiserror('Done', 0, 1) with nowait
		END
end

if @mode is null or @mode = 'reindex' or @mode = 'show' 
begin
        select 
'Nog '+cast(count(*) as sysname)+' indexen te herindexeren,
Historisch gezien ongeveer '+cast( cast(sum(IsNull(GemDuurInSec, 0))/60 as int) as sysname)+' minuten werk.
Totaal '+cast(cast(sum(cast(NrOfRows as bigint)) / 1000000 as integer) as sysname)+' miljoen records te verwerken.
Oudste index voor de controle is van '+convert(char(8), min(isnull(OudsteIndex,'29991231')), 112)
        from dbo.BVS_IndexLog il 
        left outer join (
          select TableId, IndexName, avg(datediff(ss, IndexStart, IndexStop)) GemDuurInSec, max(IndexStop) LaatsteReIndexDatum, min(IndexStop) OudsteIndex
          from dbo.BVS_IndexLog 
          where IndexStop is not null
            and IndexStop >= DATEADD(dd, -60, GETDATE())   
          group by TableId, IndexName      
        ) il2 on il.TableId = il2.TableId and il.IndexName = il2.IndexName
        where IndexStart is null 
--			and (NrOfRows >          0)   -- 20181114 MBL Start REINDEX

        and (isnull(@LikeTableName, '') = '' or object_name(il.TableId) like @LikeTableName)
end

GO


