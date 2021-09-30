CREATE DATABASE StockAnalysisDemo CONTAINMENT = NONE
ON PRIMARY (
       NAME = N'StockAnalysisDemo',
       FILENAME = N'D:\SQLData\StockAnalysisDemo.mdf',
       SIZE = 8192KB,
       FILEGROWTH = 65536KB
   ),
   FILEGROUP Data (
       NAME = N'StockAnalysisDemo_data',
       FILENAME = N'D:\SQLData\StockAnalysisDemo_data.ndf',
       SIZE = 8192KB,
       FILEGROWTH = 65536KB
   )
LOG ON (
    NAME = N'StockAnalysisDemo_log',
    FILENAME = N'D:\SQLLogs\StockAnalysisDemo_log.ldf',
    SIZE = 8192KB,
    MAXSIZE = 2097152KB,
    FILEGROWTH = 65536KB
);
GO

ALTER DATABASE StockAnalysisDemo MODIFY FILEGROUP Data AUTOGROW_ALL_FILES;
GO

USE StockAnalysisDemo;
GO

IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default = 1 AND name = N'Data') 
	ALTER DATABASE StockAnalysisDemo MODIFY FILEGROUP Data DEFAULT;
GO

CREATE TABLE Stocks (TickerSymbol VARCHAR(4));

INSERT INTO Stocks (TickerSymbol)
SELECT TOP (999) 'Z' + CAST(ROW_NUMBER () OVER (ORDER BY A.name) AS VARCHAR)
FROM sys.objects AS A
CROSS JOIN sys.objects AS B;

CREATE TABLE Dates (TradeDate DATE);

WITH AllDates AS
(
    SELECT TOP (1000) DATEADD (d, ROW_NUMBER () OVER (ORDER BY A.name), '2013-01-01') AS "TradeDate"
    FROM sys.objects AS A
    CROSS JOIN sys.objects AS B
),
     FilterOutWeekends AS
(
    SELECT TradeDate
    FROM AllDates
    WHERE DATENAME (WEEKDAY, TradeDate) NOT IN ( 'Saturday', 'Sunday' )
),
     FilterOutHolidays AS
(
    SELECT TradeDate
    FROM FilterOutWeekends
    WHERE FORMAT (TradeDate, 'mm/dd') NOT IN ( '01/01', '12/25', '07/04' )
          AND TradeDate NOT IN ( '2013-01-21', '2013-02-18', '2013-03-29', '2013-05-27', '2013-09-02', '2013-11-28',
                                 '2014-01-20', '2014-02-17', '2014-04-18', '2014-05-26', '2014-09-01', '2014-11-27',
                                 '2015-01-19', '2015-02-16', '2015-04-03', '2015-05-25', '2015-07-03', '2015-09-07',
                                 '2015-11-26'
)
)
INSERT INTO Dates (TradeDate)
SELECT TradeDate
FROM FilterOutHolidays;


CREATE TABLE StockHistory (TickerSymbol VARCHAR(4), TradeDate DATE, ClosePrice DECIMAL(5, 2));

INSERT INTO StockHistory (TickerSymbol, TradeDate, ClosePrice)
SELECT TickerSymbol,
       '2013-01-02',
       CAST(RAND (CAST(NEWID () AS VARBINARY)) * 100 AS DECIMAL(5, 2))
FROM Stocks;

DECLARE @CurrentDate AS DATE;
DECLARE @PrevDate AS DATE;

DECLARE DATES CURSOR FAST_FORWARD FOR
SELECT TradeDate
FROM Dates
ORDER BY TradeDate;
OPEN DATES;
FETCH NEXT FROM DATES
INTO @PrevDate;
FETCH NEXT FROM DATES
INTO @CurrentDate;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO StockHistory (TickerSymbol, TradeDate, ClosePrice)
    SELECT TickerSymbol,
           @CurrentDate,
           ClosePrice + CASE
                            WHEN CAST(RAND (CAST(NEWID () AS VARBINARY)) * 10 AS TINYINT) % 2 = 0 THEN -1
                            ELSE 1
                        END * CAST(RAND (CAST(NEWID () AS VARBINARY)) AS DECIMAL(5, 2))
    FROM StockHistory
    WHERE TradeDate = @PrevDate;

    SET @PrevDate = @CurrentDate;
    FETCH NEXT FROM DATES
    INTO @CurrentDate;
END;
CLOSE DATES;
DEALLOCATE DATES;