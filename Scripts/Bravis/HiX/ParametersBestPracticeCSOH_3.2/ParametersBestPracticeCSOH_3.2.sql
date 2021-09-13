/*
- Parameters gebaseerd op Scripts van Ola Hallengren: https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html
- Elke avond/nacht starten. Zorg dat dit zo min mogelijk overlapt met andere langdurige processen 
  die van invloed op het indexeren kunnen zijn

Aanbevolen:
- Scripts van Ola Hallengren installeren in database zelf, niet op MASTER (tenzij OTA)
- Always-on cluster 10gbit verbinding

Het script bevat 2 losse stappen:
- iedere stap doet meerdere index-acties (statistics berekeken, reorganizen of herindexeren)
- Iedere stap zal zolang er nog geen 2 uur verstreken is een nieuwe index-actie starten.
- Indien een index-aktie niet gestart kan worden omdat er geen lock verkregen kan worden, 
  zal die aktie na 5 minuten worden afgebroken en wordt er doorgegaan met de volgende index-actie
- alleen op een Sql Server met Standard Edition zal OFFLINE worden geherindexeerd, anders gewoon ONLINE

Stap 0 (Vaststellen variabelen)
- Stap 0 stelt de variabelen vast die in stappen 1 en 2 worden gebruikt. Onder andere de grote en 
  kleine tabellen worden onderscheid in gemaakt.

Stap 1 (Grote tabellen):
- Alle indexen van alle tabellen met een page count groter dan 500.000 worden reorganized bij een 
  fragmentatie tussen de 5% en 30%
- Alle indexen van alle tabellen met een page count groter dan 500.000 worden gerebuild bij een 
  fragmentatie hoger dan 30%
- Alle statistics van alle indexen van alle tabellen met een page count groter dan 500.000 worden 
  hier indien nodig geupdate met een samplerate van 10%
- Grote indexen worden eerst gedaan, zodat wanneer er sprake is van uitloop de uitloop in de nacht 
  plaats vind. 

Stap 2 (Kleine tabellen):
- Alle indexen van alle tabellen met een page count kleiner dan 500.000 worden reorganized bij een 
  fragmentatie tussen de 5% en 30%
- Alle indexen van alle tabellen met een page count kleiner dan 500.000 worden gerebuild bij een 
  fragmentatie hoger dan 30%
- Alle statistics van alle indexen van alle tabellen met een page count kleiner dan 500.000 worden 
  hier indien nodig geupdate met een samplerate van 100%
*/

--stap 0
DECLARE @FragmentationMediumArgument NVARCHAR(MAX)
    = IIF(SERVERPROPERTY ('EngineEdition') = 2,
          'INDEX_REORGANIZE,INDEX_REBUILD_OFFLINE',
          'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE');
DECLARE @FragmentationHighArgument NVARCHAR(MAX)
    = IIF(SERVERPROPERTY ('EngineEdition') = 2,
          'INDEX_REBUILD_OFFLINE,INDEX_REORGANIZE',
          'INDEX_REBUILD_ONLINE,INDEX_REORGANIZE');

CREATE TABLE #BigTables (fullTableName sysname);

EXEC sp_MSforeachdb 'use [?];insert into #BigTables select db_name()+''.''+OBJECT_SCHEMA_NAME(id)+''.''+OBJECT_name(id) from sysindexes where dpages > 500000 and indid in (0,1)';

DECLARE @ExcludeBigTables NVARCHAR(MAX)
    = N'ALL_INDEXES' + (SELECT ',-' + fullTableName FROM #BigTables FOR XML PATH (''));
DECLARE @IncludeBigTables NVARCHAR(MAX)
    = (STUFF ((SELECT ',' + fullTableName FROM #BigTables FOR XML PATH ('')), 1, 1, ''));

DROP TABLE #BigTables;

-- Stap 1
EXECUTE dbo.IndexOptimize @Databases = 'USER_DATABASES',
                          @FragmentationLow = NULL,
                          @FragmentationMedium = @FragmentationMediumArgument,
                          @FragmentationHigh = @FragmentationHighArgument,
                          @FragmentationLevel1 = 5,
                          @FragmentationLevel2 = 30,
                          @StatisticsSample = 10,
                          @UpdateStatistics = 'ALL',
                          @OnlyModifiedStatistics = 'Y',
                          @MaxDOP = 4,
                          @TimeLimit = 14400,
                          @LogToTable = 'Y',
                          @WaitAtLowPriorityMaxDuration = 5,
                          @WaitAtLowPriorityAbortAfterWait = SELF,
                          @Indexes = @IncludeBigTables;

-- Stap 2
EXECUTE dbo.IndexOptimize @Databases = 'USER_DATABASES',
                          @FragmentationLow = NULL,
                          @FragmentationMedium = @FragmentationMediumArgument,
                          @FragmentationHigh = @FragmentationHighArgument,
                          @FragmentationLevel1 = 5,
                          @FragmentationLevel2 = 30,
                          @MinNumberOfPages = 0,
                          @StatisticsSample = 100,
                          @UpdateStatistics = 'ALL',
                          @OnlyModifiedStatistics = 'Y',
                          @MaxDOP = 4,
                          @TimeLimit = 7200,
                          @LogToTable = 'Y',
                          @WaitAtLowPriorityMaxDuration = 5,
                          @WaitAtLowPriorityAbortAfterWait = SELF,
                          @Indexes = @ExcludeBigTables;

