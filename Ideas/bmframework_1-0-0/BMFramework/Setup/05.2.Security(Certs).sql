/****************************************************************************/
/*                    Blocking Monitoring Framework                         */
/*                                                                          */
/*                  Written by Dmitri V. Korotkevitch                       */
/*                http://aboutsqlserver.com/bmframework                     */
/*                        dk@aboutsqlserver.com                             */
/****************************************************************************/
/*                              Initial Setup                               */
/*                            Setting Up Security                           */
/****************************************************************************/


-- Certificate-based security. Do not forget to re-sign activation stored procedures
-- when you alter them and/or upgrade the framework

USE master;
GO

IF EXISTS (
    SELECT *
    FROM sys.server_principals
    WHERE name = 'BMFrameworkLogin'
          AND type = 'C'
)
    DROP LOGIN BMFrameworkLogin;

IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'BMFrameworkCert')
    DROP CERTIFICATE BMFrameworkCert;
GO

USE DBA;
GO

IF EXISTS (
    SELECT *
    FROM sys.crypt_properties
    WHERE major_id = OBJECT_ID (N'dbo.SB_BlockedProcessReport_Activation')
          AND crypt_type = 'SPVC'
)
    DROP SIGNATURE FROM dbo.SB_BlockedProcessReport_Activation
    BY CERTIFICATE BMFrameworkCert;

IF EXISTS (
    SELECT *
    FROM sys.crypt_properties
    WHERE major_id = OBJECT_ID (N'dbo.SB_DeadlockEvent_Activation')
          AND crypt_type = 'SPVC'
)
    DROP SIGNATURE FROM dbo.SB_DeadlockEvent_Activation
    BY CERTIFICATE BMFrameworkCert;

IF EXISTS (
    SELECT *
    FROM sys.database_principals
    WHERE name = 'EventMonitoringUser'
          AND type = 'S'
)
    DROP USER EventMonitoringUser;
IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'BMFrameworkCert')
    DROP CERTIFICATE BMFrameworkCert;
GO

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pas$word1'; -- Use Strong Password instead
GO

CREATE CERTIFICATE BMFrameworkCert
WITH SUBJECT = 'Cert for event monitoring',
     EXPIRY_DATE = '20301031';
GO

-- We need to re-sign every time we alter 
-- the stored procedure
ADD SIGNATURE TO dbo.SB_BlockedProcessReport_Activation
BY  CERTIFICATE BMFrameworkCert;
GO

ADD SIGNATURE TO dbo.SB_DeadlockEvent_Activation
BY  CERTIFICATE BMFrameworkCert;
GO

BACKUP CERTIFICATE BMFrameworkCert TO FILE = 'BMFrameworkCert.cer';
GO

USE master;
GO

CREATE CERTIFICATE BMFrameworkCert FROM FILE = 'BMFrameworkCert.cer';
GO

CREATE LOGIN BMFrameworkLogin FROM CERTIFICATE BMFrameworkCert;
GO

GRANT VIEW SERVER STATE, AUTHENTICATE SERVER TO BMFrameworkLogin;
GO
