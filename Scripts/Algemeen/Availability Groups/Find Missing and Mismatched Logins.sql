/***********************************************************************************************************************************
Author: David Fowler
Revision date: 04/12/2018
Version: 1.0

Description: Scripts to indentify missing logins in an availability group as well as mismatched SIDs and logins

Copyright 2018 Sql Undercover
***********************************************************************************************************************************/

-- create temp table to hold your AG details (this will be included in the Undercover Catalogue v0.2 release, so if you're in the future and that is out then tweek the scripts to point at Catalogue.AvailabilityGroups)

IF OBJECT_ID('tempdb.dbo.#AGs') IS NOT NULL
    DROP TABLE #AGs;

CREATE TABLE #AGs
(
    AGName sysname,
    ServerName sysname,
    AGRole VARCHAR(9)
);

INSERT INTO #AGs
VALUES
('AG1', 'SQLUndercoverTest01', 'PRIMARY'),
('AG1', 'SQLUndercoverTest02', 'SECONDARY'),
('AG1', 'SQLUndercoverTest03', 'SECONDARY'),
('AG1', 'SQLUndercoverTest04', 'SECONDARY'),
('AG1', 'SQLUndercoverTest05', 'SECONDARY');

-- Identify missing logins

SELECT DISTINCT
       AGs.AGName,
       Logins.LoginName,
       AGs2.ServerName AS [Missing On Node]
FROM #AGs AS AGs
    JOIN Catalogue.Logins AS Logins
        ON AGs.ServerName = Logins.ServerName
    JOIN #AGs AS AGs2
        ON AGs.AGName = AGs2.AGName
WHERE NOT EXISTS
(
    SELECT 1
    FROM #AGs AS AGs3
        JOIN Catalogue.Logins AS Logins3
            ON AGs3.ServerName = Logins3.ServerName
    WHERE AGs3.AGName = AGs.AGName
          AND AGs3.ServerName = AGs2.ServerName
          AND Logins3.LoginName = Logins.LoginName
);

-- Identify mismatched SIDs

SELECT DISTINCT
       PrimaryLogins.ServerName AS PrimaryServer,
       SecondaryLogins.ServerName AS SecondaryServer,
       SecondaryLogins.LoginName,
       PrimaryLogins.sid AS PrimarySID,
       SecondaryLogins.sid AS SecondarySID,
       'DROP LOGIN ' + QUOTENAME(SecondaryLogins.LoginName) + '; CREATE LOGIN ' + QUOTENAME(SecondaryLogins.LoginName)
       + ' WITH PASSWORD = 0x' + CONVERT(VARCHAR(MAX), PrimaryLogins.PasswordHash, 2) + ' HASHED, SID = 0x'
       + CONVERT(VARCHAR(MAX), PrimaryLogins.sid, 2) + ';' AS CreateCMD
FROM
(
    SELECT AGs.AGName,
           AGs.ServerName,
           Logins.LoginName,
           Logins.sid,
           Logins.PasswordHash
    FROM #AGs AS AGs
        JOIN Catalogue.Logins AS Logins
            ON AGs.ServerName = Logins.ServerName
    WHERE AGs.AGRole = 'PRIMARY'
) AS PrimaryLogins
    JOIN
    (
        SELECT AGs.AGName,
               AGs.ServerName,
               Logins.LoginName,
               Logins.sid
        FROM #AGs AS AGs
            JOIN Catalogue.Logins AS Logins
                ON AGs.ServerName = Logins.ServerName
        WHERE AGs.AGRole = 'SECONDARY'
    ) AS SecondaryLogins
        ON PrimaryLogins.AGName = SecondaryLogins.AGName
           AND PrimaryLogins.LoginName = SecondaryLogins.LoginName
WHERE PrimaryLogins.sid != SecondaryLogins.sid;

-- Identify mismatched passwords

SELECT DISTINCT
       PrimaryLogins.ServerName AS PrimaryServer,
       SecondaryLogins.ServerName AS SecondaryServer,
       SecondaryLogins.LoginName,
       PrimaryLogins.PasswordHash AS PrimaryPasswordHash,
       SecondaryLogins.PasswordHash AS SecondaryPasswordHash,
       'DROP LOGIN ' + QUOTENAME(SecondaryLogins.LoginName) + '; CREATE LOGIN ' + QUOTENAME(SecondaryLogins.LoginName)
       + ' WITH PASSWORD = 0x' + CONVERT(VARCHAR(MAX), PrimaryLogins.PasswordHash, 2) + ' HASHED, SID = 0x'
       + CONVERT(VARCHAR(MAX), PrimaryLogins.sid, 2) + ';' AS CreateCMD
FROM
(
    SELECT AGs.AGName,
           AGs.ServerName,
           Logins.LoginName,
           Logins.sid,
           Logins.PasswordHash
    FROM #AGs AS AGs
        JOIN Catalogue.Logins AS Logins
            ON AGs.ServerName = Logins.ServerName
    WHERE AGs.AGRole = 'PRIMARY'
) AS PrimaryLogins
    JOIN
    (
        SELECT AGs.AGName,
               AGs.ServerName,
               Logins.LoginName,
               Logins.sid,
               Logins.PasswordHash
        FROM #AGs AS AGs
            JOIN Catalogue.Logins AS Logins
                ON AGs.ServerName = Logins.ServerName
        WHERE AGs.AGRole = 'SECONDARY'
    ) AS SecondaryLogins
        ON PrimaryLogins.AGName = SecondaryLogins.AGName
           AND PrimaryLogins.LoginName = SecondaryLogins.LoginName
WHERE PrimaryLogins.PasswordHash != SecondaryLogins.PasswordHash;