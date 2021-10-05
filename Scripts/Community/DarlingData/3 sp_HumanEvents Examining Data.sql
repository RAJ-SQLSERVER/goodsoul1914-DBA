/*
Part of what gets installed when you log data to tables are some views in the same database.

You can check in on them like this:
*/

/* Queries */
SELECT TOP (1000) *
FROM dbo.HumanEvents_Queries;

/* Waits */
SELECT TOP (1000) *
FROM dbo.HumanEvents_WaitsByQueryAndDatabase;

SELECT TOP (1000) *
FROM dbo.HumanEvents_WaitsByDatabase;

SELECT TOP (1000) *
FROM dbo.HumanEvents_WaitsTotal;

/* Blocking */
SELECT TOP (1000) *
FROM dbo.HumanEvents_Blocking;

/* Compiles, only on newer versions of SQL Server */
SELECT TOP (1000) *
FROM dbo.HumanEvents_CompilesByDatabaseAndObject;

SELECT TOP (1000) *
FROM dbo.HumanEvents_CompilesByQuery;

SELECT TOP (1000) *
FROM dbo.HumanEvents_CompilesByDuration;

/* Otherwise */
SELECT TOP 1000 *
FROM dbo.HumanEvents_Compiles_Legacy;

/* Parameterization data, if available (comes along with compiles) */
SELECT TOP (1000) *
FROM dbo.HumanEvents_Parameterization;

/* Recompiles, only on newer versions of SQL Server */
SELECT TOP (1000) *
FROM dbo.HumanEvents_RecompilesByDatabaseAndObject;

SELECT TOP (1000) *
FROM dbo.HumanEvents_RecompilesByQuery;

SELECT TOP (1000) *
FROM dbo.HumanEvents_RecompilesByDuration;

/* Otherwise */
SELECT TOP (1000) *
FROM dbo.HumanEvents_Recompiles_Legacy;