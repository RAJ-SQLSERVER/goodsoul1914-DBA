-- 
-- 09-01-2014, Maico Pijnen, FZR
--
-- Script om alle resterende SQL connecties vanuit VDI stations te verbreken 
-- HIX staat erom bekend dat er een nieuwe connectie wordt opgebouwd, dus moet hix ook nog hard afgesloten worden
--

-- HIX productie database
USE HIX_PRODUCTIE

-- Gebruik een cursor om door de resultaat van actieve connecties te lopen
DECLARE UserCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
    spid,hostname
FROM
    master.dbo.sysprocesses
WHERE DB_NAME(dbid) = 'HIX_PRODUCTIE'
DECLARE @spid SMALLINT
DECLARE @hostname VARCHAR(100)
DECLARE @SQLCommand VARCHAR(300)
OPEN UserCursor
FETCH NEXT FROM UserCursor INTO
    @spid,@hostname
WHILE @@FETCH_STATUS = 0
BEGIN
	-- Query die uitgevoerd wordt om de connectie via de spid te killen
    SET @SQLCommand = 'KILL ' + CAST(@spid AS VARCHAR)
	-- Hier zit de controle in voor de PODS. Alleen de connectie sluiten als deze bijvoorbeeld begint met VD1 of VD3
	IF @hostname <> '' AND (SUBSTRING(@hostname,1,3) = 'VD1' OR SUBSTRING(@hostname,1,3) = 'VD3')
	BEGIN
		EXECUTE(@SQLCommand)
		PRINT 'CONNECTION WITH HOSTNAME '+RTRIM(@hostname)+' KILLED'
	END

    FETCH NEXT FROM UserCursor INTO
        @spid,@hostname
END
CLOSE UserCursor
DEALLOCATE UserCursor
GO
