USE DBATools;
GO

CREATE PROCEDURE usp_SQLPasswordAudit
AS
BEGIN
    -- if table does not exist create it.
    IF OBJECT_ID(N'dbo.SQLPasswordAudit', N'U') IS NULL
    BEGIN
        PRINT 'Creating Table';

        CREATE TABLE dbo.SQLPasswordAudit
        (
            ID INT IDENTITY(1, 1) NOT NULL,
            ServerName VARCHAR(50) NOT NULL,
            SQL_Login VARCHAR(50) NOT NULL,
            IsSysAdmin BIT NOT NULL
                DEFAULT (0),
            IsWeakPassword BIT NOT NULL
                DEFAULT (0),
            WeakPassword VARCHAR(250) NULL,
            PwdLastUpdate DATETIME2 NOT NULL,
            PwdDaysOld INT NULL,
            DateAudited DATETIME2 NOT NULL
                DEFAULT (GETDATE())
        );

        CREATE CLUSTERED INDEX [cluster_idx_ID]
        ON [dbo].[SQLPasswordAudit] ([ID] ASC)
        WITH (FILLFACTOR = 90);
    END;

    -- Get all SQL Logins
    SELECT @@ServerName ServerName,
           a.name AS SQL_Login,
           b.sysadmin AS IsSysAdmin,
           CAST(LOGINPROPERTY(a.[name], 'PasswordLastSetTime') AS DATETIME) AS "PwdLastUpdate"
    INTO #TempAudit
    FROM sys.sql_logins a
        LEFT JOIN master..syslogins b
            ON a.sid = b.sid
    WHERE a.name NOT LIKE '##%';

    -- Merge with perm table
    MERGE INTO dbo.SQLPasswordAudit a
    USING #TempAudit b
    ON a.SQL_Login = b.SQL_Login
    WHEN MATCHED AND (
                         a.PwdLastUpdate != b.PwdLastUpdate
                         OR a.IsSysAdmin != b.IsSysAdmin
                     ) THEN
        UPDATE SET a.PwdLastUpdate = b.PwdLastUpdate,
                   a.IsSysAdmin = b.IsSysAdmin
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            ServerName,
            SQL_Login,
            IsSysAdmin,
            PwdLastUpdate
        )
        VALUES
        (b.ServerName, b.SQL_Login, b.IsSysAdmin, b.PwdLastUpdate)
    WHEN NOT MATCHED BY SOURCE THEN
        DELETE;

    -- Drop temp table
    DROP TABLE #TempAudit;

    -- Calculate the number of days old the passwords are
    UPDATE dbo.SQLPasswordAudit
    SET PwdDaysOld = DATEDIFF(DAY, PwdLastUpdate, GETDATE());

    -- reset fields for password 
    UPDATE dbo.SQLPasswordAudit
    SET IsWeakPassword = 0,
        WeakPassword = '';

    -- Check if password is blank
    UPDATE dbo.SQLPasswordAudit
    SET WeakPassword = '[BLANK PASSWORD]',
        IsWeakPassword = 1
    FROM dbo.SQLPasswordAudit a
        LEFT JOIN sys.sql_logins b
            ON a.SQL_Login = b.name
    WHERE PWDCOMPARE('', b.password_hash) = 1;

    -- Check if password is same as login
    UPDATE dbo.SQLPasswordAudit
    SET WeakPassword = 'Same As Login',
        IsWeakPassword = 1
    FROM dbo.SQLPasswordAudit a
        LEFT JOIN sys.sql_logins b
            ON a.SQL_Login = b.name
    WHERE PWDCOMPARE(a.SQL_Login, b.password_hash) = 1
          AND a.WeakPassword = '';

    -- Check the common password table if it exists
    IF OBJECT_ID(N'dbo.CommonPwds', N'U') IS NOT NULL
    BEGIN
        UPDATE dbo.SQLPasswordAudit
        SET IsWeakPassword = 1,
            WeakPassword = 'WEAK - ' + c.pwd
        FROM dbo.SQLPasswordAudit a
            LEFT JOIN sys.sql_logins b
                ON a.SQL_Login = b.name
            CROSS JOIN CommonPwds c
        WHERE PWDCOMPARE(c.pwd, b.password_hash) = 1
              AND a.WeakPassword = '';
    END;
END;
GO