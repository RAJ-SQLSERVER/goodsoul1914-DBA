/*

██████╗ ██████╗ ███████╗███╗   ██╗████████╗     ██████╗ ███████╗ █████╗ ██████╗ 
██╔══██╗██╔══██╗██╔════╝████╗  ██║╚══██╔══╝    ██╔═══██╗╚══███╔╝██╔══██╗██╔══██╗
██████╔╝██████╔╝█████╗  ██╔██╗ ██║   ██║       ██║   ██║  ███╔╝ ███████║██████╔╝
██╔══██╗██╔══██╗██╔══╝  ██║╚██╗██║   ██║       ██║   ██║ ███╔╝  ██╔══██║██╔══██╗
██████╔╝██║  ██║███████╗██║ ╚████║   ██║       ╚██████╔╝███████╗██║  ██║██║  ██║
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝

 Twitch Stream on 2020/6/27
 My comment @8m30 in                                                                              
*/
-- Create 100 databases
DECLARE @Loop INT;

SET @Loop = 100;

WHILE @Loop > 0
    BEGIN
        EXEC ('CREATE DATABASE [Test_' + @Loop + '];');

        SET @Loop = @Loop + 1;
    END;
GO

-- Run sp_BlitzFirst 
EXEC DBATools.dbo.sp_blitzfirst;
GO

-- Count the number of user databases
IF 20 >= (
    SELECT COUNT (*)
    FROM sys.databases
    WHERE name NOT IN ( 'master', 'model', 'msdb', 'tempdb' )
)
    BEGIN
        -- only perform action when database count <= 20 
        PRINT 'Okay! Will run action.';
    END;
GO

-- Random SQL question
CREATE TABLE Trades (
    TRADE_ID  VARCHAR(MAX),
    TIMESTAMP TIME(0),
    SECURITY  VARCHAR(MAX),
    QUANTITY  INT,
    PRICE     INT
);

INSERT INTO Trades
VALUES ('TRADE1', '10:01:05', 'BP', 100, 20),
       ('TRADE2', '10:01:06', 'BP', 20, 15),
       ('TRADE3', '10:10:00', 'BP', -100, 19),
       ('TRADE4', '10:10:01', 'BP', -300, 19),
       ('TRADE5', '10:01:08', 'BP', 150, 30),
       ('TRADE6', '10:01:09', 'BP', 300, 32);
GO

/*
Expected output:

First_Trade Second_Trade    PRICE_DIFF
-----------|---------------|----------
TRADE1      TRADE2          25
TRADE1      TRADE5          50
TRADE1      TRADE6          60
TRADE2      TRADE5          100
TRADE2      TRADE6          113
*/
SELECT t1.PRICE,
       t2.PRICE,
       (t1.PRICE - t2.PRICE) * 100.00 / t1.PRICE
FROM Trades AS t1
JOIN Trades AS t2
    ON t2.TIMESTAMP >= t1.TIMESTAMP
       AND t2.TIMESTAMP < DATEADD (SECOND, 10, t1.TIMESTAMP)
       AND t2.TRADE_ID <> t1.TRADE_ID
       AND t2.PRICE NOT BETWEEN 0.9 * t1.PRICE AND 1.1 * t1.PRICE;
GO
