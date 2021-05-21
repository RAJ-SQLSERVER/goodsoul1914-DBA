/* 
sys.dm_os_performance_counters. Returns a row per performance counter maintained by the server. 
For per-second counters, this value is cumulative. The rate value must be calculated 
by sampling the value at discrete time intervals. The difference between any two successive 
sample values is equal to the rate for the time interval used.
*/
DECLARE @command NVARCHAR(MAX) = N'';
SELECT @command = @command + command
FROM
(
    SELECT DISTINCT
           'sum(CASE WHEN instance_name=''' + RTRIM(LOWER(instance_name)) + ''' THEN cntr_value ELSE 0 END) AS ['
           + +RTRIM(LOWER(instance_name)) + '],
   '    AS command
    FROM sys.dm_os_performance_counters
    WHERE [object_name] LIKE '%:Databases%'
) f;
--SELECT @command;

/*
first gather up all the names of the databases, and do a pivot rotation
by doing a GROUP BY with case statements in each aggregation
sum(CASE WHEN instance_name='_Total' THEN cntr_value ELSE 0 END) AS [_Total],
sum(CASE WHEN instance_name='NorthWind' THEN cntr_value ELSE 0 END) AS [NorthWind], 
sum(CASE WHEN instance_name='AdventureWorks2016' THEN cntr_value ELSE 0 END) AS [AdventureWorks2016], 
  ...etc...
now we insert that string into the command and execute it. We interpret the five different 
counter types used just in case the name of the counter type isn't informative enough
*/
DECLARE @TheFullCommand NVARCHAR(MAX)
    = N'SELECT @@ServerName as server, rtrim(counter_name) as [Counter_Name], [Counter_Type],
     ' + @command
      + N''''' as [ ] 
    FROM sys.dm_os_performance_counters pcs
    LEFT OUTER JOIN (VALUES (65792,''no. items''),
       (272696576,''rate per sec.''),
       (537003264,''average bulk''),
       (1073874176, ''average count''),
       (1073939712, ''large raw base''))f(TheCounter,[Counter_type])
     ON f.TheCounter=pcs.cntr_type
     WHERE [Object_Name] LIKE ''%:Databases%''
     GROUP BY counter_name, [Counter_type]';
EXECUTE (@TheFullCommand);
