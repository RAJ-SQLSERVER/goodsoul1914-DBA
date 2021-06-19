CREATE TABLE [dbo].[Certificates]
(
[PSComputerName] [nvarchar] (max) NULL,
[NotAfter] [datetime2] (7) NULL,
[NotBefore] [datetime2] (7) NULL,
[HasPrivateKey] [bit] NULL,
[SerialNumber] [nvarchar] (max) NULL,
[Version] [int] NULL,
[Issuer] [nvarchar] (max) NULL,
[Subject] [nvarchar] (max) NULL
) TEXTIMAGE_
GO
